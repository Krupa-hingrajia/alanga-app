import { Controller, Get, Put, Param, Body, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { ProductsService } from '../services/products.service';
import { RejectDto } from '../../master-data/categories/dto/reject.dto';

@ApiTags('Admin Products Approval')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller('admin/products')
export class AdminProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Get('pending')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of pending products awaiting administrative approval' })
  @ApiResponse({ status: 200, description: 'Pending products retrieved successfully.' })
  async getPending() {
    const data = await this.productsService.findAllPending();
    return {
      success: true,
      message: 'Pending products retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve a pending product' })
  @ApiResponse({ status: 200, description: 'Product approved successfully.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async approve(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.productsService.approve(id, adminId);
    return {
      success: true,
      message: 'Product approved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject a pending product' })
  @ApiResponse({ status: 200, description: 'Product rejected successfully.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async reject(
    @Param('id') id: string,
    @Body() rejectDto: RejectDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.productsService.reject(id, adminId, rejectDto.reason);
    return {
      success: true,
      message: 'Product rejected successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/suspend')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Suspend an active product' })
  @ApiResponse({ status: 200, description: 'Product suspended successfully.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async suspend(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.productsService.suspend(id, adminId);
    return {
      success: true,
      message: 'Product suspended successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
