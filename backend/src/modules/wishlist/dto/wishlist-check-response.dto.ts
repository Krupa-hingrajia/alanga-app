import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class WishlistCheckResponseDto {
  @ApiProperty({ description: 'Whether the product/variant is in the customer wishlist', example: true })
  isWishlisted: boolean;

  @ApiPropertyOptional({ description: 'Wishlist Item ID if wishlisted', example: 'wsh-123-uuid', nullable: true })
  wishlistId: string | null;

  constructor(isWishlisted: boolean, wishlistId: string | null = null) {
    this.isWishlisted = isWishlisted;
    this.wishlistId = wishlistId;
  }
}
