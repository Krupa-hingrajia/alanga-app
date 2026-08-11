import { Controller, Post, Put, Get, Delete, Body, Param, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
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
  @ApiOperation({ summary: 'Create a new product (Vendor only, defaults status to DRAFT)' })
  @ApiResponse({ status: 201, description: 'Product created successfully.' })
  @ApiResponse({ status: 400, description: 'Validation failed (MRP must be > 0, Selling Price <= MRP).' })
  async create(@Body() createProductDto: CreateProductDto, @CurrentUser('id') vendorId: string) {
    const data = await this.productsService.create(createProductDto, vendorId);
    return {
      success: true,
      message: 'Product created successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get all products owned by current vendor' })
  @ApiResponse({ status: 200, description: 'Products retrieved successfully.' })
  async findAll(@CurrentUser('id') vendorId: string) {
    const data = await this.productsService.findVendorProducts(vendorId);
    return {
      success: true,
      message: 'Products retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get details of owned product' })
  @ApiResponse({ status: 200, description: 'Product details retrieved successfully.' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async findOne(@Param('id') id: string, @CurrentUser('id') vendorId: string) {
    const data = await this.productsService.findOneByVendor(id, vendorId);
    return {
      success: true,
      message: 'Product details retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update owned product (resets status to DRAFT)' })
  @ApiResponse({ status: 200, description: 'Product updated successfully.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
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
      message: 'Product updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete owned product' })
  @ApiResponse({ status: 200, description: 'Product successfully deleted.' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async remove(@Param('id') id: string, @CurrentUser('id') vendorId: string) {
    const data = await this.productsService.removeByVendor(id, vendorId);
    return {
      success: true,
      message: 'Product deleted successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Post(':id/submit')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Submit product for approval (changes status to PENDING)' })
  @ApiResponse({ status: 200, description: 'Product submitted for approval successfully.' })
  @ApiResponse({ status: 400, description: 'Product is not in DRAFT or REJECTED status.' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this product.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async submit(@Param('id') id: string, @CurrentUser('id') vendorId: string) {
    const data = await this.productsService.submitForApproval(id, vendorId);
    return {
      success: true,
      message: 'Product submitted for approval successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
