import { Injectable } from '@nestjs/common';
import { IProductsRepository } from '../interfaces/products-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { ProductEntity } from '../entities/product.entity';
import { CreateProductDto } from '../dto/create-product.dto';
import { AdminProductFilterDto } from '../dto/admin-product-filter.dto';

@Injectable()
export class ProductsRepository implements IProductsRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(product: any): ProductEntity {
    const rawImages = product.productImages || product.images || [];
    const images = rawImages.filter((img: any) => !img.productVariantId);
    const primaryImg = images.find((img: any) => img.isPrimary)?.imageUrl || images.find((img: any) => img.isPrimary)?.url || images[0]?.imageUrl || images[0]?.url || (typeof rawImages[0] === 'string' ? rawImages[0] : null);
    const displayImage = product.image || primaryImg || null;

    const variants = (product.productVariants || product.variants || []).map((v: any) => ({
      ...v,
      images: v.images || v.productImages || rawImages.filter((img: any) => img.productVariantId === v.id),
    }));

    const vendorName = product.vendor ? product.vendor.fullName : null;
    const vendorStoreName = product.vendor?.vendorProfile?.storeName || vendorName || 'Vendor Store';

    return new ProductEntity({
      id: product.id,
      name: product.name,
      description: product.description,
      shortDescription: product.shortDescription,
      categoryId: product.categoryId,
      subCategoryId: product.subCategoryId,
      brandId: product.brandId,
      sellingPrice: product.sellingPrice,
      mrp: product.mrp,
      taxPercentage: product.taxPercentage,
      stock: product.stock,
      weight: product.weight,
      length: product.length,
      width: product.width,
      height: product.height,
      sku: product.sku,
      status: product.status,
      image: displayImage,
      vendorId: product.vendorId,
      createdByVendorId: product.createdByVendorId || product.vendorId,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      deletedAt: product.deletedAt,
      images: images,
      variants: variants,
      shipping: product.shipping || null,
      brand: product.brand ? { id: product.brand.id, name: product.brand.name, logo: product.brand.logo } : null,
      category: product.category ? { id: product.category.id, name: product.category.name } : null,
      subCategory: product.subCategory ? { id: product.subCategory.id, name: product.subCategory.name } : null,
      vendor: product.vendor
        ? {
            id: product.vendor.id,
            name: vendorName,
            fullName: vendorName,
            email: product.vendor.email,
            phoneNumber: product.vendor.phoneNumber,
            storeName: vendorStoreName,
          }
        : null,
    });
  }

  private generateNextSku(): string {
    const timestamp = Date.now().toString(36).toUpperCase();
    const randomSuffix = Math.random().toString(36).substring(2, 6).toUpperCase();
    return `ALA-PRD-${timestamp}-${randomSuffix}`;
  }

  async create(data: CreateProductDto, vendorId: string): Promise<ProductEntity> {
    const sku = await this.generateNextSku();
    const product = await this.prisma.product.create({
      data: {
        name: data.name,
        description: data.description,
        shortDescription: data.shortDescription,
        categoryId: data.categoryId,
        subCategoryId: data.subCategoryId,
        brandId: data.brandId,
        sellingPrice: data.sellingPrice,
        mrp: data.mrp,
        taxPercentage: data.taxPercentage ?? 0,
        stock: data.stock ?? 0,
        weight: data.weight,
        length: data.length,
        width: data.width,
        height: data.height,
        sku: sku,
        status: data.status ?? 'DRAFT',
        image: data.image,
        vendorId: vendorId,
      },
      include: {
        productImages: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] },
        productVariants: {
          where: { deletedAt: null },
          include: { images: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] } },
        },
        shipping: true,
        brand: true,
        category: true,
        subCategory: true,
        vendor: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phoneNumber: true,
            vendorProfile: { select: { storeName: true, legalName: true } },
          },
        },
      },
    });
    return this.mapToEntity(product);
  }

  async findMany(filters?: { status?: string; createdByVendorId?: string }): Promise<ProductEntity[]> {
    const whereClause: any = { deletedAt: null };
    if (filters) {
      if (filters.status && filters.createdByVendorId) {
        whereClause.OR = [
          { status: filters.status },
          { vendorId: filters.createdByVendorId, deletedAt: null }
        ];
      } else if (filters.status) {
        whereClause.status = filters.status;
      } else if (filters.createdByVendorId) {
        whereClause.vendorId = filters.createdByVendorId;
      }
    }
    const products = await this.prisma.product.findMany({
      where: whereClause,
      include: {
        productImages: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] },
        productVariants: {
          where: { deletedAt: null },
          include: { images: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] } },
        },
        shipping: true,
        brand: true,
        category: true,
        subCategory: true,
        vendor: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phoneNumber: true,
            vendorProfile: { select: { storeName: true, legalName: true } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
    return products.map((p) => this.mapToEntity(p));
  }

  async findById(id: string): Promise<ProductEntity | null> {
    const product = await this.prisma.product.findFirst({
      where: { id, deletedAt: null },
      include: {
        productImages: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] },
        productVariants: {
          where: { deletedAt: null },
          include: { images: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] } },
        },
        shipping: true,
        brand: true,
        category: true,
        subCategory: true,
        vendor: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phoneNumber: true,
            vendorProfile: { select: { storeName: true, legalName: true } },
          },
        },
      },
    });
    return product ? this.mapToEntity(product) : null;
  }

  async update(id: string, data: any, userId: string): Promise<ProductEntity> {
    const product = await this.prisma.product.update({
      where: { id },
      data: {
        name: data.name,
        description: data.description,
        shortDescription: data.shortDescription,
        categoryId: data.categoryId,
        subCategoryId: data.subCategoryId,
        brandId: data.brandId,
        sellingPrice: data.sellingPrice,
        mrp: data.mrp,
        taxPercentage: data.taxPercentage,
        stock: data.stock,
        weight: data.weight,
        length: data.length,
        width: data.width,
        height: data.height,
        status: data.status,
        image: data.image,
      },
      include: {
        productImages: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] },
        productVariants: {
          where: { deletedAt: null },
          include: { images: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] } },
        },
        shipping: true,
        brand: true,
        category: true,
        subCategory: true,
        vendor: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phoneNumber: true,
            vendorProfile: { select: { storeName: true, legalName: true } },
          },
        },
      },
    });
    return this.mapToEntity(product);
  }

  async softDelete(id: string, userId: string): Promise<ProductEntity> {
    const product = await this.prisma.product.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        status: 'INACTIVE',
      },
      include: {
        productImages: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] },
        productVariants: {
          where: { deletedAt: null },
          include: { images: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] } },
        },
        shipping: true,
        brand: true,
        category: true,
        subCategory: true,
        vendor: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phoneNumber: true,
            vendorProfile: { select: { storeName: true, legalName: true } },
          },
        },
      },
    });
    return this.mapToEntity(product);
  }

  async findForAdmin(filters: AdminProductFilterDto): Promise<{
    items: any[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const page = filters.page || 1;
    const limit = filters.limit || 10;
    const skip = (page - 1) * limit;

    const whereClause: any = { deletedAt: null };

    if (filters.status && filters.status.toUpperCase() !== 'ALL') {
      whereClause.status = filters.status;
    }

    if (filters.vendorId) {
      whereClause.vendorId = filters.vendorId;
    }

    if (filters.categoryId) {
      whereClause.categoryId = filters.categoryId;
    }

    if (filters.subCategoryId) {
      whereClause.subCategoryId = filters.subCategoryId;
    }

    if (filters.brandId) {
      whereClause.brandId = filters.brandId;
    }

    if (filters.search) {
      const searchOR = [
        { name: { contains: filters.search, mode: 'insensitive' } },
        { sku: { contains: filters.search, mode: 'insensitive' } },
        { description: { contains: filters.search, mode: 'insensitive' } },
        { shortDescription: { contains: filters.search, mode: 'insensitive' } },
      ];
      if (whereClause.OR) {
        whereClause.AND = [{ OR: whereClause.OR }, { OR: searchOR }];
        delete whereClause.OR;
      } else {
        whereClause.OR = searchOR;
      }
    }

    let orderBy: any = { createdAt: 'desc' };
    if (filters.sort) {
      const parts = filters.sort.split('_');
      const field = parts[0];
      const direction = parts[1]?.toLowerCase() === 'asc' ? 'asc' : 'desc';
      if (['createdAt', 'sellingPrice', 'mrp', 'name', 'stock', 'updatedAt'].includes(field)) {
        orderBy = { [field]: direction };
      }
    }

    const [products, total] = await Promise.all([
      this.prisma.product.findMany({
        where: whereClause,
        skip,
        take: limit,
        include: {
          category: {
            select: { id: true, name: true },
          },
          subCategory: {
            select: { id: true, name: true },
          },
          brand: {
            select: { id: true, name: true, logo: true },
          },
          vendor: {
            select: {
              id: true,
              fullName: true,
              email: true,
              phoneNumber: true,
              vendorProfile: { select: { storeName: true, legalName: true } },
            },
          },
          productImages: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] },
          productVariants: {
            where: { deletedAt: null },
            include: { images: { where: { deletedAt: null }, orderBy: [{ isPrimary: 'desc' }, { displayOrder: 'asc' }] } },
          },
          shipping: true,
        },
        orderBy,
      }),
      this.prisma.product.count({ where: whereClause }),
    ]);

    const items = products.map((product) => {
      const rawImages = product.productImages || [];
      const primaryImg = (rawImages.find((img: any) => img.isPrimary) as any)?.imageUrl || (rawImages[0] as any)?.imageUrl || (rawImages.find((img: any) => img.isPrimary) as any)?.url || (rawImages[0] as any)?.url;
      const displayImage = product.image || primaryImg || null;

      const vendorName = product.vendor ? product.vendor.fullName : null;
      const vendorStoreName = product.vendor?.vendorProfile?.storeName || vendorName || 'Vendor Store';
      const vendor = product.vendor
        ? {
            id: product.vendor.id,
            name: vendorName,
            fullName: vendorName,
            email: product.vendor.email,
            phoneNumber: product.vendor.phoneNumber,
            storeName: vendorStoreName,
          }
        : null;

      const images = rawImages;
      const variants = (product.productVariants || []).map((v: any) => ({
        ...v,
        images: v.images || [],
      }));

      return {
        ...product,
        image: displayImage,
        images,
        variants,
        shipping: product.shipping || null,
        vendorId: product.vendorId || null,
        vendorName: vendorStoreName,
        vendorEmail: product.vendor?.email || null,
        vendor,
      };
    });

    return {
      items,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }
}
