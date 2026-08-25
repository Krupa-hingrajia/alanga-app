import {
  Controller,
  Get,
  Put,
  Body,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody, ApiParam } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { InventoryService } from '../services/inventory.service';
import { UpdateInventoryDto } from '../dto/update-inventory.dto';
import { InventoryResponseDto } from '../dto/inventory-response.dto';
import { InventoryHistoryResponseDto } from '../dto/inventory-history-response.dto';

@ApiTags('Vendor Product Inventory')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('vendor/products')
export class VendorInventoryController {
  constructor(private readonly inventoryService: InventoryService) {}

  @Get(':productId/inventory')
  @Roles(Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get all variant inventories for a vendor product' })
  @ApiParam({ name: 'productId', description: 'Product ID (UUID)' })
  @ApiResponse({ status: 200, description: 'Inventories retrieved successfully.', type: [InventoryResponseDto] })
  @ApiResponse({ status: 403, description: 'Forbidden. Vendor does not own product.' })
  @ApiResponse({ status: 404, description: 'Product not found.' })
  async getProductInventory(
    @Param('productId') productId: string,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.inventoryService.getProductInventory(productId, vendorId);
    return {
      success: true,
      message: 'Product inventories retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':productId/variants/:variantId/inventory')
  @Roles(Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update inventory for a product variant' })
  @ApiParam({ name: 'productId', description: 'Product ID (UUID)' })
  @ApiParam({ name: 'variantId', description: 'Product Variant ID (UUID)' })
  @ApiBody({ type: UpdateInventoryDto })
  @ApiResponse({ status: 200, description: 'Inventory updated successfully.', type: InventoryResponseDto })
  @ApiResponse({ status: 400, description: 'Validation failed (e.g. negative stock).' })
  @ApiResponse({ status: 403, description: 'Forbidden. Vendor does not own product.' })
  @ApiResponse({ status: 404, description: 'Variant or Product not found.' })
  async updateVariantInventory(
    @Param('productId') productId: string,
    @Param('variantId') variantId: string,
    @Body() updateInventoryDto: UpdateInventoryDto,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.inventoryService.updateVariantInventory(
      productId,
      variantId,
      vendorId,
      updateInventoryDto,
    );
    return {
      success: true,
      message: 'Variant inventory updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':productId/variants/:variantId/inventory/history')
  @Roles(Role.VENDOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get complete stock history for a product variant' })
  @ApiParam({ name: 'productId', description: 'Product ID (UUID)' })
  @ApiParam({ name: 'variantId', description: 'Product Variant ID (UUID)' })
  @ApiResponse({ status: 200, description: 'Inventory history retrieved successfully.', type: [InventoryHistoryResponseDto] })
  @ApiResponse({ status: 403, description: 'Forbidden. Vendor does not own product.' })
  @ApiResponse({ status: 404, description: 'Variant or Product not found.' })
  async getInventoryHistory(
    @Param('productId') productId: string,
    @Param('variantId') variantId: string,
    @CurrentUser('id') vendorId: string,
  ) {
    const data = await this.inventoryService.getInventoryHistory(productId, variantId, vendorId);
    return {
      success: true,
      message: 'Variant inventory history retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
