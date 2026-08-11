import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { IProductsRepository } from '../interfaces/products-repository.interface';
import { CreateProductDto } from '../dto/create-product.dto';
import { UpdateProductDto } from '../dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(private readonly productsRepository: IProductsRepository) {}

  async create(data: CreateProductDto, vendorId: string) {
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

  async updateByVendor(id: string, data: UpdateProductDto, vendorId: string) {
    const product = await this.findOne(id);
    if (product.createdByVendorId !== vendorId) {
      throw new ForbiddenException('Access denied. You do not own this product.');
    }

    const updateData = {
      ...data,
      status: 'PENDING',
      approvedByAdminId: null,
      approvedAt: null,
      rejectedReason: null,
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
    return this.prismaUpdate(product.id, updateData, adminId);
  }

  private async prismaUpdate(id: string, updateData: any, userId: string) {
    return this.productsRepository.update(id, updateData, userId);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id);
    return this.productsRepository.softDelete(id, userId);
  }
}
