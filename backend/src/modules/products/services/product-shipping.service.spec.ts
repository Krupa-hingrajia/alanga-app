import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException, BadRequestException, ConflictException, ForbiddenException } from '@nestjs/common';
import { ProductShippingService } from './product-shipping.service';
import { IProductShippingRepository } from '../interfaces/product-shipping-repository.interface';
import { ProductsService } from './products.service';

describe('ProductShippingService', () => {
  let service: ProductShippingService;
  let mockShippingRepository: any;
  let mockProductsService: any;

  const mockVendorId = 'vendor-uuid-1';
  const mockProductId = 'product-uuid-1';

  const mockShippingEntity = {
    id: 'shipping-uuid-1',
    productId: mockProductId,
    weight: 0.5,
    weightUnit: 'kg',
    length: 20,
    width: 15,
    height: 10,
    dimensionUnit: 'cm',
    shippingCharge: 50,
    isFreeShipping: false,
    freeShippingAboveAmount: 499,
    estimatedDeliveryMinDays: 3,
    estimatedDeliveryMaxDays: 7,
    codAvailable: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockProduct = {
    id: mockProductId,
    name: 'T-Shirt',
    createdByVendorId: mockVendorId,
  };

  beforeEach(async () => {
    mockShippingRepository = {
      findByProductId: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      upsert: jest.fn(),
    };

    mockProductsService = {
      findOneByVendor: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProductShippingService,
        {
          provide: IProductShippingRepository,
          useValue: mockShippingRepository,
        },
        {
          provide: ProductsService,
          useValue: mockProductsService,
        },
      ],
    }).compile();

    service = module.get<ProductShippingService>(ProductShippingService);
  });

  describe('createShipping', () => {
    it('should successfully create shipping configuration when vendor owns product', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockShippingRepository.findByProductId.mockResolvedValue(null);
      mockShippingRepository.create.mockResolvedValue(mockShippingEntity);

      const dto = {
        weight: 0.5,
        weightUnit: 'kg',
        shippingCharge: 50,
        estimatedDeliveryMinDays: 3,
        estimatedDeliveryMaxDays: 7,
      };

      const result = await service.createShipping(mockProductId, mockVendorId, dto);

      expect(mockProductsService.findOneByVendor).toHaveBeenCalledWith(mockProductId, mockVendorId);
      expect(mockShippingRepository.create).toHaveBeenCalledWith(mockProductId, dto);
      expect(result.shippingCharge).toBe(50);
      expect(result.estimatedDeliveryLabel).toBe('3-7 Days');
    });

    it('should throw ConflictException if shipping configuration already exists', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockShippingRepository.findByProductId.mockResolvedValue(mockShippingEntity);

      await expect(
        service.createShipping(mockProductId, mockVendorId, { shippingCharge: 50 }),
      ).rejects.toThrow(ConflictException);
    });

    it('should throw BadRequestException if weight is negative', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockShippingRepository.findByProductId.mockResolvedValue(null);

      await expect(
        service.createShipping(mockProductId, mockVendorId, { weight: -1 }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if estimatedDeliveryMaxDays < minDays', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockShippingRepository.findByProductId.mockResolvedValue(null);

      await expect(
        service.createShipping(mockProductId, mockVendorId, {
          estimatedDeliveryMinDays: 5,
          estimatedDeliveryMaxDays: 2,
        }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('getShipping', () => {
    it('should return shipping configuration when found', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockShippingRepository.findByProductId.mockResolvedValue(mockShippingEntity);

      const result = await service.getShipping(mockProductId, mockVendorId);

      expect(result.productId).toBe(mockProductId);
      expect(result.codAvailable).toBe(true);
    });

    it('should throw NotFoundException if shipping configuration does not exist', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockShippingRepository.findByProductId.mockResolvedValue(null);

      await expect(service.getShipping(mockProductId, mockVendorId)).rejects.toThrow(NotFoundException);
    });
  });

  describe('updateShipping', () => {
    it('should upsert shipping configuration successfully', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockShippingRepository.findByProductId.mockResolvedValue(mockShippingEntity);
      mockShippingRepository.upsert.mockResolvedValue({ ...mockShippingEntity, shippingCharge: 0, isFreeShipping: true });

      const dto = { isFreeShipping: true, shippingCharge: 0 };
      const result = await service.updateShipping(mockProductId, mockVendorId, dto);

      expect(mockShippingRepository.upsert).toHaveBeenCalledWith(mockProductId, dto);
      expect(result.isFreeShipping).toBe(true);
      expect(result.shippingCharge).toBe(0);
    });
  });
});
