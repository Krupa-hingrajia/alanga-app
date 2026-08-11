import { Controller, Post, Put, Get, Body, Param, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { BrandsService } from '../services/brands.service';
import { CreateBrandDto } from '../dto/create-brand.dto';
import { UpdateBrandDto } from '../dto/update-brand.dto';

@ApiTags('Vendor Brands')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/brands')
export class VendorBrandsController {
  constructor(private readonly brandsService: BrandsService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit a new brand for approval (Vendor only)' })
  @ApiResponse({ status: 201, description: 'Brand submitted successfully, status: PENDING.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  @ApiResponse({ status: 409, description: 'Brand name already exists and is active/pending.' })
  async create(@Body() createBrandDto: CreateBrandDto, @CurrentUser('id') vendorId: string) {
    const data = await this.brandsService.create(createBrandDto, vendorId);
    return {
      success: true,
      message: 'Brand submitted for approval successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Edit owned brand (Vendor only). Resets status to PENDING.' })
  @ApiResponse({ status: 200, description: 'Brand updated successfully, status reset to PENDING.' })
  @ApiResponse({ status: 403, description: 'Forbidden. You do not own this brand.' })
  @ApiResponse({ status: 404, description: 'Brand not found.' })
  async update(
    @Param('id') id: string,
    @Body() updateBrandDto: UpdateBrandDto,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.brandsService.updateByVendor(id, updateBrandDto, vendorId);
    return {
      success: true,
      message: 'Brand updated and resubmitted for approval successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of active brands plus vendor\'s own brands' })
  @ApiResponse({ status: 200, description: 'Brands retrieved successfully.' })
  async findAll(@CurrentUser('id') vendorId: string) {
    const data = await this.brandsService.findVendorBrands(vendorId);
    return {
      success: true,
      message: 'Brands retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
