import { Controller, Post, Get, Put, Delete, Body, Param, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { BrandsService } from '../services/brands.service';
import { CreateBrandDto } from '../dto/create-brand.dto';
import { UpdateBrandDto } from '../dto/update-brand.dto';

@ApiTags('Brands')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin/brands')
export class BrandsController {
  constructor(private readonly brandsService: BrandsService) {}

  @Post()
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new brand (Admin only)' })
  @ApiResponse({ status: 201, description: 'Brand successfully created.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  @ApiResponse({ status: 409, description: 'Brand name already exists.' })
  async create(@Body() createBrandDto: CreateBrandDto, @CurrentUser('id') adminId: string) {
    const data = await this.brandsService.create(createBrandDto, adminId);
    return {
      success: true,
      message: 'Brand created successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get()
  @Roles(Role.ADMIN, Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of all brands (Admin and Vendor)' })
  @ApiResponse({ status: 200, description: 'Brands retrieved successfully.' })
  async findAll() {
    const data = await this.brandsService.findAll();
    return {
      success: true,
      message: 'Brands retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':id')
  @Roles(Role.ADMIN, Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get brand by ID (Admin and Vendor)' })
  @ApiResponse({ status: 200, description: 'Brand retrieved successfully.' })
  @ApiResponse({ status: 404, description: 'Brand not found.' })
  async findOne(@Param('id') id: string) {
    const data = await this.brandsService.findOne(id);
    return {
      success: true,
      message: 'Brand retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update brand (Admin only)' })
  @ApiResponse({ status: 200, description: 'Brand successfully updated.' })
  @ApiResponse({ status: 404, description: 'Brand not found.' })
  @ApiResponse({ status: 409, description: 'Brand name already exists.' })
  async update(
    @Param('id') id: string,
    @Body() updateBrandDto: UpdateBrandDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.brandsService.update(id, updateBrandDto, adminId);
    return {
      success: true,
      message: 'Brand updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete brand (Admin only)' })
  @ApiResponse({ status: 200, description: 'Brand successfully deleted.' })
  @ApiResponse({ status: 404, description: 'Brand not found.' })
  async remove(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.brandsService.remove(id, adminId);
    return {
      success: true,
      message: 'Brand deleted successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
