import { Controller, Get, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { CategoriesService } from '../services/categories.service';

@ApiTags('Customer Categories')
@Controller('customer/categories')
export class CustomerCategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of active categories for customers' })
  @ApiResponse({ status: 200, description: 'Active categories retrieved successfully.' })
  async findAll() {
    const data = await this.categoriesService.findAllActive();
    return {
      success: true,
      message: 'Categories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
