import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { BrandsService } from '../services/brands.service';
import { CreateBrandDto } from '../dto/create-brand.dto';
import { UpdateBrandDto } from '../dto/update-brand.dto';
import { RejectDto } from '../../categories/dto/reject.dto';
import { AdminBrandFilterDto } from '../dto/admin-brand-filter.dto';

@ApiTags('Admin Brands Approval & Management')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller('admin/brands')
export class BrandsController {
  constructor(private readonly brandsService: BrandsService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get all marketplace brands with filters, search, and pagination' })
  @ApiResponse({ status: 200, description: 'Brands retrieved successfully.' })
  async getBrands(@Query() filterDto: AdminBrandFilterDto) {
    const data = await this.brandsService.findForAdmin(filterDto);
    return {
      success: true,
      message: 'Admin brands retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get('pending')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of pending brand requests' })
  @ApiResponse({ status: 200, description: 'Pending brands retrieved successfully.' })
  async getPending() {
    const data = await this.brandsService.findAllPending();
    return {
      success: true,
      message: 'Pending brands retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create an ACTIVE brand directly (Admin only)' })
  @ApiResponse({ status: 201, description: 'Brand created successfully.' })
  @ApiResponse({ status: 409, description: 'Brand name already exists (case-insensitive).' })
  async create(@Body() createBrandDto: CreateBrandDto, @CurrentUser('id') adminId: string) {
    const data = await this.brandsService.createAdminBrand(createBrandDto, adminId);
    return {
      success: true,
      message: 'Brand created successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update brand details or status (Admin only)' })
  @ApiResponse({ status: 200, description: 'Brand updated successfully.' })
  @ApiResponse({ status: 404, description: 'Brand not found.' })
  async update(
    @Param('id') id: string,
    @Body() updateBrandDto: UpdateBrandDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.brandsService.updateAdminBrand(id, updateBrandDto, adminId);
    return {
      success: true,
      message: 'Brand updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve a pending vendor brand request' })
  @ApiResponse({ status: 200, description: 'Brand approved successfully.' })
  @ApiResponse({ status: 404, description: 'Brand not found.' })
  async approve(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.brandsService.approve(id, adminId);
    return {
      success: true,
      message: 'Brand approved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject a pending vendor brand request' })
  @ApiResponse({ status: 200, description: 'Brand rejected successfully.' })
  @ApiResponse({ status: 404, description: 'Brand not found.' })
  async reject(
    @Param('id') id: string,
    @Body() rejectDto: RejectDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.brandsService.reject(id, adminId, rejectDto.reason);
    return {
      success: true,
      message: 'Brand rejected successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete brand' })
  @ApiResponse({ status: 200, description: 'Brand successfully deleted.' })
  @ApiResponse({ status: 404, description: 'Brand not found.' })
  @ApiResponse({ status: 409, description: 'This brand cannot be deleted because it is being used by one or more products.' })
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
