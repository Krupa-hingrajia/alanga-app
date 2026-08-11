import { Controller, Post, Get, Put, Delete, Body, Param, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { CategoriesService } from '../services/categories.service';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';

@ApiTags('Categories')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin/categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Post()
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new category (Admin only)' })
  @ApiResponse({ status: 201, description: 'Category successfully created.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  @ApiResponse({ status: 409, description: 'Category name already exists.' })
  async create(@Body() createCategoryDto: CreateCategoryDto, @CurrentUser('id') adminId: string) {
    const data = await this.categoriesService.create(createCategoryDto, adminId);
    return {
      success: true,
      message: 'Category created successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get()
  @Roles(Role.ADMIN, Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of all categories (Admin and Vendor)' })
  @ApiResponse({ status: 200, description: 'Categories retrieved successfully.' })
  async findAll() {
    const data = await this.categoriesService.findAll();
    return {
      success: true,
      message: 'Categories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':id')
  @Roles(Role.ADMIN, Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get category by ID (Admin and Vendor)' })
  @ApiResponse({ status: 200, description: 'Category retrieved successfully.' })
  @ApiResponse({ status: 404, description: 'Category not found.' })
  async findOne(@Param('id') id: string) {
    const data = await this.categoriesService.findOne(id);
    return {
      success: true,
      message: 'Category retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update category (Admin only)' })
  @ApiResponse({ status: 200, description: 'Category successfully updated.' })
  @ApiResponse({ status: 404, description: 'Category not found.' })
  @ApiResponse({ status: 409, description: 'Category name already exists.' })
  async update(
    @Param('id') id: string,
    @Body() updateCategoryDto: UpdateCategoryDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.categoriesService.update(id, updateCategoryDto, adminId);
    return {
      success: true,
      message: 'Category updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete category (Admin only)' })
  @ApiResponse({ status: 200, description: 'Category successfully deleted.' })
  @ApiResponse({ status: 404, description: 'Category not found.' })
  async remove(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.categoriesService.remove(id, adminId);
    return {
      success: true,
      message: 'Category deleted successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
