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
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { AddressService } from '../services/address.service';
import { CreateAddressDto } from '../dto/create-address.dto';
import { UpdateAddressDto } from '../dto/update-address.dto';
import {
  AddressResponseDto,
  AddressListResponseDto,
} from '../dto/address-response.dto';

@ApiTags('Customer Addresses')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('CUSTOMER')
@Controller('customer/addresses')
export class CustomerAddressController {
  constructor(private readonly addressService: AddressService) {}

  @Get()
  @ApiOperation({
    summary: 'View Address List',
    description: 'Returns all saved delivery addresses for the authenticated customer. The default address appears first.',
  })
  @ApiResponse({
    status: 200,
    description: 'List of customer addresses retrieved successfully.',
    type: AddressListResponseDto,
  })
  async getAddresses(@CurrentUser('id') customerId: string) {
    const data = await this.addressService.getCustomerAddresses(customerId);
    return {
      success: true,
      message: 'Addresses retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get('default')
  @ApiOperation({
    summary: 'Get Default Address',
    description: 'Returns the customer’s active default shipping address for checkout convenience.',
  })
  @ApiResponse({
    status: 200,
    description: 'Default address retrieved successfully.',
    type: AddressResponseDto,
  })
  async getDefaultAddress(@CurrentUser('id') customerId: string) {
    const data = await this.addressService.getDefaultAddress(customerId);
    return {
      success: true,
      message: data ? 'Default address retrieved successfully' : 'No default address found',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':id')
  @ApiOperation({
    summary: 'View Address Details',
    description: 'Returns details of a specific address owned by the authenticated customer.',
  })
  @ApiParam({ name: 'id', description: 'Address UUID' })
  @ApiResponse({
    status: 200,
    description: 'Address details retrieved successfully.',
    type: AddressResponseDto,
  })
  @ApiResponse({ status: 404, description: 'Address not found or does not belong to customer.' })
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
  @ApiOperation({
    summary: 'Add Address',
    description: 'Creates a new delivery address for the authenticated customer. If this is their first address or marked default, it automatically becomes the default.',
  })
  @ApiBody({ type: CreateAddressDto })
  @ApiResponse({
    status: 201,
    description: 'Address created successfully.',
    type: AddressResponseDto,
  })
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
  @ApiOperation({
    summary: 'Edit Address',
    description: 'Updates an existing delivery address for the authenticated customer.',
  })
  @ApiParam({ name: 'id', description: 'Address UUID' })
  @ApiBody({ type: UpdateAddressDto })
  @ApiResponse({
    status: 200,
    description: 'Address updated successfully.',
    type: AddressResponseDto,
  })
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
  @ApiOperation({
    summary: 'Delete Address',
    description: 'Soft deletes a delivery address. If the deleted address was the default, another address is automatically promoted to default (if available).',
  })
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
      message: data.message,
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/default')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Set Default Address',
    description: 'Marks the specified address as the customer default and automatically unsets default on all other addresses.',
  })
  @ApiParam({ name: 'id', description: 'Address UUID' })
  @ApiResponse({
    status: 200,
    description: 'Default address set successfully.',
    type: AddressResponseDto,
  })
  @ApiResponse({ status: 404, description: 'Address not found.' })
  async setDefaultAddressPut(
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

  @Patch(':id/default')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Set Default Address (PATCH alias)',
    description: 'Alias for PUT /customer/addresses/:id/default.',
  })
  @ApiParam({ name: 'id', description: 'Address UUID' })
  @ApiResponse({
    status: 200,
    description: 'Default address set successfully.',
    type: AddressResponseDto,
  })
  @ApiResponse({ status: 404, description: 'Address not found.' })
  async setDefaultAddressPatch(
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
