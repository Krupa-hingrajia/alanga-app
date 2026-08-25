import { Controller, Post, Get, Body, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { BrandsService } from '../services/brands.service';
import { RequestBrandDto } from '../dto/request-brand.dto';

@ApiTags('Vendor Brands')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/brands')
export class VendorBrandsController {
  constructor(private readonly brandsService: BrandsService) {}

  @Post('request')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit a new Brand Request for approval (Vendor only)' })
  @ApiResponse({ status: 201, description: 'Brand request submitted successfully, status: PENDING.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  @ApiResponse({ status: 409, description: 'Brand name already exists (case-insensitive).' })
  async requestBrand(@Body() requestBrandDto: RequestBrandDto, @CurrentUser('id') vendorId: string) {
    const data = await this.brandsService.requestBrandByVendor(requestBrandDto, vendorId);
    return {
      success: true,
      message: 'Brand request submitted successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of ACTIVE brands for product creation (Vendor only)' })
  @ApiQuery({ name: 'search', required: false, type: String, description: 'Case-insensitive brand search query' })
  @ApiResponse({ status: 200, description: 'Active brands retrieved successfully.' })
  async findActiveBrands(@Query('search') search?: string) {
    const data = await this.brandsService.findActiveBrandsForVendor(search);
    return {
      success: true,
      message: 'Active brands retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
