import { Controller, Get, Param, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { OptionalJwtAuthGuard } from '../../auth/guards/optional-jwt-auth.guard';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { ProductsService } from '../services/products.service';

@ApiTags('Customer Products')
@ApiBearerAuth('access-token')
@UseGuards(OptionalJwtAuthGuard)
@Controller('customer/products')
export class CustomerProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of active products for customers (with optional isWishlisted state)' })
  @ApiResponse({ status: 200, description: 'Active products retrieved successfully.' })
  async findAll(@CurrentUser('id') customerId?: string) {
    const data = await this.productsService.findAllActive(customerId);
    return {
      success: true,
      message: 'Products retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get product details for customer (with optional isWishlisted state)' })
  @ApiParam({ name: 'id', description: 'Product ID (UUID)' })
  @ApiResponse({ status: 200, description: 'Product details retrieved successfully.' })
  async findOne(@Param('id') id: string, @CurrentUser('id') customerId?: string) {
    const data = await this.productsService.findOneForCustomer(id, customerId);
    return {
      success: true,
      message: 'Product details retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
