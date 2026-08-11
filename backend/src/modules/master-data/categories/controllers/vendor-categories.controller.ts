import { Controller, Post, Put, Get, Body, Param, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { CategoriesService } from '../services/categories.service';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';

@ApiTags('Vendor Categories')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/categories')
export class VendorCategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit a new category for approval (Vendor only)' })
  @ApiResponse({ status: 201, description: 'Category submitted successfully, status: PENDING.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  @ApiResponse({ status: 409, description: 'Category name already exists and is active/pending.' })
  async create(@Body() createCategoryDto: CreateCategoryDto, @CurrentUser('id') vendorId: string) {
    const data = await this.categoriesService.create(createCategoryDto, vendorId);
    return {
      success: true,
      message: 'Category submitted for approval successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Edit owned category (Vendor only). Resets status to PENDING.' })
  @ApiResponse({ status: 200, description: 'Category updated successfully, status reset to PENDING.' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this category.' })
  @ApiResponse({ status: 404, description: 'Category not found.' })
  async update(
    @Param('id') id: string,
    @Body() updateCategoryDto: UpdateCategoryDto,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.categoriesService.updateByVendor(id, updateCategoryDto, vendorId);
    return {
      success: true,
      message: 'Category updated and resubmitted for approval successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of active categories plus vendor\'s own categories' })
  @ApiResponse({ status: 200, description: 'Categories retrieved successfully.' })
  async findAll(@CurrentUser('id') vendorId: string) {
    const data = await this.categoriesService.findVendorCategories(vendorId);
    return {
      success: true,
      message: 'Categories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
