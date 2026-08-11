import { CategoryEntity } from '../entities/category.entity';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';

export abstract class ICategoriesRepository {
  abstract create(data: CreateCategoryDto, vendorId: string): Promise<CategoryEntity>;
  abstract findMany(filters?: { status?: string; createdByVendorId?: string }): Promise<CategoryEntity[]>;
  abstract findById(id: string): Promise<CategoryEntity | null>;
  abstract findByName(name: string): Promise<CategoryEntity | null>;
  abstract update(id: string, data: any, userId: string): Promise<CategoryEntity>;
  abstract softDelete(id: string, userId: string): Promise<CategoryEntity>;
}
