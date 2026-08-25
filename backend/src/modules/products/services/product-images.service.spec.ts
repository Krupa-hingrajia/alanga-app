import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { ProductImagesService } from './product-images.service';
import { IProductImagesRepository } from '../interfaces/product-images-repository.interface';
import { IProductsRepository } from '../interfaces/products-repository.interface';
import { ProductImageEntity } from '../entities/product-image.entity';
import { ProductEntity } from '../entities/product.entity';

describe('ProductImagesService', () => {
  let service: ProductImagesService;
  let productImagesRepository: jest.Mocked<IProductImagesRepository>;
  let productsRepository: jest.Mocked<IProductsRepository>;

  const mockVendorId = 'vendor-uuid-123';
  const mockProductId = 'product-uuid-456';
  const mockProduct = new ProductEntity({
    id: mockProductId,
    name: 'Test Product',
    vendorId: mockVendorId,
    createdByVendorId: mockVendorId,
    sellingPrice: 100,
    mrp: 150,
    status: 'ACTIVE',
  } as any);

  const mockImage1 = new ProductImageEntity({
    id: 'img-1',
    productId: mockProductId,
    imageUrl: '/uploads/products/img1.jpg',
    isPrimary: true,
    displayOrder: 0,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
  });

  const mockImage2 = new ProductImageEntity({
    id: 'img-2',
    productId: mockProductId,
    imageUrl: '/uploads/products/img2.jpg',
    isPrimary: false,
    displayOrder: 1,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
  });

  beforeEach(async () => {
    const mockImagesRepo = {
      createMany: jest.fn(),
      findByProductId: jest.fn(),
      findById: jest.fn(),
      countActiveByProductId: jest.fn(),
      getMaxDisplayOrder: jest.fn(),
      setPrimaryImage: jest.fn(),
      softDelete: jest.fn(),
      findFirstAvailable: jest.fn(),
      updateDisplayOrders: jest.fn(),
    };

    const mockProdsRepo = {
      create: jest.fn(),
      findMany: jest.fn(),
      findById: jest.fn(),
      update: jest.fn(),
      softDelete: jest.fn(),
      findForAdmin: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProductImagesService,
        { provide: IProductImagesRepository, useValue: mockImagesRepo },
        { provide: IProductsRepository, useValue: mockProdsRepo },
      ],
    }).compile();

    service = module.get<ProductImagesService>(ProductImagesService);
    productImagesRepository = module.get(IProductImagesRepository);
    productsRepository = module.get(IProductsRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('uploadImages', () => {
    it('should upload images and automatically set the first image as primary if 0 existing images', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      productImagesRepository.countActiveByProductId.mockResolvedValue(0);
      productImagesRepository.getMaxDisplayOrder.mockResolvedValue(0);
      productImagesRepository.createMany.mockResolvedValue([mockImage1]);
      productsRepository.update.mockResolvedValue(mockProduct);

      const mockFiles = [
        {
          originalname: 'test.jpg',
          mimetype: 'image/jpeg',
          size: 1024 * 1024,
          filename: 'test.jpg',
          path: 'uploads/products/test.jpg',
        } as Express.Multer.File,
      ];

      const result = await service.uploadImages(mockProductId, mockVendorId, mockFiles);

      expect(productsRepository.findById).toHaveBeenCalledWith(mockProductId);
      expect(productImagesRepository.createMany).toHaveBeenCalledWith(mockProductId, [
        { imageUrl: '/uploads/products/test.jpg', isPrimary: true, displayOrder: 0, productVariantId: null },
      ], undefined);
      expect(productsRepository.update).toHaveBeenCalledWith(mockProductId, { image: mockImage1.imageUrl }, mockVendorId);
      expect(result).toEqual([mockImage1]);
    });

    it('should throw ForbiddenException if vendor does not own product', async () => {
      productsRepository.findById.mockResolvedValue({
        ...mockProduct,
        vendorId: 'other-vendor',
        createdByVendorId: 'other-vendor',
      } as any);

      await expect(
        service.uploadImages(mockProductId, mockVendorId, [], ['http://example.com/img.png']),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw BadRequestException if file exceeds 5MB size limit', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      const largeFile = [
        {
          originalname: 'large.jpg',
          mimetype: 'image/jpeg',
          size: 6 * 1024 * 1024, // 6 MB
        } as Express.Multer.File,
      ];

      await expect(service.uploadImages(mockProductId, mockVendorId, largeFile)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should throw BadRequestException if file format is unsupported', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      const invalidFile = [
        {
          originalname: 'doc.pdf',
          mimetype: 'application/pdf',
          size: 1024,
        } as Express.Multer.File,
      ];

      await expect(service.uploadImages(mockProductId, mockVendorId, invalidFile)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should throw BadRequestException if upload exceeds 10 images limit', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      productImagesRepository.countActiveByProductId.mockResolvedValue(9);

      const files = [
        { originalname: 'a.jpg', mimetype: 'image/jpeg', size: 100 } as Express.Multer.File,
        { originalname: 'b.jpg', mimetype: 'image/jpeg', size: 100 } as Express.Multer.File,
      ];

      await expect(service.uploadImages(mockProductId, mockVendorId, files)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('getProductImages', () => {
    it('should return active product images sorted', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      productImagesRepository.findByProductId.mockResolvedValue([mockImage1, mockImage2]);

      const result = await service.getProductImages(mockProductId, mockVendorId);
      expect(result).toEqual([mockImage1, mockImage2]);
    });
  });

  describe('setPrimaryImage', () => {
    it('should set selected image as primary and update product single image field', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      productImagesRepository.findById.mockResolvedValue(mockImage2);
      productImagesRepository.setPrimaryImage.mockResolvedValue({ ...mockImage2, isPrimary: true });
      productsRepository.update.mockResolvedValue(mockProduct);

      const result = await service.setPrimaryImage(mockProductId, 'img-2', mockVendorId);

      expect(productImagesRepository.setPrimaryImage).toHaveBeenCalledWith(mockProductId, 'img-2', undefined);
      expect(productsRepository.update).toHaveBeenCalledWith(mockProductId, { image: mockImage2.imageUrl }, mockVendorId);
      expect(result.isPrimary).toBe(true);
    });

    it('should throw NotFoundException if image does not belong to product', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      productImagesRepository.findById.mockResolvedValue({ ...mockImage1, productId: 'other-prod' });

      await expect(service.setPrimaryImage(mockProductId, 'img-1', mockVendorId)).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('deleteImage', () => {
    it('should soft delete non-primary image without changing primary', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      productImagesRepository.findById.mockResolvedValue(mockImage2); // isPrimary: false
      productImagesRepository.softDelete.mockResolvedValue({ ...mockImage2, deletedAt: new Date() });

      const result = await service.deleteImage(mockProductId, 'img-2', mockVendorId);

      expect(productImagesRepository.softDelete).toHaveBeenCalledWith('img-2');
      expect(productImagesRepository.findFirstAvailable).not.toHaveBeenCalled();
      expect(result).toEqual({ message: 'Product image deleted successfully.' });
    });

    it('should automatically set next available image as primary when primary image is deleted', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      productImagesRepository.findById.mockResolvedValue(mockImage1); // isPrimary: true
      productImagesRepository.softDelete.mockResolvedValue({ ...mockImage1, deletedAt: new Date() });
      productImagesRepository.findFirstAvailable.mockResolvedValue(mockImage2);
      productImagesRepository.setPrimaryImage.mockResolvedValue({ ...mockImage2, isPrimary: true });
      productsRepository.update.mockResolvedValue(mockProduct);

      const result = await service.deleteImage(mockProductId, 'img-1', mockVendorId);

      expect(productImagesRepository.softDelete).toHaveBeenCalledWith('img-1');
      expect(productImagesRepository.findFirstAvailable).toHaveBeenCalledWith(mockProductId, undefined);
      expect(productImagesRepository.setPrimaryImage).toHaveBeenCalledWith(mockProductId, 'img-2', undefined);
      expect(productsRepository.update).toHaveBeenCalledWith(mockProductId, { image: mockImage2.imageUrl }, mockVendorId);
      expect(result).toEqual({ message: 'Product image deleted successfully.' });
    });

    it('should clear product image to null if primary image is deleted and no other images remain', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      productImagesRepository.findById.mockResolvedValue(mockImage1); // isPrimary: true
      productImagesRepository.softDelete.mockResolvedValue({ ...mockImage1, deletedAt: new Date() });
      productImagesRepository.findFirstAvailable.mockResolvedValue(null);
      productsRepository.update.mockResolvedValue(mockProduct);

      const result = await service.deleteImage(mockProductId, 'img-1', mockVendorId);

      expect(productImagesRepository.findFirstAvailable).toHaveBeenCalledWith(mockProductId, undefined);
      expect(productsRepository.update).toHaveBeenCalledWith(mockProductId, { image: null }, mockVendorId);
      expect(result).toEqual({ message: 'Product image deleted successfully.' });
    });
  });

  describe('reorderImages', () => {
    it('should update image display orders', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      productImagesRepository.findByProductId.mockResolvedValue([mockImage1, mockImage2]);
      productImagesRepository.updateDisplayOrders.mockResolvedValue([
        { ...mockImage2, displayOrder: 0 },
        { ...mockImage1, displayOrder: 1 },
      ]);

      const reorderDto = {
        images: [
          { id: 'img-2', displayOrder: 0 },
          { id: 'img-1', displayOrder: 1 },
        ],
      };

      const result = await service.reorderImages(mockProductId, reorderDto, mockVendorId);

      expect(productImagesRepository.updateDisplayOrders).toHaveBeenCalledWith(mockProductId, reorderDto.images);
      expect(result[0].id).toBe('img-2');
    });

    it('should throw BadRequestException if an image ID does not belong to product', async () => {
      productsRepository.findById.mockResolvedValue(mockProduct);
      productImagesRepository.findByProductId.mockResolvedValue([mockImage1]);

      const reorderDto = {
        images: [{ id: 'non-existent-img', displayOrder: 0 }],
      };

      await expect(service.reorderImages(mockProductId, reorderDto, mockVendorId)).rejects.toThrow(
        BadRequestException,
      );
    });
  });
});
