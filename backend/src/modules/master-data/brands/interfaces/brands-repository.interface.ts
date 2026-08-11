import { BrandEntity } from '../entities/brand.entity';
import { CreateBrandDto } from '../dto/create-brand.dto';
import { UpdateBrandDto } from '../dto/update-brand.dto';

export abstract class IBrandsRepository {
  abstract create(data: CreateBrandDto, userId: string): Promise<BrandEntity>;
  abstract findMany(): Promise<BrandEntity[]>;
  abstract findById(id: string): Promise<BrandEntity | null>;
  abstract findByName(name: string): Promise<BrandEntity | null>;
  abstract update(id: string, data: UpdateBrandDto, userId: string): Promise<BrandEntity>;
  abstract softDelete(id: string, userId: string): Promise<BrandEntity>;
}
