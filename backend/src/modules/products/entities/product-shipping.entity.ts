import { ProductShipping } from '@prisma/client';

export class ProductShippingEntity implements ProductShipping {
  id: string;
  productId: string;
  weight: number;
  weightUnit: string;
  length: number;
  width: number;
  height: number;
  dimensionUnit: string;
  shippingCharge: number;
  isFreeShipping: boolean;
  freeShippingAboveAmount: number | null;
  estimatedDeliveryMinDays: number;
  estimatedDeliveryMaxDays: number;
  codAvailable: boolean;
  createdAt: Date;
  updatedAt: Date;

  constructor(partial: Partial<ProductShippingEntity>) {
    Object.assign(this, partial);
  }
}
