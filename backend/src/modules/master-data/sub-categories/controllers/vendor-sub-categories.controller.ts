import { Controller, Post, Put, Get, Body, Param, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { SubCategoriesService } from '../services/sub-categories.service';
import { CreateSubCategoryDto } from '../dto/create-sub-category.dto';
import { UpdateSubCategoryDto } from '../dto/update-sub-category.dto';

@ApiTags('Vendor SubCategories')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/sub-categories')
export class VendorSubCategoriesController {
  constructor(private readonly subCategoriesService: SubCategoriesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit a new subcategory for approval (Vendor only)' })
  @ApiResponse({ status: 201, description: 'SubCategory submitted successfully, status: PENDING.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  @ApiResponse({ status: 404, description: 'Parent Category not found.' })
  @ApiResponse({ status: 409, description: 'SubCategory name already exists in this category.' })
  async create(@Body() createSubCategoryDto: CreateSubCategoryDto, @CurrentUser('id') vendorId: string) {
    const data = await this.subCategoriesService.create(createSubCategoryDto, vendorId);
    return {
      success: true,
      message: 'SubCategory submitted for approval successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Edit owned subcategory (Vendor only). Resets status to PENDING.' })
  @ApiResponse({ status: 200, description: 'SubCategory updated successfully, status reset to PENDING.' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this subcategory.' })
  @ApiResponse({ status: 404, description: 'SubCategory or parent Category not found.' })
  async update(
    @Param('id') id: string,
    @Body() updateSubCategoryDto: UpdateSubCategoryDto,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.subCategoriesService.updateByVendor(id, updateSubCategoryDto, vendorId);
    return {
      success: true,
      message: 'SubCategory updated and resubmitted for approval successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of active subcategories plus vendor\'s own subcategories' })
  @ApiQuery({ name: 'categoryId', required: false, description: 'Filter by parent Category ID' })
  @ApiResponse({ status: 200, description: 'SubCategories retrieved successfully.' })
  async findAll(@CurrentUser('id') vendorId: string, @Query('categoryId') categoryId?: string) {
    const data = await this.subCategoriesService.findVendorSubCategories(vendorId, categoryId);
    return {
      success: true,
      message: 'SubCategories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
