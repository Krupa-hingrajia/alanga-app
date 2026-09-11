import { Controller, Get, Put, Body, Param, Query, UseGuards, HttpCode, HttpStatus, NotFoundException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role, AccountStatus } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { UsersService } from '../services/users.service';

@ApiTags('Admin Customer Management')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller('admin/customers')
export class AdminCustomersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of customers with filters, search, and pagination' })
  @ApiQuery({ name: 'status', required: false, enum: AccountStatus, description: 'Filter by customer status' })
  @ApiQuery({ name: 'search', required: false, description: 'Search by customer name, email, or phone' })
  @ApiQuery({ name: 'page', required: false, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, description: 'Items per page (default: 10)' })
  @ApiResponse({ status: 200, description: 'Customers retrieved successfully.' })
  async getCustomers(
    @Query('status') status?: string,
    @Query('search') search?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const data = await this.usersService.findManyCustomers({
      status,
      search,
      page: page ? parseInt(page, 10) : 1,
      limit: limit ? parseInt(limit, 10) : 10,
    });

    return {
      success: true,
      message: 'Customers retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get detailed information about a customer' })
  @ApiResponse({ status: 200, description: 'Customer details retrieved successfully.' })
  @ApiResponse({ status: 404, description: 'Customer not found.' })
  async getCustomerById(@Param('id') id: string) {
    const customer = await this.usersService.findById(id);
    if (!customer || customer.role !== Role.CUSTOMER) {
      throw new NotFoundException(`Customer with ID "${id}" not found.`);
    }

    return {
      success: true,
      message: 'Customer details retrieved successfully',
      data: customer,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/status')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update customer status' })
  @ApiResponse({ status: 200, description: 'Customer status updated successfully.' })
  async updateStatus(@Param('id') id: string, @Body('status') status: AccountStatus) {
    const customer = await this.usersService.findById(id);
    if (!customer || customer.role !== Role.CUSTOMER) {
      throw new NotFoundException(`Customer with ID "${id}" not found.`);
    }

    const data = await this.usersService.updateStatus(id, status);
    return {
      success: true,
      message: `Customer status updated to ${status} successfully`,
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/suspend')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Suspend customer account' })
  @ApiResponse({ status: 200, description: 'Customer suspended successfully.' })
  async suspendCustomer(@Param('id') id: string) {
    const customer = await this.usersService.findById(id);
    if (!customer || customer.role !== Role.CUSTOMER) {
      throw new NotFoundException(`Customer with ID "${id}" not found.`);
    }

    const data = await this.usersService.updateStatus(id, AccountStatus.SUSPENDED);
    return {
      success: true,
      message: 'Customer suspended successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/activate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Activate customer account' })
  @ApiResponse({ status: 200, description: 'Customer activated successfully.' })
  async activateCustomer(@Param('id') id: string) {
    const customer = await this.usersService.findById(id);
    if (!customer || customer.role !== Role.CUSTOMER) {
      throw new NotFoundException(`Customer with ID "${id}" not found.`);
    }

    const data = await this.usersService.updateStatus(id, AccountStatus.ACTIVE);
    return {
      success: true,
      message: 'Customer activated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
