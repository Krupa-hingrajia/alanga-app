import { Controller, Get, Put, Delete, Param, Body, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { SubCategoriesService } from '../services/sub-categories.service';
import { RejectDto } from '../../categories/dto/reject.dto';

@ApiTags('Admin SubCategories Approval')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller('admin/sub-categories')
export class SubCategoriesController {
  constructor(private readonly subCategoriesService: SubCategoriesService) {}

  @Get('pending')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of pending subcategories' })
  @ApiQuery({ name: 'categoryId', required: false, description: 'Filter by parent Category ID' })
  @ApiResponse({ status: 200, description: 'Pending subcategories retrieved successfully.' })
  async getPending(@Query('categoryId') categoryId?: string) {
    const data = await this.subCategoriesService.findAllPending(categoryId);
    return {
      success: true,
      message: 'Pending subcategories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve a pending subcategory' })
  @ApiResponse({ status: 200, description: 'SubCategory approved successfully.' })
  @ApiResponse({ status: 404, description: 'SubCategory not found.' })
  async approve(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.subCategoriesService.approve(id, adminId);
    return {
      success: true,
      message: 'SubCategory approved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject a pending subcategory' })
  @ApiResponse({ status: 200, description: 'SubCategory rejected successfully.' })
  @ApiResponse({ status: 404, description: 'SubCategory not found.' })
  async reject(
    @Param('id') id: string,
    @Body() rejectDto: RejectDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.subCategoriesService.reject(id, adminId, rejectDto.reason);
    return {
      success: true,
      message: 'SubCategory rejected successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete subcategory' })
  @ApiResponse({ status: 200, description: 'SubCategory successfully deleted.' })
  @ApiResponse({ status: 404, description: 'SubCategory not found.' })
  async remove(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.subCategoriesService.remove(id, adminId);
    return {
      success: true,
      message: 'SubCategory deleted successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
