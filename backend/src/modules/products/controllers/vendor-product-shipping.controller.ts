import {
  Controller,
  Post,
  Get,
  Put,
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
import { ProductShippingService } from '../services/product-shipping.service';
import { CreateShippingDto } from '../dto/create-shipping.dto';
import { UpdateShippingDto } from '../dto/update-shipping.dto';
import { ShippingResponseDto } from '../dto/shipping-response.dto';

@ApiTags('Vendor Product Shipping')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('vendor/products')
export class VendorProductShippingController {
  constructor(private readonly shippingService: ProductShippingService) {}

  @Post(':productId/shipping')
  @Roles(Role.VENDOR)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create shipping configuration for a product' })
  @ApiParam({ name: 'productId', description: 'Product ID (UUID)' })
  @ApiBody({ type: CreateShippingDto })
  @ApiResponse({ status: 201, description: 'Shipping configuration created successfully.', type: ShippingResponseDto })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  @ApiResponse({ status: 403, description: 'Forbidden. Vendor does not own product.' })
  @ApiResponse({ status: 409, description: 'Shipping configuration already exists.' })
  async createShipping(
    @Param('productId') productId: string,
    @Body() dto: CreateShippingDto,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.shippingService.createShipping(productId, vendorId, dto);
    return {
      success: true,
      message: 'Product shipping configuration created successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get(':productId/shipping')
  @Roles(Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get shipping configuration for a product' })
  @ApiParam({ name: 'productId', description: 'Product ID (UUID)' })
  @ApiResponse({ status: 200, description: 'Shipping configuration retrieved successfully.', type: ShippingResponseDto })
  @ApiResponse({ status: 403, description: 'Forbidden. Vendor does not own product.' })
  @ApiResponse({ status: 404, description: 'Shipping configuration or product not found.' })
  async getShipping(
    @Param('productId') productId: string,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.shippingService.getShipping(productId, vendorId);
    return {
      success: true,
      message: 'Product shipping configuration retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':productId/shipping')
  @Roles(Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update shipping configuration for a product' })
  @ApiParam({ name: 'productId', description: 'Product ID (UUID)' })
  @ApiBody({ type: UpdateShippingDto })
  @ApiResponse({ status: 200, description: 'Shipping configuration updated successfully.', type: ShippingResponseDto })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  @ApiResponse({ status: 403, description: 'Forbidden. Vendor does not own product.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async updateShipping(
    @Param('productId') productId: string,
    @Body() dto: UpdateShippingDto,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.shippingService.updateShipping(productId, vendorId, dto);
    return {
      success: true,
      message: 'Product shipping configuration updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
