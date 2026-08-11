import { Controller, Post, Get, Put, Delete, Body, Param, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { SubCategoriesService } from '../services/sub-categories.service';
import { CreateSubCategoryDto } from '../dto/create-sub-category.dto';
import { UpdateSubCategoryDto } from '../dto/update-sub-category.dto';

@ApiTags('SubCategories')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin/sub-categories')
export class SubCategoriesController {
  constructor(private readonly subCategoriesService: SubCategoriesService) {}

  @Post()
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new subcategory (Admin only)' })
  @ApiResponse({ status: 201, description: 'SubCategory successfully created.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  @ApiResponse({ status: 404, description: 'Category not found.' })
  @ApiResponse({ status: 409, description: 'SubCategory name already exists in this category.' })
  async create(@Body() createSubCategoryDto: CreateSubCategoryDto, @CurrentUser('id') adminId: string) {
    const data = await this.subCategoriesService.create(createSubCategoryDto, adminId);
    return {
      success: true,
      message: 'SubCategory created successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get()
  @Roles(Role.ADMIN, Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of subcategories (Admin and Vendor)' })
  @ApiQuery({ name: 'categoryId', required: false, description: 'Filter by Category ID (UUID)' })
  @ApiResponse({ status: 200, description: 'SubCategories retrieved successfully.' })
  async findAll(@Query('categoryId') categoryId?: string) {
    const data = await this.subCategoriesService.findAll(categoryId);
    return {
      success: true,
      message: 'SubCategories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':id')
  @Roles(Role.ADMIN, Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get subcategory by ID (Admin and Vendor)' })
  @ApiResponse({ status: 200, description: 'SubCategory retrieved successfully.' })
  @ApiResponse({ status: 404, description: 'SubCategory not found.' })
  async findOne(@Param('id') id: string) {
    const data = await this.subCategoriesService.findOne(id);
    return {
      success: true,
      message: 'SubCategory retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update subcategory (Admin only)' })
  @ApiResponse({ status: 200, description: 'SubCategory successfully updated.' })
  @ApiResponse({ status: 404, description: 'SubCategory or Category not found.' })
  @ApiResponse({ status: 409, description: 'SubCategory name already exists in this category.' })
  async update(
    @Param('id') id: string,
    @Body() updateSubCategoryDto: UpdateSubCategoryDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.subCategoriesService.update(id, updateSubCategoryDto, adminId);
    return {
      success: true,
      message: 'SubCategory updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete subcategory (Admin only)' })
  @ApiResponse({ status: 200, description: 'SubCategory successfully deleted.' })
  @ApiResponse({ status: 404, description: 'SubCategory not found.' })
  async remove(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.subCategoriesService.remove(id, adminId);
    return {
      success: true,
      message: 'SubCategory deleted successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
