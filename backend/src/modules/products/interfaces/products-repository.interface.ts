import { ProductEntity } from '../entities/product.entity';
import { CreateProductDto } from '../dto/create-product.dto';
import { AdminProductFilterDto } from '../dto/admin-product-filter.dto';

export abstract class IProductsRepository {
  abstract create(data: CreateProductDto, vendorId: string): Promise<ProductEntity>;
  abstract findMany(filters?: { status?: string; createdByVendorId?: string }): Promise<ProductEntity[]>;
  abstract findById(id: string): Promise<ProductEntity | null>;
  abstract update(id: string, data: any, userId: string): Promise<ProductEntity>;
  abstract softDelete(id: string, userId: string): Promise<ProductEntity>;
  abstract findForAdmin(filters: AdminProductFilterDto): Promise<{
    items: any[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }>;
}

