import { Controller, Get, Put, Param, Query, UseGuards, HttpCode, HttpStatus, NotFoundException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role, AccountStatus } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { UsersService } from '../services/users.service';

@ApiTags('Admin Vendor Management')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller('admin/vendors')
export class AdminUsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of vendors with filters, search, and pagination' })
  @ApiQuery({ name: 'status', required: false, enum: AccountStatus, description: 'Filter by vendor status' })
  @ApiQuery({ name: 'search', required: false, description: 'Search by vendor name or email' })
  @ApiQuery({ name: 'page', required: false, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, description: 'Items per page (default: 10)' })
  @ApiResponse({ status: 200, description: 'Vendors retrieved successfully.' })
  async getVendors(
    @Query('status') status?: string,
    @Query('search') search?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.usersService.findManyVendors({
      status,
      search,
      page: page ? parseInt(page, 10) : 1,
      limit: limit ? parseInt(limit, 10) : 10,
    });

    return {
      success: true,
      message: 'Vendors retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get detailed information about a vendor' })
  @ApiResponse({ status: 200, description: 'Vendor details retrieved successfully.' })
  @ApiResponse({ status: 404, description: 'Vendor not found.' })
  async getVendorById(@Param('id') id: string) {
    const vendor = await this.usersService.findById(id);
    if (!vendor || vendor.role !== Role.VENDOR) {
      throw new NotFoundException(`Vendor with ID "${id}" not found.`);
    }

    return {
      success: true,
      message: 'Vendor details retrieved successfully',
      data: vendor,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve vendor registration request' })
  @ApiResponse({ status: 200, description: 'Vendor approved successfully.' })
  @ApiResponse({ status: 404, description: 'Vendor not found.' })
  async approveVendor(@Param('id') id: string) {
    const vendor = await this.usersService.findById(id);
    if (!vendor || vendor.role !== Role.VENDOR) {
      throw new NotFoundException(`Vendor with ID "${id}" not found.`);
    }

    const data = await this.usersService.updateStatus(id, AccountStatus.ACTIVE);
    return {
      success: true,
      message: 'Vendor approved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject vendor registration request' })
  @ApiResponse({ status: 200, description: 'Vendor rejected successfully.' })
  @ApiResponse({ status: 404, description: 'Vendor not found.' })
  async rejectVendor(@Param('id') id: string) {
    const vendor = await this.usersService.findById(id);
    if (!vendor || vendor.role !== Role.VENDOR) {
      throw new NotFoundException(`Vendor with ID "${id}" not found.`);
    }

    const data = await this.usersService.updateStatus(id, AccountStatus.REJECTED);
    return {
      success: true,
      message: 'Vendor rejected successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/suspend')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Suspend active vendor account' })
  @ApiResponse({ status: 200, description: 'Vendor suspended successfully.' })
  @ApiResponse({ status: 404, description: 'Vendor not found.' })
  async suspendVendor(@Param('id') id: string) {
    const vendor = await this.usersService.findById(id);
    if (!vendor || vendor.role !== Role.VENDOR) {
      throw new NotFoundException(`Vendor with ID "${id}" not found.`);
    }

    const data = await this.usersService.updateStatus(id, AccountStatus.SUSPENDED);
    return {
      success: true,
      message: 'Vendor suspended successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
