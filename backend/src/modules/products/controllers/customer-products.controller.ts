import { Controller, Get, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { ProductsService } from '../services/products.service';

@ApiTags('Customer Products')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard)
@Controller('customer/products')
export class CustomerProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of active products for customers' })
  @ApiResponse({ status: 200, description: 'Active products retrieved successfully.' })
  async findAll() {
    const data = await this.productsService.findAllActive();
    return {
      success: true,
      message: 'Products retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
