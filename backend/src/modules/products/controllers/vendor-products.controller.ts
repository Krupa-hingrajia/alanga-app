import { Controller, Post, Put, Get, Body, Param, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { ProductsService } from '../services/products.service';
import { CreateProductDto } from '../dto/create-product.dto';
import { UpdateProductDto } from '../dto/update-product.dto';

@ApiTags('Vendor Products')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/products')
export class VendorProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit a new product for approval (Vendor only)' })
  @ApiResponse({ status: 201, description: 'Product submitted successfully, status: PENDING.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  async create(@Body() createProductDto: CreateProductDto, @CurrentUser('id') vendorId: string) {
    const data = await this.productsService.create(createProductDto, vendorId);
    return {
      success: true,
      message: 'Product submitted for approval successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Edit owned product (Vendor only). Resets status to PENDING.' })
  @ApiResponse({ status: 200, description: 'Product updated successfully, status reset to PENDING.' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async update(
    @Param('id') id: string,
    @Body() updateProductDto: UpdateProductDto,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.productsService.updateByVendor(id, updateProductDto, vendorId);
    return {
      success: true,
      message: 'Product updated and resubmitted for approval successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of vendor\'s own products' })
  @ApiResponse({ status: 200, description: 'Vendor products retrieved successfully.' })
  async findAll(@CurrentUser('id') vendorId: string) {
    const data = await this.productsService.findVendorProducts(vendorId);
    return {
      success: true,
      message: 'Products retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
