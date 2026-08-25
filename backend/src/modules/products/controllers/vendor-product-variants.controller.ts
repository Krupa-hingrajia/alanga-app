import {
  Controller,
  Post,
  Get,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { ProductVariantsService } from '../services/product-variants.service';
import { CreateProductVariantDto } from '../dto/create-product-variant.dto';
import { UpdateProductVariantDto } from '../dto/update-product-variant.dto';
import { ProductVariantResponseDto } from '../dto/product-variant-response.dto';

@ApiTags('Vendor Product Variants')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/products/:productId/variants')
export class VendorProductVariantsController {
  constructor(private readonly productVariantsService: ProductVariantsService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new Product Variant (Vendor only)' })
  @ApiResponse({
    status: 201,
    description: 'Product variant created successfully.',
    type: ProductVariantResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Validation failed (unique SKU required, price >= 0, stock >= 0, name required).' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async createVariant(
    @Param('productId') productId: string,
    @Body() dto: CreateProductVariantDto,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.productVariantsService.createVariant(productId, vendorId, dto);
    return {
      success: true,
      message: 'Product variant created successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get all Product Variants for a product (Vendor only)' })
  @ApiResponse({
    status: 200,
    description: 'Product variants retrieved successfully.',
    type: [ProductVariantResponseDto],
  })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async getVariants(
    @Param('productId') productId: string,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.productVariantsService.getVariantsByProductId(productId, vendorId);
    return {
      success: true,
      message: 'Product variants retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':variantId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update an existing Product Variant (Vendor only)' })
  @ApiResponse({
    status: 200,
    description: 'Product variant updated successfully.',
    type: ProductVariantResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Validation failed (unique SKU required, price >= 0, stock >= 0).' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product or variant not found.' })
  async updateVariant(
    @Param('productId') productId: string,
    @Param('variantId') variantId: string,
    @Body() dto: UpdateProductVariantDto,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.productVariantsService.updateVariant(
      productId,
      variantId,
      vendorId,
      dto,
    );
    return {
      success: true,
      message: 'Product variant updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':variantId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete a Product Variant (Vendor only)' })
  @ApiResponse({ status: 200, description: 'Product variant deleted successfully.' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product or variant not found.' })
  async deleteVariant(
    @Param('productId') productId: string,
    @Param('variantId') variantId: string,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.productVariantsService.deleteVariant(
      productId,
      variantId,
      vendorId,
    );
    return {
      success: true,
      message: data.message,
      statusCode: HttpStatus.OK,
    };
  }
}
