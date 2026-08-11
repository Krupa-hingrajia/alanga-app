import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { IProductsRepository } from '../interfaces/products-repository.interface';
import { CreateProductDto } from '../dto/create-product.dto';
import { UpdateProductDto } from '../dto/update-product.dto';
import { CategoriesService } from '../../master-data/categories/services/categories.service';
import { SubCategoriesService } from '../../master-data/sub-categories/services/sub-categories.service';
import { BrandsService } from '../../master-data/brands/services/brands.service';

@Injectable()
export class ProductsService {
  constructor(
    private readonly productsRepository: IProductsRepository,
    private readonly categoriesService: CategoriesService,
    private readonly subCategoriesService: SubCategoriesService,
    private readonly brandsService: BrandsService,
  ) {}

  async create(data: CreateProductDto, vendorId: string) {
    if (data.mrp <= 0) {
      throw new BadRequestException('MRP must be greater than zero.');
    }
    if (data.sellingPrice > data.mrp) {
      throw new BadRequestException('Selling Price cannot exceed MRP.');
    }

    // Validate category, subcategory, brand exist
    await this.categoriesService.findOne(data.categoryId);
    await this.subCategoriesService.findOne(data.subCategoryId);
    await this.brandsService.findOne(data.brandId);

    return this.productsRepository.create(data, vendorId);
  }

  async findAllActive() {
    return this.productsRepository.findMany({ status: 'ACTIVE' });
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
    if (product.createdByVendorId !== vendorId) {
      throw new ForbiddenException('Access denied. You do not own this product.');
    }
    return product;
  }

  async updateByVendor(id: string, data: UpdateProductDto, vendorId: string) {
    const product = await this.findOneByVendor(id, vendorId);

    // Validate prices if updated
    const targetMrp = data.mrp !== undefined ? data.mrp : product.mrp;
    const targetSellingPrice = data.sellingPrice !== undefined ? data.sellingPrice : product.sellingPrice;

    if (targetMrp <= 0) {
      throw new BadRequestException('MRP must be greater than zero.');
    }
    if (targetSellingPrice > targetMrp) {
      throw new BadRequestException('Selling Price cannot exceed MRP.');
    }

    // Validate references if updated
    if (data.categoryId && data.categoryId !== product.categoryId) {
      await this.categoriesService.findOne(data.categoryId);
    }
    if (data.subCategoryId && data.subCategoryId !== product.subCategoryId) {
      await this.subCategoriesService.findOne(data.subCategoryId);
    }
    if (data.brandId && data.brandId !== product.brandId) {
      await this.brandsService.findOne(data.brandId);
    }

    // Reset status to DRAFT on edit
    const updateData = {
      ...data,
      status: 'DRAFT',
      approvedByAdminId: null,
      approvedAt: null,
      rejectedReason: null,
    };

    return this.productsRepository.update(id, updateData, vendorId);
  }

  async submitForApproval(id: string, vendorId: string) {
    const product = await this.findOneByVendor(id, vendorId);

    if (product.status !== 'DRAFT' && product.status !== 'REJECTED') {
      throw new BadRequestException(`Cannot submit product for approval. Current status is: ${product.status}`);
    }

    const updateData = {
      status: 'PENDING',
    };

    return this.productsRepository.update(id, updateData, vendorId);
  }

  async approve(id: string, adminId: string) {
    const product = await this.findOne(id);
    const updateData = {
      status: 'ACTIVE',
      approvedByAdminId: adminId,
      approvedAt: new Date(),
      rejectedReason: null,
    };
    return this.productsRepository.update(product.id, updateData, adminId);
  }

  async reject(id: string, adminId: string, reason: string) {
    const product = await this.findOne(id);
    const updateData = {
      status: 'REJECTED',
      approvedByAdminId: adminId,
      approvedAt: new Date(),
      rejectedReason: reason,
    };
    return this.productsRepository.update(product.id, updateData, adminId);
  }

  async suspend(id: string, adminId: string) {
    const product = await this.findOne(id);
    const updateData = {
      status: 'SUSPENDED',
      approvedByAdminId: adminId,
      approvedAt: new Date(),
    };
    return this.productsRepository.update(product.id, updateData, adminId);
  }

  async removeByVendor(id: string, vendorId: string) {
    await this.findOneByVendor(id, vendorId);
    return this.productsRepository.softDelete(id, vendorId);
  }

  async removeByAdmin(id: string, adminId: string) {
    await this.findOne(id);
    return this.productsRepository.softDelete(id, adminId);
  }
}
