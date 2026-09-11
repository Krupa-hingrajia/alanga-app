import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Patch,
  Body,
  Param,
  UseGuards,
  HttpStatus,
  HttpCode,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { AddressService } from '../services/address.service';
import { CreateAddressDto } from '../dto/create-address.dto';
import { UpdateAddressDto } from '../dto/update-address.dto';

@ApiTags('Customer Addresses')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('CUSTOMER')
@Controller('customer/addresses')
export class CustomerAddressController {
  constructor(private readonly addressService: AddressService) {}

  @Get()
  @ApiOperation({ summary: 'Get all saved addresses for customer' })
  @ApiResponse({ status: 200, description: 'List of customer addresses retrieved successfully.' })
  async getAddresses(@CurrentUser('id') customerId: string) {
    const data = await this.addressService.getCustomerAddresses(customerId);
    return {
      success: true,
      message: 'Addresses retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get address by ID' })
  @ApiParam({ name: 'id', description: 'Address UUID' })
  @ApiResponse({ status: 200, description: 'Address details retrieved successfully.' })
  @ApiResponse({ status: 404, description: 'Address not found.' })
  async getAddressById(
    @Param('id') id: string,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.addressService.getAddressById(customerId, id);
    return {
      success: true,
      message: 'Address retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Post()
  @ApiOperation({ summary: 'Add a new shipping address' })
  @ApiResponse({ status: 201, description: 'Address created successfully.' })
  async createAddress(
    @Body() dto: CreateAddressDto,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.addressService.createAddress(customerId, dto);
    return {
      success: true,
      message: 'Address created successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update an existing address' })
  @ApiParam({ name: 'id', description: 'Address UUID' })
  @ApiResponse({ status: 200, description: 'Address updated successfully.' })
  @ApiResponse({ status: 404, description: 'Address not found.' })
  async updateAddress(
    @Param('id') id: string,
    @Body() dto: UpdateAddressDto,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.addressService.updateAddress(customerId, id, dto);
    return {
      success: true,
      message: 'Address updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete an address' })
  @ApiParam({ name: 'id', description: 'Address UUID' })
  @ApiResponse({ status: 200, description: 'Address deleted successfully.' })
  @ApiResponse({ status: 404, description: 'Address not found.' })
  async deleteAddress(
    @Param('id') id: string,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.addressService.deleteAddress(customerId, id);
    return {
      success: true,
      message: 'Address deleted successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Patch(':id/default')
  @ApiOperation({ summary: 'Set an address as default' })
  @ApiParam({ name: 'id', description: 'Address UUID' })
  @ApiResponse({ status: 200, description: 'Default address updated successfully.' })
  @ApiResponse({ status: 404, description: 'Address not found.' })
  async setDefaultAddress(
    @Param('id') id: string,
    @CurrentUser('id') customerId: string,
  ) {
    const data = await this.addressService.setDefaultAddress(customerId, id);
    return {
      success: true,
      message: 'Default address updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
