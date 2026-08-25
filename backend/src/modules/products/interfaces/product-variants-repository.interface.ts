import { ProductVariantEntity } from '../entities/product-variant.entity';
import { CreateProductVariantDto } from '../dto/create-product-variant.dto';
import { UpdateProductVariantDto } from '../dto/update-product-variant.dto';

export abstract class IProductVariantsRepository {
  abstract create(
    productId: string,
    data: CreateProductVariantDto,
  ): Promise<ProductVariantEntity>;

  abstract findByProductId(productId: string): Promise<ProductVariantEntity[]>;

  abstract findById(id: string): Promise<ProductVariantEntity | null>;

  abstract findBySku(sku: string): Promise<ProductVariantEntity | null>;

  abstract update(
    id: string,
    data: UpdateProductVariantDto,
  ): Promise<ProductVariantEntity>;

  abstract softDelete(id: string): Promise<ProductVariantEntity>;
}
