import { ProductEntity } from '../entities/product.entity';
import { CreateProductDto } from '../dto/create-product.dto';

export abstract class IProductsRepository {
  abstract create(data: CreateProductDto, vendorId: string): Promise<ProductEntity>;
  abstract findMany(filters?: { status?: string; createdByVendorId?: string }): Promise<ProductEntity[]>;
  abstract findById(id: string): Promise<ProductEntity | null>;
  abstract update(id: string, data: any, userId: string): Promise<ProductEntity>;
  abstract softDelete(id: string, userId: string): Promise<ProductEntity>;
}
