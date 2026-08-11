import { Controller, Get, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { CategoriesService } from '../services/categories.service';

@ApiTags('Customer Categories')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard)
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
