import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody, ApiParam, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { WishlistService } from '../services/wishlist.service';
import { CreateWishlistDto } from '../dto/create-wishlist.dto';
import { WishlistResponseDto } from '../dto/wishlist-response.dto';
import { WishlistCheckResponseDto } from '../dto/wishlist-check-response.dto';

@ApiTags('Customer Wishlist')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.CUSTOMER)
@Controller('customer/wishlist')
export class CustomerWishlistController {
  constructor(private readonly wishlistService: WishlistService) {}

  @Post('toggle')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Toggle Product or Variant in Customer Wishlist (Add if absent, Remove if present)' })
  @ApiBody({ type: CreateWishlistDto })
  @ApiResponse({ status: 200, description: 'Wishlist status toggled successfully.' })
  @ApiResponse({ status: 400, description: 'Validation failed or variant does not belong to product.' })
  @ApiResponse({ status: 404, description: 'Product or variant not found.' })
  async toggleWishlist(
    @Body() dto: CreateWishlistDto,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.wishlistService.toggleWishlist(customerId, dto);
    return {
      success: true,
      message: data.message,
      isWishlisted: data.isWishlisted,
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Add product or product variant to customer wishlist' })
  @ApiBody({ type: CreateWishlistDto })
  @ApiResponse({ status: 201, description: 'Product added to wishlist successfully.', type: WishlistResponseDto })
  @ApiResponse({ status: 400, description: 'Validation failed or variant does not belong to product.' })
  @ApiResponse({ status: 404, description: 'Product or variant not found.' })
  async addToWishlist(
    @Body() dto: CreateWishlistDto,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.wishlistService.addToWishlist(customerId, dto);
    return {
      success: true,
      message: 'Product saved to wishlist successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get all wishlist items for logged in customer' })
  @ApiResponse({ status: 200, description: 'Wishlist items retrieved successfully.', type: [WishlistResponseDto] })
  async getWishlist(@CurrentUser('id') customerId: string) {
    const data = await this.wishlistService.getCustomerWishlist(customerId);
    return {
      success: true,
      message: 'Wishlist retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get('check/:productId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Check whether a product or variant is in customer wishlist' })
  @ApiParam({ name: 'productId', description: 'Product ID (UUID)' })
  @ApiQuery({ name: 'productVariantId', description: 'Product Variant ID (UUID)', required: false })
  @ApiResponse({ status: 200, description: 'Wishlist status checked successfully.', type: WishlistCheckResponseDto })
  async checkWishlist(
    @Param('productId') productId: string,
    @Query('productVariantId') productVariantId: string | undefined,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.wishlistService.checkWishlist(customerId, productId, productVariantId);
    return {
      success: true,
      message: 'Wishlist status checked successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':wishlistId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Remove item from customer wishlist' })
  @ApiParam({ name: 'wishlistId', description: 'Wishlist Item ID (UUID)' })
  @ApiResponse({ status: 200, description: 'Wishlist item removed successfully.' })
  @ApiResponse({ status: 403, description: 'Forbidden. Customer does not own wishlist item.' })
  @ApiResponse({ status: 404, description: 'Wishlist item not found.' })
  async removeFromWishlist(
    @Param('wishlistId') wishlistId: string,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.wishlistService.removeFromWishlist(customerId, wishlistId);
    return {
      success: true,
      message: data.message,
      data: null,
      statusCode: HttpStatus.OK,
    };
  }
}
