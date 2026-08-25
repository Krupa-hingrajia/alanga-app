import { Test, TestingModule } from '@nestjs/testing';
import {
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { ProductVariantsService } from './product-variants.service';
import { IProductVariantsRepository } from '../interfaces/product-variants-repository.interface';
import { IProductsRepository } from '../interfaces/products-repository.interface';
import { ProductVariantEntity } from '../entities/product-variant.entity';
import { ProductEntity } from '../entities/product.entity';

describe('ProductVariantsService', () => {
  let service: ProductVariantsService;
  let variantsRepository: jest.Mocked<IProductVariantsRepository>;
  let productsRepository: jest.Mocked<IProductsRepository>;

  const mockVendorId = 'vendor-123';
  const mockProductId = 'product-123';

  const mockProduct = new ProductEntity({
    id: mockProductId,
    name: 'Sample iPhone 15',
    vendorId: mockVendorId,
    createdByVendorId: mockVendorId,
    sku: 'IPHONE15-MAIN',
  } as any);

  const mockVariant = new ProductVariantEntity({
    id: 'variant-1',
    productId: mockProductId,
    sku: 'IPHONE15-128-BLK',
    variantName: '128 GB / Black',
    color: 'Black',
    size: null,
    storage: '128 GB',
    price: 79999,
    stock: 20,
    status: 'ACTIVE',
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
  });

  beforeEach(async () => {
    const mockVariantsRepo = {
      create: jest.fn(),
      findByProductId: jest.fn(),
      findById: jest.fn(),
      findBySku: jest.fn(),
      update: jest.fn(),
      softDelete: jest.fn(),
    };

    const mockProductsRepo = {
      findById: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProductVariantsService,
        { provide: IProductVariantsRepository, useValue: mockVariantsRepo },
        { provide: IProductsRepository, useValue: mockProductsRepo },
      ],
    }).compile();

    service = module.get<ProductVariantsService>(ProductVariantsService);
    variantsRepository = module.get(IProductVariantsRepository);
    productsRepository = module.get(IProductsRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createVariant', () => {
    it('should create a variant successfully', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      variantsRepository.findBySku.mockResolvedValue(null);
      variantsRepository.create.mockResolvedValue(mockVariant);

      const dto = {
        variantName: '128 GB / Black',
        sku: 'IPHONE15-128-BLK',
        price: 79999,
        stock: 20,
        color: 'Black',
        storage: '128 GB',
      };

      const result = await service.createVariant(mockProductId, mockVendorId, dto);
      expect(result).toEqual(mockVariant);
      expect(productsRepository.findById).toHaveBeenCalledWith(mockProductId);
      expect(variantsRepository.create).toHaveBeenCalledWith(mockProductId, dto);
    });

    it('should throw NotFoundException if product does not exist', async () => {
      productsRepository.findById.mockResolvedValue(null);

      await expect(
        service.createVariant(mockProductId, mockVendorId, {
          variantName: 'Test',
          sku: 'TEST-SKU',
          price: 100,
          stock: 10,
        }),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw ForbiddenException if vendor does not own product', async () => {
      productsRepository.findById.mockResolvedValue(
        new ProductEntity({ id: mockProductId, vendorId: 'other-vendor' } as any),
      );

      await expect(
        service.createVariant(mockProductId, mockVendorId, {
          variantName: 'Test',
          sku: 'TEST-SKU',
          price: 100,
          stock: 10,
        }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw BadRequestException if price is negative', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);

      await expect(
        service.createVariant(mockProductId, mockVendorId, {
          variantName: 'Test',
          sku: 'TEST-SKU',
          price: -10,
          stock: 10,
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if stock is negative', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);

      await expect(
        service.createVariant(mockProductId, mockVendorId, {
          variantName: 'Test',
          sku: 'TEST-SKU',
          price: 100,
          stock: -5,
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if SKU already exists', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      variantsRepository.findBySku.mockResolvedValue(mockVariant);

      await expect(
        service.createVariant(mockProductId, mockVendorId, {
          variantName: 'Test',
          sku: 'IPHONE15-128-BLK',
          price: 100,
          stock: 10,
        }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('getVariantsByProductId', () => {
    it('should return list of variants', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      variantsRepository.findByProductId.mockResolvedValue([mockVariant]);

      const result = await service.getVariantsByProductId(mockProductId, mockVendorId);
      expect(result).toEqual([mockVariant]);
    });

    it('should throw ForbiddenException if vendor does not own product', async () => {
      productsRepository.findById.mockResolvedValue(
        new ProductEntity({ id: mockProductId, vendorId: 'other-vendor' } as any),
      );

      await expect(
        service.getVariantsByProductId(mockProductId, mockVendorId),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('updateVariant', () => {
    it('should update variant successfully', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      variantsRepository.findById.mockResolvedValue(mockVariant);
      variantsRepository.update.mockResolvedValue({
        ...mockVariant,
        price: 74999,
      } as any);

      const dto = { price: 74999 };
      const result = await service.updateVariant(mockProductId, 'variant-1', mockVendorId, dto);
      expect(result.price).toBe(74999);
    });

    it('should throw NotFoundException if variant does not exist', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      variantsRepository.findById.mockResolvedValue(null);

      await expect(
        service.updateVariant(mockProductId, 'non-existent', mockVendorId, { price: 100 }),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw BadRequestException if updating to an existing SKU owned by another variant', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      variantsRepository.findById.mockResolvedValue(mockVariant);
      variantsRepository.findBySku.mockResolvedValue(
        new ProductVariantEntity({ id: 'variant-2', sku: 'OTHER-SKU' } as any),
      );

      await expect(
        service.updateVariant(mockProductId, 'variant-1', mockVendorId, { sku: 'OTHER-SKU' }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('deleteVariant', () => {
    it('should soft delete variant successfully', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      variantsRepository.findById.mockResolvedValue(mockVariant);
      variantsRepository.softDelete.mockResolvedValue(mockVariant);

      const result = await service.deleteVariant(mockProductId, 'variant-1', mockVendorId);
      expect(result).toEqual({ message: 'Product variant deleted successfully.' });
      expect(variantsRepository.softDelete).toHaveBeenCalledWith('variant-1');
    });

    it('should throw NotFoundException if variant to delete does not exist', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      variantsRepository.findById.mockResolvedValue(null);

      await expect(
        service.deleteVariant(mockProductId, 'non-existent', mockVendorId),
      ).rejects.toThrow(NotFoundException);
    });
  });
});
