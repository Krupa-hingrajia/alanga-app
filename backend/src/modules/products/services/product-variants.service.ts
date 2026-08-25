import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { IProductVariantsRepository } from '../interfaces/product-variants-repository.interface';
import { IProductsRepository } from '../interfaces/products-repository.interface';
import { CreateProductVariantDto } from '../dto/create-product-variant.dto';
import { UpdateProductVariantDto } from '../dto/update-product-variant.dto';
import { ProductVariantEntity } from '../entities/product-variant.entity';

@Injectable()
export class ProductVariantsService {
  constructor(
    private readonly productVariantsRepository: IProductVariantsRepository,
    private readonly productsRepository: IProductsRepository,
  ) {}

  private async checkProductOwnership(productId: string, vendorId: string) {
    const product = await this.productsRepository.findById(productId);
    if (!product) {
      throw new NotFoundException('Product not found.');
    }
    if (product.vendorId !== vendorId && product.createdByVendorId !== vendorId) {
      throw new ForbiddenException('Forbidden. You do not own this product.');
    }
    return product;
  }

  async createVariant(
    productId: string,
    vendorId: string,
    dto: CreateProductVariantDto,
  ): Promise<ProductVariantEntity> {
    await this.checkProductOwnership(productId, vendorId);

    // Validate Price
    if (dto.price < 0) {
      throw new BadRequestException('Price cannot be negative.');
    }

    // Validate Stock
    if (dto.stock < 0) {
      throw new BadRequestException('Stock cannot be negative.');
    }

    // Validate SKU uniqueness across variants
    const existingVariant = await this.productVariantsRepository.findBySku(dto.sku);
    if (existingVariant) {
      throw new BadRequestException(
        `SKU must be unique. The SKU "${dto.sku}" is already in use by another variant.`,
      );
    }

    return this.productVariantsRepository.create(productId, dto);
  }

  async getVariantsByProductId(
    productId: string,
    vendorId: string,
  ): Promise<ProductVariantEntity[]> {
    await this.checkProductOwnership(productId, vendorId);
    return this.productVariantsRepository.findByProductId(productId);
  }

  async updateVariant(
    productId: string,
    variantId: string,
    vendorId: string,
    dto: UpdateProductVariantDto,
  ): Promise<ProductVariantEntity> {
    await this.checkProductOwnership(productId, vendorId);

    const existingVariant = await this.productVariantsRepository.findById(variantId);
    if (!existingVariant || existingVariant.productId !== productId) {
      throw new NotFoundException('Product variant not found.');
    }

    if (dto.price !== undefined && dto.price < 0) {
      throw new BadRequestException('Price cannot be negative.');
    }

    if (dto.stock !== undefined && dto.stock < 0) {
      throw new BadRequestException('Stock cannot be negative.');
    }

    if (dto.sku && dto.sku !== existingVariant.sku) {
      const skuOwner = await this.productVariantsRepository.findBySku(dto.sku);
      if (skuOwner && skuOwner.id !== variantId) {
        throw new BadRequestException(
          `SKU must be unique. The SKU "${dto.sku}" is already in use by another variant.`,
        );
      }
    }

    return this.productVariantsRepository.update(variantId, dto);
  }

  async deleteVariant(
    productId: string,
    variantId: string,
    vendorId: string,
  ): Promise<{ message: string }> {
    await this.checkProductOwnership(productId, vendorId);

    const existingVariant = await this.productVariantsRepository.findById(variantId);
    if (!existingVariant || existingVariant.productId !== productId) {
      throw new NotFoundException('Product variant not found.');
    }

    await this.productVariantsRepository.softDelete(variantId);
    return { message: 'Product variant deleted successfully.' };
  }
}
