export class ProductAttributeEntity {
  id: string;
  name: string;
  status: string;
  createdAt: Date;
  updatedAt: Date;
  deletedAt: Date | null;
  createdBy: string | null;
  updatedBy: string | null;

  constructor(partial: Partial<ProductAttributeEntity>) {
    Object.assign(this, partial);
  }
}
