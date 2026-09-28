import {
  Controller,
  Get,
  Put,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { VendorProfileService } from '../services/vendor-profile.service';
import { UpdateVendorProfileDto } from '../dto/update-vendor-profile.dto';

@ApiTags('Vendor Profile & KYC')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/profile')
export class VendorProfileController {
  constructor(private readonly profileService: VendorProfileService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get vendor store profile, KYC, warehouse address and bank details' })
  @ApiResponse({ status: 200, description: 'Vendor profile retrieved successfully.' })
  @ApiResponse({ status: 401, description: 'Unauthorized.' })
  @ApiResponse({ status: 403, description: 'Forbidden. Vendor role required.' })
  async getProfile(@CurrentUser('id') vendorId: string) {
    const data = await this.profileService.getProfile(vendorId);
    return {
      success: true,
      message: 'Vendor profile retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update vendor store profile, KYC, pickup address, bank details and signature' })
  @ApiResponse({ status: 200, description: 'Vendor profile updated successfully.' })
  @ApiResponse({ status: 401, description: 'Unauthorized.' })
  @ApiResponse({ status: 403, description: 'Forbidden. Vendor role required.' })
  async updateProfile(
    @CurrentUser('id') vendorId: string,
    @Body() dto: UpdateVendorProfileDto,
  ) {
    const data = await this.profileService.updateProfile(vendorId, dto);
    return {
      success: true,
      message: 'Vendor profile updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
