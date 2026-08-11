import { Controller, Post, Get, Put, Delete, Body, Param, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { AttributesService } from '../services/attributes.service';
import { CreateAttributeDto } from '../dto/create-attribute.dto';
import { UpdateAttributeDto } from '../dto/update-attribute.dto';

@ApiTags('Product Attributes')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin/attributes')
export class AttributesController {
  constructor(private readonly attributesService: AttributesService) {}

  @Post()
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new product attribute (Admin only)' })
  @ApiResponse({ status: 201, description: 'Attribute successfully created.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  @ApiResponse({ status: 409, description: 'Attribute name already exists.' })
  async create(@Body() createAttributeDto: CreateAttributeDto, @CurrentUser('id') adminId: string) {
    const data = await this.attributesService.create(createAttributeDto, adminId);
    return {
      success: true,
      message: 'Attribute created successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get()
  @Roles(Role.ADMIN, Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of all product attributes (Admin and Vendor)' })
  @ApiResponse({ status: 200, description: 'Attributes retrieved successfully.' })
  async findAll() {
    const data = await this.attributesService.findAll();
    return {
      success: true,
      message: 'Attributes retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update product attribute (Admin only)' })
  @ApiResponse({ status: 200, description: 'Attribute successfully updated.' })
  @ApiResponse({ status: 404, description: 'Attribute not found.' })
  @ApiResponse({ status: 409, description: 'Attribute name already exists.' })
  async update(
    @Param('id') id: string,
    @Body() updateAttributeDto: UpdateAttributeDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.attributesService.update(id, updateAttributeDto, adminId);
    return {
      success: true,
      message: 'Attribute updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete product attribute (Admin only)' })
  @ApiResponse({ status: 200, description: 'Attribute successfully deleted.' })
  @ApiResponse({ status: 404, description: 'Attribute not found.' })
  async remove(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.attributesService.remove(id, adminId);
    return {
      success: true,
      message: 'Attribute deleted successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
