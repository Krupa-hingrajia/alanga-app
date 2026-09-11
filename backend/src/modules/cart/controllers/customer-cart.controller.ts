import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody, ApiParam } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { CartService } from '../services/cart.service';
import { AddToCartDto } from '../dto/add-to-cart.dto';
import { UpdateCartItemDto } from '../dto/update-cart-item.dto';
import { CartFullResponseDto } from '../dto/cart-response.dto';

@ApiTags('Customer Shopping Cart')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.CUSTOMER)
@Controller('customer/cart')
export class CustomerCartController {
  constructor(private readonly cartService: CartService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get Customer Shopping Cart with item details, image hierarchy, and summary calculations' })
  @ApiResponse({ status: 200, description: 'Cart retrieved successfully.', type: CartFullResponseDto })
  async getCart(@CurrentUser('id') customerId: string) {
    const data = await this.cartService.getCart(customerId);
    return {
      success: true,
      message: 'Cart retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Post()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Add product variant to customer shopping cart (Increases quantity if duplicate)' })
  @ApiBody({ type: AddToCartDto })
  @ApiResponse({ status: 200, description: 'Product variant added to cart successfully.', type: CartFullResponseDto })
  @ApiResponse({ status: 400, description: 'Validation failed or stock limit exceeded.' })
  @ApiResponse({ status: 404, description: 'Product or variant not found.' })
  async addToCart(
    @Body() dto: AddToCartDto,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.cartService.addToCart(customerId, dto);
    return {
      success: true,
      message: 'Product variant added to cart successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':cartItemId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update cart item quantity or increase/decrease' })
  @ApiParam({ name: 'cartItemId', description: 'ID of the cart item' })
  @ApiBody({ type: UpdateCartItemDto })
  @ApiResponse({ status: 200, description: 'Cart item quantity updated successfully.', type: CartFullResponseDto })
  @ApiResponse({ status: 400, description: 'Stock limit exceeded or invalid quantity.' })
  @ApiResponse({ status: 404, description: 'Cart item not found.' })
  async updateQuantity(
    @Param('cartItemId') cartItemId: string,
    @Body() dto: UpdateCartItemDto,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.cartService.updateQuantity(customerId, cartItemId, dto);
    return {
      success: true,
      message: 'Cart item quantity updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':cartItemId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Remove a specific item from cart' })
  @ApiParam({ name: 'cartItemId', description: 'ID of the cart item to remove' })
  @ApiResponse({ status: 200, description: 'Cart item removed successfully.', type: CartFullResponseDto })
  @ApiResponse({ status: 404, description: 'Cart item not found.' })
  async removeItem(
    @Param('cartItemId') cartItemId: string,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.cartService.removeItem(customerId, cartItemId);
    return {
      success: true,
      message: 'Item removed from cart successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Clear all items from customer shopping cart' })
  @ApiResponse({ status: 200, description: 'Cart cleared successfully.', type: CartFullResponseDto })
  async clearCart(@CurrentUser('id') customerId: string) {
    const data = await this.cartService.clearCart(customerId);
    return {
      success: true,
      message: 'Cart cleared successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
