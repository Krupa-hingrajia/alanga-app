import { BrandEntity } from '../entities/brand.entity';
import { CreateBrandDto } from '../dto/create-brand.dto';
import { RequestBrandDto } from '../dto/request-brand.dto';
import { AdminBrandFilterDto } from '../dto/admin-brand-filter.dto';

export abstract class IBrandsRepository {
  abstract create(data: CreateBrandDto, vendorId?: string): Promise<BrandEntity>;
  abstract createVendorRequest(data: RequestBrandDto, vendorId: string): Promise<BrandEntity>;
  abstract findMany(filters?: { status?: string; search?: string }): Promise<BrandEntity[]>;
  abstract findById(id: string): Promise<BrandEntity | null>;
  abstract findByName(name: string): Promise<BrandEntity | null>;
  abstract findByNameCaseInsensitive(name: string): Promise<BrandEntity | null>;
  abstract update(id: string, data: any, userId: string): Promise<BrandEntity>;
  abstract softDelete(id: string, userId: string): Promise<BrandEntity>;
  abstract countProducts(brandId: string): Promise<number>;
  abstract findForAdmin(filters: AdminBrandFilterDto): Promise<{
    items: any[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }>;
}
