import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { SubCategoriesService } from '../services/sub-categories.service';
import { RejectDto } from '../../categories/dto/reject.dto';
import { AdminSubCategoryFilterDto } from '../dto/admin-sub-category-filter.dto';
import { CreateSubCategoryDto } from '../dto/create-sub-category.dto';
import { UpdateSubCategoryDto } from '../dto/update-sub-category.dto';

@ApiTags('Admin SubCategories Approval & Management')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller(['admin/subcategories', 'admin/sub-categories'])
export class SubCategoriesController {
  constructor(private readonly subCategoriesService: SubCategoriesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new subcategory (Admin only)' })
  @ApiResponse({ status: 201, description: 'SubCategory created successfully.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
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

  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update subcategory (Admin only)' })
  @ApiResponse({ status: 200, description: 'SubCategory updated successfully.' })
  @ApiResponse({ status: 404, description: 'SubCategory not found.' })
  async update(
    @Param('id') id: string,
    @Body() updateSubCategoryDto: UpdateSubCategoryDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.subCategoriesService.updateByVendor(id, updateSubCategoryDto, adminId);
    return {
      success: true,
      message: 'SubCategory updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get all marketplace subcategories with filters, search, and pagination' })
  @ApiResponse({ status: 200, description: 'SubCategories retrieved successfully.' })
  async getSubCategories(@Query() filterDto: AdminSubCategoryFilterDto) {
    const data = await this.subCategoriesService.findForAdmin(filterDto);
    return {
      success: true,
      message: 'Admin subcategories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get('pending')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of pending subcategories' })
  @ApiQuery({ name: 'categoryId', required: false, description: 'Filter by parent Category ID' })
  @ApiResponse({ status: 200, description: 'Pending subcategories retrieved successfully.' })
  async getPending(@Query('categoryId') categoryId?: string) {
    const data = await this.subCategoriesService.findAllPending(categoryId);
    return {
      success: true,
      message: 'Pending subcategories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }


  @Put(':id/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve a pending subcategory' })
  @ApiResponse({ status: 200, description: 'SubCategory approved successfully.' })
  @ApiResponse({ status: 404, description: 'SubCategory not found.' })
  async approve(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.subCategoriesService.approve(id, adminId);
    return {
      success: true,
      message: 'SubCategory approved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject a pending subcategory' })
  @ApiResponse({ status: 200, description: 'SubCategory rejected successfully.' })
  @ApiResponse({ status: 404, description: 'SubCategory not found.' })
  async reject(
    @Param('id') id: string,
    @Body() rejectDto: RejectDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.subCategoriesService.reject(id, adminId, rejectDto.reason);
    return {
      success: true,
      message: 'SubCategory rejected successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete subcategory' })
  @ApiResponse({ status: 200, description: 'SubCategory successfully deleted.' })
  @ApiResponse({ status: 404, description: 'SubCategory not found.' })
  @ApiResponse({ status: 409, description: 'This sub-category cannot be deleted because it contains products. Please delete all products first.' })
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
