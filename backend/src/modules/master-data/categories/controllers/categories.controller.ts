import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { CategoriesService } from '../services/categories.service';
import { RejectDto } from '../dto/reject.dto';
import { AdminCategoryFilterDto } from '../dto/admin-category-filter.dto';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';

@ApiTags('Admin Categories Approval & Management')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller('admin/categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new category (Admin only)' })
  @ApiResponse({ status: 201, description: 'Category created successfully.' })
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

  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update category (Admin only)' })
  @ApiResponse({ status: 200, description: 'Category updated successfully.' })
  @ApiResponse({ status: 404, description: 'Category not found.' })
  async update(
    @Param('id') id: string,
    @Body() updateCategoryDto: UpdateCategoryDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.categoriesService.updateByVendor(id, updateCategoryDto, adminId);
    return {
      success: true,
      message: 'Category updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get all marketplace categories with filters, search, and pagination' })
  @ApiResponse({ status: 200, description: 'Categories retrieved successfully.' })
  async getCategories(@Query() filterDto: AdminCategoryFilterDto) {
    const data = await this.categoriesService.findForAdmin(filterDto);
    return {
      success: true,
      message: 'Admin categories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get('pending')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of pending categories' })
  @ApiResponse({ status: 200, description: 'Pending categories retrieved successfully.' })
  async getPending() {
    const data = await this.categoriesService.findAllPending();
    return {
      success: true,
      message: 'Pending categories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }


  @Put(':id/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve a pending category' })
  @ApiResponse({ status: 200, description: 'Category approved successfully.' })
  @ApiResponse({ status: 404, description: 'Category not found.' })
  async approve(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.categoriesService.approve(id, adminId);
    return {
      success: true,
      message: 'Category approved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject a pending category' })
  @ApiResponse({ status: 200, description: 'Category rejected successfully.' })
  @ApiResponse({ status: 404, description: 'Category not found.' })
  async reject(
    @Param('id') id: string,
    @Body() rejectDto: RejectDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.categoriesService.reject(id, adminId, rejectDto.reason);
    return {
      success: true,
      message: 'Category rejected successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete category' })
  @ApiResponse({ status: 200, description: 'Category successfully deleted.' })
  @ApiResponse({ status: 404, description: 'Category not found.' })
  @ApiResponse({ status: 409, description: 'This category cannot be deleted because it contains sub-categories. Please delete all sub-categories first.' })
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
