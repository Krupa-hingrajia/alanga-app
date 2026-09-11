import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { IProductsRepository } from '../interfaces/products-repository.interface';
import { CreateProductDto } from '../dto/create-product.dto';
import { UpdateProductDto } from '../dto/update-product.dto';
import { AdminProductFilterDto } from '../dto/admin-product-filter.dto';
import { CategoriesService } from '../../master-data/categories/services/categories.service';
import { SubCategoriesService } from '../../master-data/sub-categories/services/sub-categories.service';
import { BrandsService } from '../../master-data/brands/services/brands.service';
import { PrismaService } from '../../../database/prisma.service';

@Injectable()
export class ProductsService {
  constructor(
    private readonly productsRepository: IProductsRepository,
    private readonly categoriesService: CategoriesService,
    private readonly subCategoriesService: SubCategoriesService,
    private readonly brandsService: BrandsService,
    private readonly prisma: PrismaService,
  ) {}

  async findForAdmin(filters: AdminProductFilterDto) {
    return this.productsRepository.findForAdmin(filters);
  }

  async create(data: CreateProductDto, vendorId: string) {
    if (data.mrp <= 0) {
      throw new BadRequestException('MRP must be greater than zero.');
    }
    if (data.sellingPrice > data.mrp) {
      throw new BadRequestException('Selling Price cannot exceed MRP.');
    }

    // Validate category, subcategory, brand exist and are active
    await this.categoriesService.findOne(data.categoryId);
    await this.subCategoriesService.findOne(data.subCategoryId);
    await this.brandsService.validateActiveBrandForProduct(data.brandId);

    return this.productsRepository.create(data, vendorId);
  }

  private resolveDefaultVariantAndImages(product: any) {
    const variants = product.variants || [];
    // 1. Variant marked as default
    // 2. First Active Variant
    // 3. Fallback to first variant
    const defaultVariant = variants.find((v: any) => v.isDefault && v.status === 'ACTIVE')
      || variants.find((v: any) => v.isDefault)
      || variants.find((v: any) => v.status === 'ACTIVE')
      || variants[0]
      || null;

    let variantImages = [];
    if (defaultVariant && defaultVariant.images && defaultVariant.images.length > 0) {
      variantImages = defaultVariant.images;
    } else {
      // Fallback to product common images (productImages where productVariantId is null)
      variantImages = (product.images || []).filter((img: any) => !img.productVariantId);
    }

    const primaryImageUrl = variantImages.find((img: any) => img.isPrimary)?.imageUrl
      || variantImages[0]?.imageUrl
      || product.image
      || '';

    return {
      ...product,
      sellingPrice: defaultVariant ? defaultVariant.price : product.sellingPrice,
      mrp: defaultVariant ? (defaultVariant.mrp ?? defaultVariant.price) : product.mrp,
      stock: defaultVariant ? defaultVariant.stock : product.stock,
      sku: defaultVariant ? defaultVariant.sku : product.sku,
      attributes: defaultVariant ? defaultVariant.attributes : {},
      image: primaryImageUrl,
      images: variantImages,
      defaultVariant,
    };
  }

  async findAllActive(customerId?: string) {
    const products = await this.productsRepository.findMany({ status: 'ACTIVE' });
    const resolvedProducts = products.map((p) => this.resolveDefaultVariantAndImages(p));

    if (!customerId) {
      return resolvedProducts.map((p) => ({ ...p, isWishlisted: false }));
    }

    const wishlists = await this.prisma.wishlist.findMany({
      where: { customerId },
      select: { productId: true },
    });
    const wishlistedSet = new Set(wishlists.map((w) => w.productId));

    return resolvedProducts.map((p) => ({
      ...p,
      isWishlisted: wishlistedSet.has(p.id),
    }));
  }

  async findOneForCustomer(id: string, customerId?: string) {
    const rawProduct = await this.findOne(id);
    const product = this.resolveDefaultVariantAndImages(rawProduct);
    
    let isWishlisted = false;
    if (customerId) {
      const existing = await this.prisma.wishlist.findFirst({
        where: { 
          customerId, 
          productId: id,
          productVariantId: product.defaultVariant ? product.defaultVariant.id : undefined,
        },
      });
      isWishlisted = !!existing;
    }
    return {
      ...product,
      isWishlisted,
    };
  }

  async findVariantForCustomer(productId: string, variantId: string) {
    const variant = await this.prisma.productVariant.findFirst({
      where: { id: variantId, productId: productId, deletedAt: null },
      include: {
        images: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] },
      },
    });

    if (!variant) {
      throw new NotFoundException(`Variant with ID "${variantId}" not found for product "${productId}".`);
    }

    // Resolve images
    let resolvedImages = variant.images || [];
    if (resolvedImages.length === 0) {
      resolvedImages = await this.prisma.productImage.findMany({
        where: { productId: productId, productVariantId: null, deletedAt: null },
        orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }],
      });
    }

    return {
      id: variant.id,
      productId: variant.productId,
      sku: variant.sku,
      variantName: variant.variantName,
      color: variant.color,
      size: variant.size,
      storage: variant.storage,
      price: variant.price,
      mrp: variant.mrp ?? variant.price,
      stock: variant.stock,
      status: variant.status,
      attributes: variant.attributes,
      images: resolvedImages,
      isDefault: variant.isDefault,
      createdAt: variant.createdAt,
      updatedAt: variant.updatedAt,
    };
  }

  async findAllPending() {
    return this.productsRepository.findMany({ status: 'PENDING' });
  }

  async findVendorProducts(vendorId: string) {
    return this.productsRepository.findMany({ createdByVendorId: vendorId });
  }

  async findOne(id: string) {
    const product = await this.productsRepository.findById(id);
    if (!product) {
      throw new NotFoundException(`Product with ID "${id}" not found.`);
    }
    return product;
  }

  async findOneByVendor(id: string, vendorId: string) {
    const product = await this.findOne(id);
    if (product.createdByVendorId !== vendorId && product.vendorId !== vendorId) {
      throw new ForbiddenException('Access denied. You do not own this product.');
    }
    return product;
  }

  async updateByVendor(id: string, data: UpdateProductDto, vendorId: string) {
    const product = await this.findOneByVendor(id, vendorId);

    if (data.mrp !== undefined && data.mrp <= 0) {
      throw new BadRequestException('MRP must be greater than zero.');
    }

    const targetMrp = data.mrp ?? product.mrp;
    const targetSellingPrice = data.sellingPrice ?? product.sellingPrice;

    if (targetSellingPrice > targetMrp) {
      throw new BadRequestException('Selling Price cannot exceed MRP.');
    }

    if (data.categoryId) await this.categoriesService.findOne(data.categoryId);
    if (data.subCategoryId) await this.subCategoriesService.findOne(data.subCategoryId);
    if (data.brandId) await this.brandsService.validateActiveBrandForProduct(data.brandId);

    return this.productsRepository.update(id, data, vendorId);
  }

  async removeByVendor(id: string, vendorId: string) {
    await this.findOneByVendor(id, vendorId);
    return this.productsRepository.softDelete(id, vendorId);
  }

  async submitForApproval(id: string, vendorId: string) {
    await this.findOneByVendor(id, vendorId);
    return this.productsRepository.update(id, { status: 'PENDING' }, vendorId);
  }

  async approve(id: string, adminId: string) {
    await this.findOne(id);
    return this.productsRepository.update(id, { status: 'ACTIVE', approvedByAdminId: adminId, approvedAt: new Date() }, adminId);
  }

  async reject(id: string, adminId: string, reason: string) {
    await this.findOne(id);
    return this.productsRepository.update(id, { status: 'REJECTED', approvedByAdminId: adminId, rejectedReason: reason }, adminId);
  }

  async suspend(id: string, adminId: string) {
    await this.findOne(id);
    return this.productsRepository.update(id, { status: 'SUSPENDED' }, adminId);
  }
}
