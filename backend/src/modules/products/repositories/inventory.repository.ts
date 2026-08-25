import { Injectable } from '@nestjs/common';
import { IInventoryRepository, UpdateInventoryData, CreateInventoryHistoryData } from '../interfaces/inventory-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { InventoryHistoryEntity } from '../entities/inventory-history.entity';

@Injectable()
export class InventoryRepository implements IInventoryRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findVariantById(variantId: string): Promise<any | null> {
    return this.prisma.productVariant.findFirst({
      where: { id: variantId, deletedAt: null },
    });
  }

  async findVariantsByProductId(productId: string): Promise<any[]> {
    return this.prisma.productVariant.findMany({
      where: { productId, deletedAt: null },
      orderBy: { createdAt: 'asc' },
    });
  }

  async updateInventory(variantId: string, data: UpdateInventoryData, userId: string): Promise<any> {
    // Update ProductVariant stock
    const variant = await this.prisma.productVariant.update({
      where: { id: variantId },
      data: {
        stock: data.currentStock,
        status: data.inventoryStatus ?? 'ACTIVE',
      },
    });

    // Also update or create Inventory record if it exists
    const inventory = await this.prisma.inventory.findFirst({
      where: { productVariantId: variantId },
    });

    if (inventory) {
      const previousStock = inventory.stockQuantity;
      const newStock = data.currentStock;
      const quantityChanged = newStock - previousStock;

      await this.prisma.inventory.update({
        where: { id: inventory.id },
        data: {
          stockQuantity: newStock,
          availableStock: Math.max(0, newStock - inventory.reservedQuantity),
          inventoryStatus: data.inventoryStatus ?? 'IN_STOCK',
          ...(data.minimumStock !== undefined ? { minStockAlert: data.minimumStock } : {}),
        },
      });

      // Create log entry
      await this.prisma.inventoryLog.create({
        data: {
          inventoryId: inventory.id,
          previousStock,
          newStock,
          quantityChanged,
          changeType: 'MANUAL_UPDATE',
          reason: `Updated by user ${userId}`,
        },
      });
    }

    return variant;
  }

  async createHistoryEntry(data: CreateInventoryHistoryData): Promise<InventoryHistoryEntity> {
    // Map to InventoryLog using existing inventory record
    const inventory = await this.prisma.inventory.findFirst({
      where: { productVariantId: data.variantId },
    });

    if (inventory) {
      const log = await this.prisma.inventoryLog.create({
        data: {
          inventoryId: inventory.id,
          previousStock: data.previousStock,
          newStock: data.newStock,
          quantityChanged: data.quantityChanged,
          changeType: data.actionType,
          reason: data.remarks ?? null,
        },
      });
      return new InventoryHistoryEntity({
        id: log.id,
        variantId: data.variantId,
        previousStock: log.previousStock,
        newStock: log.newStock,
        quantityChanged: log.quantityChanged,
        actionType: log.changeType,
        remarks: log.reason ?? null,
        updatedBy: data.updatedBy,
        createdAt: log.createdAt,
      });
    }

    // Return a stub if no inventory record
    return new InventoryHistoryEntity({
      id: `stub-${Date.now()}`,
      variantId: data.variantId,
      previousStock: data.previousStock,
      newStock: data.newStock,
      quantityChanged: data.quantityChanged,
      actionType: data.actionType,
      remarks: data.remarks ?? null,
      updatedBy: data.updatedBy,
      createdAt: new Date(),
    });
  }

  async findHistoryByVariantId(variantId: string): Promise<InventoryHistoryEntity[]> {
    const inventory = await this.prisma.inventory.findFirst({
      where: { productVariantId: variantId },
      include: { logs: { orderBy: { createdAt: 'desc' } } },
    });

    if (!inventory) return [];

    return inventory.logs.map(
      (log) =>
        new InventoryHistoryEntity({
          id: log.id,
          variantId,
          previousStock: log.previousStock,
          newStock: log.newStock,
          quantityChanged: log.quantityChanged,
          actionType: log.changeType,
          remarks: log.reason ?? null,
          updatedBy: '',
          createdAt: log.createdAt,
        }),
    );
  }
}
