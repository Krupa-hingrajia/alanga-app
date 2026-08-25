import { InventoryHistoryEntity } from '../entities/inventory-history.entity';

export interface UpdateInventoryData {
  currentStock: number;
  minimumStock?: number;
  inventoryStatus: string;
}

export interface CreateInventoryHistoryData {
  variantId: string;
  previousStock: number;
  newStock: number;
  quantityChanged: number;
  actionType: string;
  remarks?: string;
  updatedBy: string;
}

export abstract class IInventoryRepository {
  abstract findVariantById(variantId: string): Promise<any | null>;
  abstract findVariantsByProductId(productId: string): Promise<any[]>;
  abstract updateInventory(variantId: string, data: UpdateInventoryData, userId: string): Promise<any>;
  abstract createHistoryEntry(data: CreateInventoryHistoryData): Promise<InventoryHistoryEntity>;
  abstract findHistoryByVariantId(variantId: string): Promise<InventoryHistoryEntity[]>;
}
