import { Controller, Get, Put, Param, Body, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { ProductsService } from '../services/products.service';
import { RejectDto } from '../../master-data/categories/dto/reject.dto';
import { AdminProductFilterDto } from '../dto/admin-product-filter.dto';
import { NotificationsService } from '../../notifications/notifications.service';

@ApiTags('Admin Products Approval & Management')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller('admin/products')
export class AdminProductsController {
  constructor(
    private readonly productsService: ProductsService,
    private readonly notificationsService: NotificationsService,
  ) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get all marketplace products with filters, search, sorting, and pagination' })
  @ApiResponse({ status: 200, description: 'Products retrieved successfully.' })
  async getProducts(@Query() filterDto: AdminProductFilterDto) {
    const data = await this.productsService.findForAdmin(filterDto);
    return {
      success: true,
      message: 'Admin products retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

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

    // Send push & in-app notification to the product's vendor
    if (data?.vendorId) {
      await this.notificationsService.sendNotificationToUser(
        data.vendorId,
        '🎉 Product Approved!',
        `Your product "${data.name}" has been approved and is now live on the store.`,
        'PRODUCT_APPROVAL',
        { productId: data.id },
      );
    }

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

    // Send push & in-app notification to the product's vendor
    if (data?.vendorId) {
      const reasonSuffix = rejectDto.reason ? ` Reason: ${rejectDto.reason}` : '';
      await this.notificationsService.sendNotificationToUser(
        data.vendorId,
        '⚠️ Product Rejected',
        `Your product "${data.name}" was not approved.${reasonSuffix}`,
        'PRODUCT_REJECTION',
        { productId: data.id, reason: rejectDto.reason },
      );
    }

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
