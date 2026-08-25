import { Controller, Post, Put, Delete, Get, Body, Param, UseGuards, HttpCode, HttpStatus, ForbiddenException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CategoriesService } from '../services/categories.service';

@ApiTags('Vendor Categories')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/categories')
export class VendorCategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Post()
  @HttpCode(HttpStatus.FORBIDDEN)
  @ApiOperation({ summary: 'Categories are managed only by Admin' })
  async create() {
    throw new ForbiddenException('Categories are managed only by Admin.');
  }

  @Put(':id')
  @HttpCode(HttpStatus.FORBIDDEN)
  @ApiOperation({ summary: 'Categories are managed only by Admin' })
  async update() {
    throw new ForbiddenException('Categories are managed only by Admin.');
  }

  @Delete(':id')
  @HttpCode(HttpStatus.FORBIDDEN)
  @ApiOperation({ summary: 'Categories are managed only by Admin' })
  async remove() {
    throw new ForbiddenException('Categories are managed only by Admin.');
  }

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of active Admin-created categories for product creation' })
  @ApiResponse({ status: 200, description: 'Categories retrieved successfully.' })
  async findAll() {
    const data = await this.categoriesService.findAllActive();
    return {
      success: true,
      message: 'Active categories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
