import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { WishlistService } from './wishlist.service';
import { IWishlistRepository } from '../interfaces/wishlist-repository.interface';
import { PrismaService } from '../../../database/prisma.service';

describe('WishlistService', () => {
  let service: WishlistService;
  let mockWishlistRepository: any;
  let mockPrismaService: any;

  const mockCustomerId = 'customer-uuid-1';
  const mockProductId = 'product-uuid-1';
  const mockVariantId = 'variant-uuid-1';

  const mockProduct = {
    id: mockProductId,
    name: 'Samsung Galaxy S25 Ultra',
    sellingPrice: 120000,
    mrp: 130000,
    stock: 10,
    productImages: [{ imageUrl: 'https://example.com/s25.jpg' }],
    shipping: {
      shippingCharge: 0,
      isFreeShipping: true,
      estimatedDeliveryMinDays: 2,
      estimatedDeliveryMaxDays: 5,
      codAvailable: true,
    },
  };

  const mockVariant = {
    id: mockVariantId,
    productId: mockProductId,
    variantName: '512 GB / Titanium Black',
    price: 125000,
    stock: 8,
  };

  const mockWishlistEntity = {
    id: 'wishlist-uuid-1',
    customerId: mockCustomerId,
    productId: mockProductId,
    productVariantId: mockVariantId,
    createdAt: new Date(),
    updatedAt: new Date(),
    product: mockProduct,
    productVariant: mockVariant,
  };

  beforeEach(async () => {
    mockWishlistRepository = {
      findByCustomer: jest.fn(),
      findExisting: jest.fn(),
      findByCustomerAndProduct: jest.fn(),
      findById: jest.fn(),
      create: jest.fn(),
      updateVariant: jest.fn(),
      delete: jest.fn(),
    };

    mockPrismaService = {
      product: {
        findFirst: jest.fn(),
      },
      productVariant: {
        findFirst: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WishlistService,
        {
          provide: IWishlistRepository,
          useValue: mockWishlistRepository,
        },
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
      ],
    }).compile();

    service = module.get<WishlistService>(WishlistService);
  });

  describe('toggleWishlist', () => {
    it('should add to wishlist if product is not currently wishlisted', async () => {
      mockPrismaService.product.findFirst.mockResolvedValue(mockProduct);
      mockWishlistRepository.findByCustomerAndProduct.mockResolvedValue(null);
      mockWishlistRepository.create.mockResolvedValue(mockWishlistEntity);

      const result = await service.toggleWishlist(mockCustomerId, { productId: mockProductId });

      expect(mockWishlistRepository.create).toHaveBeenCalledWith(mockCustomerId, mockProductId, undefined);
      expect(result.isWishlisted).toBe(true);
      expect(result.message).toBe('Product added to Wishlist.');
    });

    it('should remove from wishlist if same variant is currently wishlisted', async () => {
      mockPrismaService.product.findFirst.mockResolvedValue(mockProduct);
      mockPrismaService.productVariant.findFirst.mockResolvedValue(mockVariant);
      mockWishlistRepository.findByCustomerAndProduct.mockResolvedValue(mockWishlistEntity);
      mockWishlistRepository.delete.mockResolvedValue(undefined);

      const result = await service.toggleWishlist(mockCustomerId, { productId: mockProductId, productVariantId: mockVariantId });

      expect(mockWishlistRepository.delete).toHaveBeenCalledWith(mockWishlistEntity.id);
      expect(result.isWishlisted).toBe(false);
      expect(result.message).toBe('Product removed from Wishlist.');
    });

    it('should update variant in place when different variant is selected', async () => {
      mockPrismaService.product.findFirst.mockResolvedValue(mockProduct);
      mockPrismaService.productVariant.findFirst.mockResolvedValue({ ...mockVariant, id: 'variant-uuid-2' });
      mockWishlistRepository.findByCustomerAndProduct.mockResolvedValue(mockWishlistEntity);
      mockWishlistRepository.updateVariant.mockResolvedValue({ ...mockWishlistEntity, productVariantId: 'variant-uuid-2' });

      const result = await service.toggleWishlist(mockCustomerId, { productId: mockProductId, productVariantId: 'variant-uuid-2' });

      expect(mockWishlistRepository.updateVariant).toHaveBeenCalledWith(mockWishlistEntity.id, 'variant-uuid-2');
      expect(result.isWishlisted).toBe(true);
      expect(result.message).toBe('Wishlist variant updated.');
    });
  });

  describe('addToWishlist', () => {
    it('should successfully add product variant to wishlist', async () => {
      mockPrismaService.product.findFirst.mockResolvedValue(mockProduct);
      mockPrismaService.productVariant.findFirst.mockResolvedValue(mockVariant);
      mockWishlistRepository.findByCustomerAndProduct.mockResolvedValue(null);
      mockWishlistRepository.create.mockResolvedValue(mockWishlistEntity);

      const dto = { productId: mockProductId, productVariantId: mockVariantId };
      const result = await service.addToWishlist(mockCustomerId, dto);

      expect(mockPrismaService.product.findFirst).toHaveBeenCalledWith({ where: { id: mockProductId, deletedAt: null } });
      expect(mockPrismaService.productVariant.findFirst).toHaveBeenCalledWith({
        where: { id: mockVariantId, productId: mockProductId, deletedAt: null },
      });
      expect(mockWishlistRepository.create).toHaveBeenCalledWith(mockCustomerId, mockProductId, mockVariantId);
      expect(result.productId).toBe(mockProductId);
      expect(result.sellingPrice).toBe(125000);
      expect(result.stockStatus).toBe('IN_STOCK');
    });

    it('should throw NotFoundException if product does not exist', async () => {
      mockPrismaService.product.findFirst.mockResolvedValue(null);

      await expect(
        service.addToWishlist(mockCustomerId, { productId: mockProductId }),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw BadRequestException if variant does not belong to product', async () => {
      mockPrismaService.product.findFirst.mockResolvedValue(mockProduct);
      mockPrismaService.productVariant.findFirst.mockResolvedValue(null);

      await expect(
        service.addToWishlist(mockCustomerId, { productId: mockProductId, productVariantId: mockVariantId }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('getCustomerWishlist', () => {
    it('should return array of formatted wishlist items', async () => {
      mockWishlistRepository.findByCustomer.mockResolvedValue([mockWishlistEntity]);

      const result = await service.getCustomerWishlist(mockCustomerId);

      expect(result.length).toBe(1);
      expect(result[0].productId).toBe(mockProductId);
      expect(result[0].stockStatus).toBe('IN_STOCK');
      expect(result[0].shipping.isFreeShipping).toBe(true);
    });
  });

  describe('checkWishlist', () => {
    it('should return isWishlisted: true when item exists in wishlist', async () => {
      mockWishlistRepository.findByCustomerAndProduct.mockResolvedValue(mockWishlistEntity);

      const result = await service.checkWishlist(mockCustomerId, mockProductId, mockVariantId);

      expect(result.isWishlisted).toBe(true);
      expect(result.wishlistId).toBe('wishlist-uuid-1');
    });

    it('should return isWishlisted: false when item is not in wishlist', async () => {
      mockWishlistRepository.findByCustomerAndProduct.mockResolvedValue(null);

      const result = await service.checkWishlist(mockCustomerId, mockProductId);

      expect(result.isWishlisted).toBe(false);
      expect(result.wishlistId).toBeNull();
    });
  });

  describe('removeFromWishlist', () => {
    it('should remove wishlist item when customer owns it', async () => {
      mockWishlistRepository.findById.mockResolvedValue(mockWishlistEntity);
      mockWishlistRepository.delete.mockResolvedValue(undefined);

      const result = await service.removeFromWishlist(mockCustomerId, 'wishlist-uuid-1');

      expect(mockWishlistRepository.delete).toHaveBeenCalledWith('wishlist-uuid-1');
      expect(result.success).toBe(true);
    });

    it('should throw ForbiddenException if customer does not own wishlist item', async () => {
      mockWishlistRepository.findById.mockResolvedValue({ ...mockWishlistEntity, customerId: 'other-customer' });

      await expect(
        service.removeFromWishlist(mockCustomerId, 'wishlist-uuid-1'),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
