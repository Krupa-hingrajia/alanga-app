import { Controller, Get, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { BrandsService } from '../services/brands.service';

@ApiTags('Customer Brands')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard)
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
