import { ApiProperty } from '@nestjs/swagger';

export class CartItemResponseDto {
  @ApiProperty({ description: 'Cart Item ID' })
  id: string;

  @ApiProperty({ description: 'Product ID' })
  productId: string;

  @ApiProperty({ description: 'Product Variant ID' })
  productVariantId: string;

  @ApiProperty({ description: 'Quantity in cart' })
  quantity: number;

  @ApiProperty({ description: 'Current unit price of the selected variant' })
  unitPrice: number;

  @ApiProperty({ description: 'Total price for this cart item (unitPrice * quantity)' })
  itemTotal: number;

  @ApiProperty({ description: 'Selected variant primary image URL' })
  selectedImageUrl: string;

  @ApiProperty({ description: 'Whether the item is out of stock or requested quantity exceeds available stock' })
  isOutOfStock: boolean;

  @ApiProperty({ description: 'Available stock quantity' })
  stock: number;

  @ApiProperty({ description: 'Stock status string (IN_STOCK, OUT_OF_STOCK, INSUFFICIENT_STOCK)' })
  stockStatus: string;

  @ApiProperty({ description: 'Product details' })
  product: any;

  @ApiProperty({ description: 'Variant details' })
  variant: any;

  @ApiProperty({ description: 'Shipping details for this product' })
  shipping: any;

  @ApiProperty({ description: 'Created date timestamp' })
  createdAt: Date;

  @ApiProperty({ description: 'Updated date timestamp' })
  updatedAt: Date;
}

export class CartSummaryDto {
  @ApiProperty({ description: 'Subtotal sum of all active items' })
  subtotal: number;

  @ApiProperty({ description: 'Total calculated shipping charges' })
  shippingCharge: number;

  @ApiProperty({ description: 'Estimated total (subtotal + shippingCharge)' })
  estimatedTotal: number;

  @ApiProperty({ description: 'Total item quantities in cart' })
  totalItems: number;

  @ApiProperty({ description: 'Total unique items count in cart' })
  itemCount: number;

  @ApiProperty({ description: 'Whether cart contains any out of stock items' })
  hasOutOfStockItems: boolean;
}

export class CartFullResponseDto {
  @ApiProperty({ description: 'List of cart items', type: [CartItemResponseDto] })
  items: CartItemResponseDto[];

  @ApiProperty({ description: 'Cart summary details', type: CartSummaryDto })
  summary: CartSummaryDto;
}
