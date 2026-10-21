import {
  Injectable,
  BadRequestException,
  Logger,
  InternalServerErrorException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../database/prisma.service';
import { CheckoutService } from '../orders/services/checkout.service';
import { OrderService } from '../orders/services/order.service';
import { CreatePaymentOrderDto, PaymentGateway } from './dto/create-payment-order.dto';
import { VerifyPaymentDto } from './dto/verify-payment.dto';
import { PaymentMethod } from '../orders/dto/place-order.dto';
import * as crypto from 'crypto';
import axios from 'axios';

// eslint-disable-next-line @typescript-eslint/no-require-imports
const Razorpay = require('razorpay');

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
    private readonly checkoutService: CheckoutService,
    private readonly orderService: OrderService,
  ) {}

  /**
   * Return public configuration for frontends (Public Keys & Environment)
   */
  getPaymentConfig() {
    const razorpayKeyId =
      this.configService.get<string>('RAZORPAY_KEY_ID') || 'rzp_test_placeholder';
    const cashfreeAppId =
      this.configService.get<string>('CASHFREE_APP_ID') || 'cf_test_placeholder';
    const cashfreeEnv =
      (this.configService.get<string>('CASHFREE_ENV') || 'TEST').toUpperCase();

    return {
      razorpayKeyId,
      cashfreeAppId,
      cashfreeEnv,
    };
  }

  /**
   * Create an online payment order on Razorpay or Cashfree
   */
  async createPaymentOrder(customerId: string, dto: CreatePaymentOrderDto) {
    const customer = await this.prisma.user.findUnique({
      where: { id: customerId },
    });

    if (!customer) {
      throw new BadRequestException('Customer account not found.');
    }

    // 1. Calculate live checkout summary & amount
    const summary = await this.checkoutService.getCheckoutSummary(customerId);
    if (!summary || summary.items.length === 0) {
      throw new BadRequestException('Shopping cart is empty. Cannot create payment order.');
    }

    if (summary.hasOutOfStockItems) {
      throw new BadRequestException('One or more items in your cart are currently out of stock.');
    }

    const amount = Number(summary.grandTotal.toFixed(2));
    if (amount <= 0) {
      throw new BadRequestException('Order amount must be greater than zero.');
    }

    // 2. Dispatch to selected Gateway
    if (dto.gateway === PaymentGateway.RAZORPAY) {
      return this.createRazorpayOrder(customerId, amount, dto.addressId);
    } else if (dto.gateway === PaymentGateway.CASHFREE) {
      return this.createCashfreeOrder(customer, amount, dto.addressId);
    } else {
      throw new BadRequestException(`Unsupported gateway: ${dto.gateway}`);
    }
  }

  /**
   * Verify online payment and atomically place the confirmed order
   */
  async verifyAndPlaceOrder(customerId: string, dto: VerifyPaymentDto) {
    this.logger.log(
      `[verifyAndPlaceOrder] Verifying payment for customer ${customerId} via ${dto.gateway} | OrderId: ${dto.gatewayOrderId}`,
    );

    // 1. Verify payment validity
    if (dto.gateway === PaymentGateway.RAZORPAY) {
      this.verifyRazorpaySignature(dto);
    } else if (dto.gateway === PaymentGateway.CASHFREE) {
      await this.verifyCashfreePayment(dto);
    } else {
      throw new BadRequestException(`Unsupported gateway: ${dto.gateway}`);
    }

    // 2. Place order with verified online payment
    const paymentMethod =
      dto.gateway === PaymentGateway.RAZORPAY
        ? PaymentMethod.RAZORPAY
        : PaymentMethod.CASHFREE;

    return this.orderService.placeOrder(customerId, {
      addressId: dto.addressId,
      paymentMethod,
      notes: dto.notes,
      gatewayOrderId: dto.gatewayOrderId,
      gatewayPaymentId: dto.gatewayPaymentId,
      gatewaySignature: dto.gatewaySignature,
    });
  }

  // =========================================================================
  // RAZORPAY IMPLEMENTATION
  // =========================================================================

  private async createRazorpayOrder(customerId: string, amount: number, addressId: string) {
    const keyId = this.configService.get<string>('RAZORPAY_KEY_ID');
    const keySecret = this.configService.get<string>('RAZORPAY_KEY_SECRET');

    if (!keyId || !keySecret || keyId.includes('placeholder')) {
      // In development fallback/mock if keys not yet provided
      this.logger.warn('Razorpay credentials not fully configured. Using mock order ID.');
      return {
        gateway: PaymentGateway.RAZORPAY,
        orderId: `order_mock_${Date.now()}`,
        amount: Math.round(amount * 100),
        currency: 'INR',
        keyId: keyId || 'rzp_test_placeholder',
        isMock: true,
      };
    }

    try {
      const rzp = new Razorpay({
        key_id: keyId,
        key_secret: keySecret,
      });

      const options = {
        amount: Math.round(amount * 100), // in paise
        currency: 'INR',
        receipt: `ALG_${Date.now().toString(36).toUpperCase()}`,
        notes: {
          customerId,
          addressId,
        },
      };

      const rzpOrder = await rzp.orders.create(options);

      return {
        gateway: PaymentGateway.RAZORPAY,
        orderId: rzpOrder.id,
        amount: rzpOrder.amount,
        currency: rzpOrder.currency,
        keyId,
        isMock: false,
      };
    } catch (err: any) {
      this.logger.error(`Razorpay order creation failed: ${err.message}`);
      throw new InternalServerErrorException(
        `Failed to initialize Razorpay payment: ${err.error?.description || err.message}`,
      );
    }
  }

  private verifyRazorpaySignature(dto: VerifyPaymentDto) {
    const keySecret = this.configService.get<string>('RAZORPAY_KEY_SECRET');

    // If running with mock order in dev
    if (dto.gatewayOrderId.startsWith('order_mock_') || !keySecret || keySecret.includes('placeholder')) {
      this.logger.warn('Mock Razorpay verification accepted in development mode.');
      return true;
    }

    if (!dto.gatewayPaymentId || !dto.gatewaySignature) {
      throw new BadRequestException('Missing paymentId or signature for Razorpay verification.');
    }

    const payload = `${dto.gatewayOrderId}|${dto.gatewayPaymentId}`;
    const expectedSignature = crypto
      .createHmac('sha256', keySecret)
      .update(payload)
      .digest('hex');

    if (expectedSignature !== dto.gatewaySignature) {
      this.logger.error(
        `Razorpay signature mismatch: expected ${expectedSignature}, received ${dto.gatewaySignature}`,
      );
      throw new BadRequestException('Invalid payment signature. Payment verification failed.');
    }

    return true;
  }

  // =========================================================================
  // CASHFREE IMPLEMENTATION
  // =========================================================================

  private async createCashfreeOrder(customer: any, amount: number, addressId: string) {
    const appId = this.configService.get<string>('CASHFREE_APP_ID');
    const secretKey = this.configService.get<string>('CASHFREE_SECRET_KEY');
    const env = (this.configService.get<string>('CASHFREE_ENV') || 'TEST').toUpperCase();

    if (!appId || !secretKey || appId.includes('placeholder')) {
      this.logger.warn('Cashfree credentials not fully configured. Using mock session ID.');
      return {
        gateway: PaymentGateway.CASHFREE,
        orderId: `CF_mock_${Date.now()}`,
        paymentSessionId: `session_mock_${Date.now()}`,
        orderAmount: amount,
        environment: env,
        isMock: true,
      };
    }

    const baseUrl =
      env === 'PROD'
        ? 'https://api.cashfree.com/pg'
        : 'https://sandbox.cashfree.com/pg';

    const cfOrderId = `CF_${Date.now()}_${Math.random().toString(36).substring(2, 6).toUpperCase()}`;

    // Clean phone number (needs 10 digits for Indian numbers)
    const phone = (customer.phoneNumber || '9999999999').replace(/[^0-9]/g, '').slice(-10);

    try {
      const response = await axios.post(
        `${baseUrl}/orders`,
        {
          order_id: cfOrderId,
          order_amount: amount,
          order_currency: 'INR',
          customer_details: {
            customer_id: customer.id,
            customer_phone: phone,
            customer_name: customer.fullName || 'Customer',
            customer_email: customer.email || 'customer@alangashop.com',
          },
          order_meta: {
            return_url: 'https://alanga.com/payment-return?order_id={order_id}',
            notify_url: 'https://alanga.com/api/v1/payments/cashfree-webhook',
          },
          order_note: `Address: ${addressId}`,
        },
        {
          headers: {
            'x-client-id': appId,
            'x-client-secret': secretKey,
            'x-api-version': '2023-08-01',
            'Content-Type': 'application/json',
          },
        },
      );

      return {
        gateway: PaymentGateway.CASHFREE,
        orderId: cfOrderId,
        paymentSessionId: response.data.payment_session_id,
        orderAmount: amount,
        environment: env,
        isMock: false,
      };
    } catch (err: any) {
      this.logger.error(`Cashfree order creation failed: ${err.response?.data?.message || err.message}`);
      throw new InternalServerErrorException(
        `Failed to initialize Cashfree payment: ${err.response?.data?.message || err.message}`,
      );
    }
  }

  private async verifyCashfreePayment(dto: VerifyPaymentDto) {
    const appId = this.configService.get<string>('CASHFREE_APP_ID');
    const secretKey = this.configService.get<string>('CASHFREE_SECRET_KEY');
    const env = (this.configService.get<string>('CASHFREE_ENV') || 'TEST').toUpperCase();

    if (dto.gatewayOrderId.startsWith('CF_mock_') || !appId || appId.includes('placeholder')) {
      this.logger.warn('Mock Cashfree verification accepted in development mode.');
      return true;
    }

    const baseUrl =
      env === 'PROD'
        ? 'https://api.cashfree.com/pg'
        : 'https://sandbox.cashfree.com/pg';

    try {
      const response = await axios.get(`${baseUrl}/orders/${dto.gatewayOrderId}`, {
        headers: {
          'x-client-id': appId,
          'x-client-secret': secretKey,
          'x-api-version': '2023-08-01',
        },
      });

      const orderData = response.data;
      if (orderData.order_status !== 'PAID') {
        throw new BadRequestException(
          `Cashfree order status is "${orderData.order_status}". Payment was not completed.`,
        );
      }

      return true;
    } catch (err: any) {
      if (err instanceof BadRequestException) throw err;
      this.logger.error(`Cashfree verification error: ${err.response?.data?.message || err.message}`);
      throw new InternalServerErrorException(
        `Could not verify Cashfree payment: ${err.response?.data?.message || err.message}`,
      );
    }
  }
}
