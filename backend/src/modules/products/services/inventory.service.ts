import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { IInventoryRepository } from '../interfaces/inventory-repository.interface';
import { ProductsService } from './products.service';
import { UpdateInventoryDto } from '../dto/update-inventory.dto';
import { InventoryResponseDto } from '../dto/inventory-response.dto';
import { InventoryHistoryResponseDto } from '../dto/inventory-history-response.dto';

@Injectable()
export class InventoryService {
  constructor(
    private readonly inventoryRepository: IInventoryRepository,
    private readonly productsService: ProductsService,
  ) {}

  public calculateInventoryStatus(stock: number): string {
    if (stock > 10) {
      return 'IN_STOCK';
    } else if (stock >= 1) {
      return 'LOW_STOCK';
    } else {
      return 'OUT_OF_STOCK';
    }
  }

  private mapToInventoryResponse(variant: any): InventoryResponseDto {
    const currentStock = variant.currentStock ?? variant.stock ?? 0;
    const reservedStock = variant.reservedStock ?? 0;
    const availableStock = currentStock - reservedStock;
    const minimumStock = variant.minimumStock ?? 5;
    const inventoryStatus = this.calculateInventoryStatus(currentStock);

    return new InventoryResponseDto({
      variant: {
        id: variant.id,
        productId: variant.productId,
        sku: variant.sku,
        variantName: variant.variantName,
        color: variant.color,
        size: variant.size,
        storage: variant.storage,
        price: variant.price,
        status: variant.status,
      },
      sku: variant.sku,
      currentStock,
      reservedStock,
      availableStock,
      minimumStock,
      inventoryStatus,
      lastStockUpdatedAt: variant.lastStockUpdatedAt ?? variant.updatedAt,
      lastStockUpdatedBy: variant.lastStockUpdatedBy ?? null,
    });
  }

  async getProductInventory(productId: string, vendorId: string): Promise<InventoryResponseDto[]> {
    // Ownership check
    await this.productsService.findOneByVendor(productId, vendorId);

    const variants = await this.inventoryRepository.findVariantsByProductId(productId);
    return variants.map((v) => this.mapToInventoryResponse(v));
  }

  async updateVariantInventory(
    productId: string,
    variantId: string,
    vendorId: string,
    dto: UpdateInventoryDto,
  ): Promise<InventoryResponseDto> {
    // Ownership check
    await this.productsService.findOneByVendor(productId, vendorId);

    const variant = await this.inventoryRepository.findVariantById(variantId);
    if (!variant) {
      throw new NotFoundException(`Product Variant with ID "${variantId}" not found.`);
    }

    if (variant.productId !== productId) {
      throw new BadRequestException(`Variant "${variantId}" does not belong to Product "${productId}".`);
    }

    if (dto.currentStock < 0) {
      throw new BadRequestException('Stock cannot be negative.');
    }

    if (dto.minimumStock !== undefined && dto.minimumStock < 0) {
      throw new BadRequestException('Minimum stock cannot be negative.');
    }

    const previousStock = variant.currentStock ?? variant.stock ?? 0;
    const newStock = dto.currentStock;
    const quantityChanged = newStock - previousStock;
    const newStatus = this.calculateInventoryStatus(newStock);

    const updatedVariant = await this.inventoryRepository.updateInventory(
      variantId,
      {
        currentStock: newStock,
        minimumStock: dto.minimumStock,
        inventoryStatus: newStatus,
      },
      vendorId,
    );

    // Record History Entry
    await this.inventoryRepository.createHistoryEntry({
      variantId,
      previousStock,
      newStock,
      quantityChanged,
      actionType: 'MANUAL_UPDATE',
      remarks: dto.remarks,
      updatedBy: vendorId,
    });

    return this.mapToInventoryResponse(updatedVariant);
  }

  async getInventoryHistory(
    productId: string,
    variantId: string,
    vendorId: string,
  ): Promise<InventoryHistoryResponseDto[]> {
    // Ownership check
    await this.productsService.findOneByVendor(productId, vendorId);

    const variant = await this.inventoryRepository.findVariantById(variantId);
    if (!variant) {
      throw new NotFoundException(`Product Variant with ID "${variantId}" not found.`);
    }

    if (variant.productId !== productId) {
      throw new BadRequestException(`Variant "${variantId}" does not belong to Product "${productId}".`);
    }

    const history = await this.inventoryRepository.findHistoryByVariantId(variantId);
    return history.map(
      (h) =>
        new InventoryHistoryResponseDto({
          id: h.id,
          variantId: h.variantId,
          previousStock: h.previousStock,
          newStock: h.newStock,
          quantityChanged: h.quantityChanged,
          actionType: h.actionType,
          remarks: h.remarks,
          updatedBy: h.updatedBy,
          createdAt: h.createdAt,
        }),
    );
  }
}
