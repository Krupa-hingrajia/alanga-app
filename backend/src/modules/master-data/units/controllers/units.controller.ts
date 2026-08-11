import { Controller, Post, Get, Put, Delete, Body, Param, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { UnitsService } from '../services/units.service';
import { CreateUnitDto } from '../dto/create-unit.dto';
import { UpdateUnitDto } from '../dto/update-unit.dto';

@ApiTags('Units')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin/units')
export class UnitsController {
  constructor(private readonly unitsService: UnitsService) {}

  @Post()
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new unit (Admin only)' })
  @ApiResponse({ status: 201, description: 'Unit successfully created.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  @ApiResponse({ status: 409, description: 'Unit name already exists.' })
  async create(@Body() createUnitDto: CreateUnitDto, @CurrentUser('id') adminId: string) {
    const data = await this.unitsService.create(createUnitDto, adminId);
    return {
      success: true,
      message: 'Unit created successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get()
  @Roles(Role.ADMIN, Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of all units (Admin and Vendor)' })
  @ApiResponse({ status: 200, description: 'Units retrieved successfully.' })
  async findAll() {
    const data = await this.unitsService.findAll();
    return {
      success: true,
      message: 'Units retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update unit (Admin only)' })
  @ApiResponse({ status: 200, description: 'Unit successfully updated.' })
  @ApiResponse({ status: 404, description: 'Unit not found.' })
  @ApiResponse({ status: 409, description: 'Unit name already exists.' })
  async update(
    @Param('id') id: string,
    @Body() updateUnitDto: UpdateUnitDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.unitsService.update(id, updateUnitDto, adminId);
    return {
      success: true,
      message: 'Unit updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete unit (Admin only)' })
  @ApiResponse({ status: 200, description: 'Unit successfully deleted.' })
  @ApiResponse({ status: 404, description: 'Unit not found.' })
  async remove(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.unitsService.remove(id, adminId);
    return {
      success: true,
      message: 'Unit deleted successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
