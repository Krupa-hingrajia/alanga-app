import { BrandEntity } from '../entities/brand.entity';
import { CreateBrandDto } from '../dto/create-brand.dto';
import { UpdateBrandDto } from '../dto/update-brand.dto';

export abstract class IBrandsRepository {
  abstract create(data: CreateBrandDto, vendorId: string): Promise<BrandEntity>;
  abstract findMany(filters?: { status?: string; createdByVendorId?: string }): Promise<BrandEntity[]>;
  abstract findById(id: string): Promise<BrandEntity | null>;
  abstract findByName(name: string): Promise<BrandEntity | null>;
  abstract update(id: string, data: any, userId: string): Promise<BrandEntity>;
  abstract softDelete(id: string, userId: string): Promise<BrandEntity>;
}
