import { Controller, Get, Put, Delete, Param, Body, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { BrandsService } from '../services/brands.service';
import { RejectDto } from '../../categories/dto/reject.dto';

@ApiTags('Admin Brands Approval')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller('admin/brands')
export class BrandsController {
  constructor(private readonly brandsService: BrandsService) {}

  @Get('pending')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of pending brands' })
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

  @Put(':id/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve a pending brand' })
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
  @ApiOperation({ summary: 'Reject a pending brand' })
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
