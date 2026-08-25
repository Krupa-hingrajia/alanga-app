import { Injectable } from '@nestjs/common';
import { IProductShippingRepository } from '../interfaces/product-shipping-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { ProductShippingEntity } from '../entities/product-shipping.entity';

@Injectable()
export class ProductShippingRepository implements IProductShippingRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(data: any): ProductShippingEntity {
    return new ProductShippingEntity({
      id: data.id,
      productId: data.productId,
      weight: data.weight,
      weightUnit: data.weightUnit,
      length: data.length,
      width: data.width,
      height: data.height,
      dimensionUnit: data.dimensionUnit,
      shippingCharge: data.shippingCharge,
      isFreeShipping: data.isFreeShipping,
      freeShippingAboveAmount: data.freeShippingAboveAmount,
      estimatedDeliveryMinDays: data.estimatedDeliveryMinDays,
      estimatedDeliveryMaxDays: data.estimatedDeliveryMaxDays,
      codAvailable: data.codAvailable,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    });
  }

  async findByProductId(productId: string): Promise<ProductShippingEntity | null> {
    const shipping = await this.prisma.productShipping.findUnique({
      where: { productId },
    });
    return shipping ? this.mapToEntity(shipping) : null;
  }

  async create(productId: string, data: any): Promise<ProductShippingEntity> {
    const shipping = await this.prisma.productShipping.create({
      data: {
        productId,
        weight: data.weight ?? 0,
        weightUnit: data.weightUnit ?? 'kg',
        length: data.length ?? 0,
        width: data.width ?? 0,
        height: data.height ?? 0,
        dimensionUnit: data.dimensionUnit ?? 'cm',
        shippingCharge: data.shippingCharge ?? 0,
        isFreeShipping: data.isFreeShipping ?? false,
        freeShippingAboveAmount: data.freeShippingAboveAmount ?? null,
        estimatedDeliveryMinDays: data.estimatedDeliveryMinDays ?? 3,
        estimatedDeliveryMaxDays: data.estimatedDeliveryMaxDays ?? 7,
        codAvailable: data.codAvailable ?? true,
      },
    });
    return this.mapToEntity(shipping);
  }

  async update(productId: string, data: any): Promise<ProductShippingEntity> {
    const updatePayload: any = {};
    if (data.weight !== undefined) updatePayload.weight = data.weight;
    if (data.weightUnit !== undefined) updatePayload.weightUnit = data.weightUnit;
    if (data.length !== undefined) updatePayload.length = data.length;
    if (data.width !== undefined) updatePayload.width = data.width;
    if (data.height !== undefined) updatePayload.height = data.height;
    if (data.dimensionUnit !== undefined) updatePayload.dimensionUnit = data.dimensionUnit;
    if (data.shippingCharge !== undefined) updatePayload.shippingCharge = data.shippingCharge;
    if (data.isFreeShipping !== undefined) updatePayload.isFreeShipping = data.isFreeShipping;
    if (data.freeShippingAboveAmount !== undefined) updatePayload.freeShippingAboveAmount = data.freeShippingAboveAmount;
    if (data.estimatedDeliveryMinDays !== undefined) updatePayload.estimatedDeliveryMinDays = data.estimatedDeliveryMinDays;
    if (data.estimatedDeliveryMaxDays !== undefined) updatePayload.estimatedDeliveryMaxDays = data.estimatedDeliveryMaxDays;
    if (data.codAvailable !== undefined) updatePayload.codAvailable = data.codAvailable;

    const shipping = await this.prisma.productShipping.update({
      where: { productId },
      data: updatePayload,
    });
    return this.mapToEntity(shipping);
  }

  async upsert(productId: string, data: any): Promise<ProductShippingEntity> {
    const payload = {
      weight: data.weight ?? 0,
      weightUnit: data.weightUnit ?? 'kg',
      length: data.length ?? 0,
      width: data.width ?? 0,
      height: data.height ?? 0,
      dimensionUnit: data.dimensionUnit ?? 'cm',
      shippingCharge: data.shippingCharge ?? 0,
      isFreeShipping: data.isFreeShipping ?? false,
      freeShippingAboveAmount: data.freeShippingAboveAmount ?? null,
      estimatedDeliveryMinDays: data.estimatedDeliveryMinDays ?? 3,
      estimatedDeliveryMaxDays: data.estimatedDeliveryMaxDays ?? 7,
      codAvailable: data.codAvailable ?? true,
    };

    const shipping = await this.prisma.productShipping.upsert({
      where: { productId },
      create: {
        productId,
        ...payload,
      },
      update: payload,
    });
    return this.mapToEntity(shipping);
  }
}
