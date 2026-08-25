import { Controller, Get, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { BrandsService } from '../services/brands.service';

@ApiTags('Customer Brands')
@Controller('customer/brands')
export class CustomerBrandsController {
  constructor(private readonly brandsService: BrandsService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of active brands for customers' })
  @ApiResponse({ status: 200, description: 'Active brands retrieved successfully.' })
  async findAll() {
    const data = await this.brandsService.findAllActive();
    return {
      success: true,
      message: 'Brands retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
