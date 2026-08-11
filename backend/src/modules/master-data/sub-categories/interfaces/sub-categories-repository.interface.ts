import { SubCategoryEntity } from '../entities/sub-category.entity';
import { CreateSubCategoryDto } from '../dto/create-sub-category.dto';
import { UpdateSubCategoryDto } from '../dto/update-sub-category.dto';

export abstract class ISubCategoriesRepository {
  abstract create(data: CreateSubCategoryDto, vendorId: string): Promise<SubCategoryEntity>;
  abstract findMany(filters?: { categoryId?: string; status?: string; createdByVendorId?: string }): Promise<SubCategoryEntity[]>;
  abstract findById(id: string): Promise<SubCategoryEntity | null>;
  abstract findByNameAndCategory(name: string, categoryId: string): Promise<SubCategoryEntity | null>;
  abstract update(id: string, data: any, userId: string): Promise<SubCategoryEntity>;
  abstract softDelete(id: string, userId: string): Promise<SubCategoryEntity>;
}
