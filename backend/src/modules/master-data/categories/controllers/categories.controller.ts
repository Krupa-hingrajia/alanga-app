import { Controller, Get, Put, Delete, Param, Body, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { CategoriesService } from '../services/categories.service';
import { RejectDto } from '../dto/reject.dto';

@ApiTags('Admin Categories Approval')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller('admin/categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get('pending')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of pending categories' })
  @ApiResponse({ status: 200, description: 'Pending categories retrieved successfully.' })
  async getPending() {
    const data = await this.categoriesService.findAllPending();
    return {
      success: true,
      message: 'Pending categories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/approve')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve a pending category' })
  @ApiResponse({ status: 200, description: 'Category approved successfully.' })
  @ApiResponse({ status: 404, description: 'Category not found.' })
  async approve(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.categoriesService.approve(id, adminId);
    return {
      success: true,
      message: 'Category approved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id/reject')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject a pending category' })
  @ApiResponse({ status: 200, description: 'Category rejected successfully.' })
  @ApiResponse({ status: 404, description: 'Category not found.' })
  async reject(
    @Param('id') id: string,
    @Body() rejectDto: RejectDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.categoriesService.reject(id, adminId, rejectDto.reason);
    return {
      success: true,
      message: 'Category rejected successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete category' })
  @ApiResponse({ status: 200, description: 'Category successfully deleted.' })
  @ApiResponse({ status: 404, description: 'Category not found.' })
  async remove(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.categoriesService.remove(id, adminId);
    return {
      success: true,
      message: 'Category deleted successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
