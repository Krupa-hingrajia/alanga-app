import { Controller, Post, Put, Delete, Get, Query, UseGuards, HttpCode, HttpStatus, ForbiddenException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { SubCategoriesService } from '../services/sub-categories.service';

@ApiTags('Vendor SubCategories')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/sub-categories')
export class VendorSubCategoriesController {
  constructor(private readonly subCategoriesService: SubCategoriesService) {}

  @Post()
  @HttpCode(HttpStatus.FORBIDDEN)
  @ApiOperation({ summary: 'SubCategories are managed only by Admin' })
  async create() {
    throw new ForbiddenException('Sub-categories are managed only by Admin.');
  }

  @Put(':id')
  @HttpCode(HttpStatus.FORBIDDEN)
  @ApiOperation({ summary: 'SubCategories are managed only by Admin' })
  async update() {
    throw new ForbiddenException('Sub-categories are managed only by Admin.');
  }

  @Delete(':id')
  @HttpCode(HttpStatus.FORBIDDEN)
  @ApiOperation({ summary: 'SubCategories are managed only by Admin' })
  async remove() {
    throw new ForbiddenException('Sub-categories are managed only by Admin.');
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of active Admin-created subcategories for product creation' })
  @ApiQuery({ name: 'categoryId', required: false, description: 'Filter by parent Category ID' })
  @ApiResponse({ status: 200, description: 'SubCategories retrieved successfully.' })
  async findAll(@Query('categoryId') categoryId?: string) {
    const data = await this.subCategoriesService.findAllActive(categoryId);
    return {
      success: true,
      message: 'Active subcategories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
