import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { ProductsService } from './products.service';
import { IProductsRepository } from '../interfaces/products-repository.interface';
import { ProductEntity } from '../entities/product.entity';
import { CategoriesService } from '../../master-data/categories/services/categories.service';
import { SubCategoriesService } from '../../master-data/sub-categories/services/sub-categories.service';
import { BrandsService } from '../../master-data/brands/services/brands.service';
import { PrismaService } from '../../../database/prisma.service';

describe('ProductsService', () => {
  let service: ProductsService;
  let repository: jest.Mocked<IProductsRepository>;

  const mockProduct: ProductEntity = new ProductEntity({
    id: 'prod-1',
    name: 'T-Shirt',
    description: 'Cotton T-Shirt',
    shortDescription: null,
    categoryId: 'cat-1',
    subCategoryId: 'sub-1',
    brandId: 'brand-1',
    sellingPrice: 100,
    mrp: 150,
    taxPercentage: 18,
    stock: 50,
    weight: null,
    length: null,
    width: null,
    height: null,
    sku: 'SKU-001',
    status: 'ACTIVE',
    image: null,
    vendorId: 'vendor-1',
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
    createdBy: 'vendor-1',
    updatedBy: 'vendor-1',
    createdByVendorId: 'vendor-1',
    approvedByAdminId: 'admin-1',
    approvedAt: new Date(),
    rejectedReason: null,
  });

  beforeEach(async () => {
    const mockRepo: Partial<jest.Mocked<IProductsRepository>> = {
      create: jest.fn(),
      findMany: jest.fn(),
      findById: jest.fn(),
      update: jest.fn(),
      softDelete: jest.fn(),
      findForAdmin: jest.fn(),
    };

    const mockCategoriesService = { findOne: jest.fn().mockResolvedValue({ id: 'cat-1' }) };
    const mockSubCategoriesService = { findOne: jest.fn().mockResolvedValue({ id: 'sub-1' }) };
    const mockBrandsService = { findOne: jest.fn().mockResolvedValue({ id: 'brand-1' }) };
    const mockPrismaService = {
      wishlist: {
        findMany: jest.fn().mockResolvedValue([]),
        findFirst: jest.fn().mockResolvedValue(null),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProductsService,
        { provide: IProductsRepository, useValue: mockRepo },
        { provide: CategoriesService, useValue: mockCategoriesService },
        { provide: SubCategoriesService, useValue: mockSubCategoriesService },
        { provide: BrandsService, useValue: mockBrandsService },
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<ProductsService>(ProductsService);
    repository = module.get(IProductsRepository);
  });

  describe('updateByVendor', () => {
    it('should reset status to PENDING when vendor edits an APPROVED (ACTIVE) product', async () => {
      repository.findById.mockResolvedValue(mockProduct);
      repository.update.mockResolvedValue({
        ...mockProduct,
        name: 'Updated T-Shirt',
        status: 'PENDING',
      });

      const result = await service.updateByVendor(
        'prod-1',
        { name: 'Updated T-Shirt' },
        'vendor-1',
      );

      expect(repository.update).toHaveBeenCalledWith(
        'prod-1',
        { name: 'Updated T-Shirt' },
        'vendor-1',
      );
      expect(result.status).toBe('PENDING');
    });

    it('should throw BadRequestException if sellingPrice > mrp', async () => {
      repository.findById.mockResolvedValue(mockProduct);

      await expect(
        service.updateByVendor(
          'prod-1',
          { sellingPrice: 200, mrp: 150 },
          'vendor-1',
        ),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('removeByVendor', () => {
    it('should soft delete product if vendor owns it', async () => {
      repository.findById.mockResolvedValue(mockProduct);
      repository.softDelete.mockResolvedValue({
        ...mockProduct,
        deletedAt: new Date(),
      });

      const result = await service.removeByVendor('prod-1', 'vendor-1');

      expect(repository.softDelete).toHaveBeenCalledWith('prod-1', 'vendor-1');
      expect(result.deletedAt).toBeDefined();
    });

    it('should throw ForbiddenException if vendor does not own product', async () => {
      repository.findById.mockResolvedValue(mockProduct);

      await expect(
        service.removeByVendor('prod-1', 'other-vendor'),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
