import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

typedef OnPaymentSuccess = void Function({
  required String gateway,
  required String orderId,
  String? paymentId,
  String? signature,
});

typedef OnPaymentError = void Function({
  required String gateway,
  required String message,
});

class PaymentGatewayService {
  Razorpay? _razorpay;
  CFPaymentGatewayService? _cfService;

  OnPaymentSuccess? _onSuccess;
  OnPaymentError? _onError;
  String? _currentOrderId;

  void initialize({
    required OnPaymentSuccess onSuccess,
    required OnPaymentError onError,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;

    // 1. Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpaySuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorpayExternalWallet);

    // 2. Initialize Cashfree
    _cfService = CFPaymentGatewayService();
    _cfService!.setCallback(
      (String orderId) {
        debugPrint('[Cashfree] Payment Success for Order: $orderId');
        _onSuccess?.call(
          gateway: 'CASHFREE',
          orderId: orderId,
          paymentId: null,
          signature: null,
        );
      },
      (CFErrorResponse errorResponse, String orderId) {
        debugPrint('[Cashfree] Payment Error: ${errorResponse.getMessage()} (Code: ${errorResponse.getCode()})');
        _onError?.call(
          gateway: 'CASHFREE',
          message: errorResponse.getMessage() ?? 'Cashfree payment was cancelled or failed.',
        );
      },
    );
  }

  /// Launch Razorpay Checkout
  void openRazorpay({
    required String keyId,
    required String orderId,
    required num amountInPaise,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
  }) {
    if (_razorpay == null) {
      _onError?.call(gateway: 'RAZORPAY', message: 'Razorpay SDK is not initialized.');
      return;
    }

    _currentOrderId = orderId;

    final options = {
      'key': keyId,
      'amount': amountInPaise,
      'name': 'ALANGA',
      'description': 'Marketplace Order Payment',
      'order_id': orderId,
      'timeout': 300, // 5 minutes
      'prefill': {
        'contact': customerPhone,
        'email': customerEmail,
        'name': customerName,
      },
      'theme': {
        'color': '#11261B',
      },
      'modal': {
        'confirm_close': true,
      },
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      _onError?.call(gateway: 'RAZORPAY', message: 'Failed to launch Razorpay: $e');
    }
  }

  /// Launch Cashfree Drop Checkout
  void openCashfree({
    required String orderId,
    required String paymentSessionId,
    required String environment, // 'PROD' or 'TEST'
  }) {
    if (_cfService == null) {
      _onError?.call(gateway: 'CASHFREE', message: 'Cashfree SDK is not initialized.');
      return;
    }

    _currentOrderId = orderId;

    try {
      final cfEnv = environment.toUpperCase() == 'PROD'
          ? CFEnvironment.PRODUCTION
          : CFEnvironment.SANDBOX;

      final session = CFSessionBuilder()
          .setEnvironment(cfEnv)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();

      final webCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .build();

      _cfService!.doPayment(webCheckout);
    } catch (e) {
      _onError?.call(gateway: 'CASHFREE', message: 'Failed to launch Cashfree: $e');
    }
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) {
    debugPrint('[Razorpay] Payment Success! PaymentId: ${response.paymentId}, OrderId: ${response.orderId}');
    _onSuccess?.call(
      gateway: 'RAZORPAY',
      orderId: response.orderId ?? _currentOrderId ?? '',
      paymentId: response.paymentId,
      signature: response.signature,
    );
  }

  void _handleRazorpayError(PaymentFailureResponse response) {
    debugPrint('[Razorpay] Payment Failed: ${response.message} (Code: ${response.code})');
    _onError?.call(
      gateway: 'RAZORPAY',
      message: response.message ?? 'Payment cancelled or failed.',
    );
  }

  void _handleRazorpayExternalWallet(ExternalWalletResponse response) {
    debugPrint('[Razorpay] External Wallet Selected: ${response.walletName}');
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
    _cfService = null;
    _onSuccess = null;
    _onError = null;
  }
}
