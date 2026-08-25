import { Controller, Get, Query, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { SubCategoriesService } from '../services/sub-categories.service';

@ApiTags('Customer SubCategories')
@Controller('customer/sub-categories')
export class CustomerSubCategoriesController {
  constructor(private readonly subCategoriesService: SubCategoriesService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of active subcategories for customers' })
  @ApiQuery({ name: 'categoryId', required: false, description: 'Filter by parent Category ID' })
  @ApiResponse({ status: 200, description: 'Active subcategories retrieved successfully.' })
  async findAll(@Query('categoryId') categoryId?: string) {
    const data = await this.subCategoriesService.findAllActive(categoryId);
    return {
      success: true,
      message: 'SubCategories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
