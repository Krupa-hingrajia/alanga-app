import { Controller, Post, Get, Put, Delete, Body, Param, Query, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../../common/guards/roles.guard';
import { Roles } from '../../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../../common/decorators/current-user.decorator';
import { AttributeValuesService } from '../services/attribute-values.service';
import { CreateAttributeValueDto } from '../dto/create-attribute-value.dto';
import { UpdateAttributeValueDto } from '../dto/update-attribute-value.dto';

@ApiTags('Attribute Values')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin/attribute-values')
export class AttributeValuesController {
  constructor(private readonly attributeValuesService: AttributeValuesService) {}

  @Post()
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new attribute value (Admin only)' })
  @ApiResponse({ status: 201, description: 'Attribute value successfully created.' })
  @ApiResponse({ status: 400, description: 'Validation failed.' })
  @ApiResponse({ status: 404, description: 'ProductAttribute not found.' })
  @ApiResponse({ status: 409, description: 'Attribute value already exists for this attribute.' })
  async create(@Body() createAttributeValueDto: CreateAttributeValueDto, @CurrentUser('id') adminId: string) {
    const data = await this.attributeValuesService.create(createAttributeValueDto, adminId);
    return {
      success: true,
      message: 'Attribute value created successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get()
  @Roles(Role.ADMIN, Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get list of attribute values (Admin and Vendor)' })
  @ApiQuery({ name: 'attributeId', required: false, description: 'Filter by ProductAttribute ID (UUID)' })
  @ApiResponse({ status: 200, description: 'Attribute values retrieved successfully.' })
  async findAll(@Query('attributeId') attributeId?: string) {
    const data = await this.attributeValuesService.findAll(attributeId);
    return {
      success: true,
      message: 'Attribute values retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update attribute value (Admin only)' })
  @ApiResponse({ status: 200, description: 'Attribute value successfully updated.' })
  @ApiResponse({ status: 404, description: 'Attribute value or ProductAttribute not found.' })
  @ApiResponse({ status: 409, description: 'Attribute value already exists for this attribute.' })
  async update(
    @Param('id') id: string,
    @Body() updateAttributeValueDto: UpdateAttributeValueDto,
    @CurrentUser('id') adminId: string,
  ) {
    const data = await this.attributeValuesService.update(id, updateAttributeValueDto, adminId);
    return {
      success: true,
      message: 'Attribute value updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete attribute value (Admin only)' })
  @ApiResponse({ status: 200, description: 'Attribute value successfully deleted.' })
  @ApiResponse({ status: 404, description: 'Attribute value not found.' })
  async remove(@Param('id') id: string, @CurrentUser('id') adminId: string) {
    const data = await this.attributeValuesService.remove(id, adminId);
    return {
      success: true,
      message: 'Attribute value deleted successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
