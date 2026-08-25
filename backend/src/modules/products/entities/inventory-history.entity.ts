export class InventoryHistoryEntity {
  id: string;
  variantId: string;
  previousStock: number;
  newStock: number;
  quantityChanged: number;
  actionType: string;
  remarks: string | null;
  updatedBy: string;
  createdAt: Date;

  constructor(partial: Partial<InventoryHistoryEntity>) {
    Object.assign(this, partial);
  }
}
