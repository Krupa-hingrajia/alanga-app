import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { InventoryService } from './inventory.service';
import { IInventoryRepository } from '../interfaces/inventory-repository.interface';
import { ProductsService } from './products.service';

describe('InventoryService', () => {
  let service: InventoryService;
  let mockInventoryRepository: any;
  let mockProductsService: any;

  const mockVendorId = 'vendor-uuid-1';
  const mockProductId = 'product-uuid-1';
  const mockVariantId = 'variant-uuid-1';

  const mockVariant = {
    id: mockVariantId,
    productId: mockProductId,
    sku: 'TSHIRT-BLK-XL',
    variantName: 'Black / XL',
    color: 'Black',
    size: 'XL',
    price: 999,
    stock: 20,
    currentStock: 20,
    minimumStock: 5,
    reservedStock: 2,
    inventoryStatus: 'IN_STOCK',
    lastStockUpdatedAt: new Date(),
    lastStockUpdatedBy: mockVendorId,
    status: 'ACTIVE',
  };

  const mockProduct = {
    id: mockProductId,
    name: 'T-Shirt',
    createdByVendorId: mockVendorId,
  };

  beforeEach(async () => {
    mockInventoryRepository = {
      findVariantById: jest.fn(),
      findVariantsByProductId: jest.fn(),
      updateInventory: jest.fn(),
      createHistoryEntry: jest.fn(),
      findHistoryByVariantId: jest.fn(),
    };

    mockProductsService = {
      findOneByVendor: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InventoryService,
        {
          provide: IInventoryRepository,
          useValue: mockInventoryRepository,
        },
        {
          provide: ProductsService,
          useValue: mockProductsService,
        },
      ],
    }).compile();

    service = module.get<InventoryService>(InventoryService);
  });

  describe('calculateInventoryStatus', () => {
    it('should return IN_STOCK when stock > 10', () => {
      expect(service.calculateInventoryStatus(15)).toBe('IN_STOCK');
    });

    it('should return LOW_STOCK when stock is between 1 and 10', () => {
      expect(service.calculateInventoryStatus(10)).toBe('LOW_STOCK');
      expect(service.calculateInventoryStatus(5)).toBe('LOW_STOCK');
      expect(service.calculateInventoryStatus(1)).toBe('LOW_STOCK');
    });

    it('should return OUT_OF_STOCK when stock is 0', () => {
      expect(service.calculateInventoryStatus(0)).toBe('OUT_OF_STOCK');
    });
  });

  describe('getProductInventory', () => {
    it('should return variant inventory DTOs when vendor owns product', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockInventoryRepository.findVariantsByProductId.mockResolvedValue([mockVariant]);

      const result = await service.getProductInventory(mockProductId, mockVendorId);

      expect(mockProductsService.findOneByVendor).toHaveBeenCalledWith(mockProductId, mockVendorId);
      expect(mockInventoryRepository.findVariantsByProductId).toHaveBeenCalledWith(mockProductId);
      expect(result).toHaveLength(1);
      expect(result[0].sku).toBe('TSHIRT-BLK-XL');
      expect(result[0].currentStock).toBe(20);
      expect(result[0].reservedStock).toBe(2);
      expect(result[0].availableStock).toBe(18); // 20 - 2
      expect(result[0].inventoryStatus).toBe('IN_STOCK');
    });

    it('should throw ForbiddenException if vendor does not own product', async () => {
      mockProductsService.findOneByVendor.mockRejectedValue(
        new ForbiddenException('Access denied. You do not own this product.'),
      );

      await expect(service.getProductInventory(mockProductId, mockVendorId)).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe('updateVariantInventory', () => {
    it('should successfully update stock, calculate status, and record history entry', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockInventoryRepository.findVariantById.mockResolvedValue(mockVariant);

      const updatedVariant = { ...mockVariant, currentStock: 8, stock: 8, inventoryStatus: 'LOW_STOCK' };
      mockInventoryRepository.updateInventory.mockResolvedValue(updatedVariant);
      mockInventoryRepository.createHistoryEntry.mockResolvedValue({ id: 'hist-1' });

      const dto = { currentStock: 8, minimumStock: 5, remarks: 'Manual stock adjustment' };

      const result = await service.updateVariantInventory(
        mockProductId,
        mockVariantId,
        mockVendorId,
        dto,
      );

      expect(mockProductsService.findOneByVendor).toHaveBeenCalledWith(mockProductId, mockVendorId);
      expect(mockInventoryRepository.updateInventory).toHaveBeenCalledWith(
        mockVariantId,
        { currentStock: 8, minimumStock: 5, inventoryStatus: 'LOW_STOCK' },
        mockVendorId,
      );
      expect(mockInventoryRepository.createHistoryEntry).toHaveBeenCalledWith({
        variantId: mockVariantId,
        previousStock: 20,
        newStock: 8,
        quantityChanged: -12,
        actionType: 'MANUAL_UPDATE',
        remarks: 'Manual stock adjustment',
        updatedBy: mockVendorId,
      });
      expect(result.currentStock).toBe(8);
      expect(result.inventoryStatus).toBe('LOW_STOCK');
    });

    it('should throw BadRequestException if current stock is negative', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockInventoryRepository.findVariantById.mockResolvedValue(mockVariant);

      await expect(
        service.updateVariantInventory(mockProductId, mockVariantId, mockVendorId, { currentStock: -5 }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if minimum stock is negative', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockInventoryRepository.findVariantById.mockResolvedValue(mockVariant);

      await expect(
        service.updateVariantInventory(mockProductId, mockVariantId, mockVendorId, { currentStock: 10, minimumStock: -2 }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw NotFoundException if variant does not exist', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockInventoryRepository.findVariantById.mockResolvedValue(null);

      await expect(
        service.updateVariantInventory(mockProductId, mockVariantId, mockVendorId, { currentStock: 10 }),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw BadRequestException if variant belongs to a different product', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockInventoryRepository.findVariantById.mockResolvedValue({
        ...mockVariant,
        productId: 'different-product-id',
      });

      await expect(
        service.updateVariantInventory(mockProductId, mockVariantId, mockVendorId, { currentStock: 10 }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('getInventoryHistory', () => {
    it('should return complete inventory history entries for variant', async () => {
      mockProductsService.findOneByVendor.mockResolvedValue(mockProduct);
      mockInventoryRepository.findVariantById.mockResolvedValue(mockVariant);

      const mockHistoryList = [
        {
          id: 'hist-1',
          variantId: mockVariantId,
          previousStock: 20,
          newStock: 8,
          quantityChanged: -12,
          actionType: 'MANUAL_UPDATE',
          remarks: 'Manual update',
          updatedBy: mockVendorId,
          createdAt: new Date(),
        },
      ];
      mockInventoryRepository.findHistoryByVariantId.mockResolvedValue(mockHistoryList);

      const result = await service.getInventoryHistory(mockProductId, mockVariantId, mockVendorId);

      expect(result).toHaveLength(1);
      expect(result[0].actionType).toBe('MANUAL_UPDATE');
      expect(result[0].quantityChanged).toBe(-12);
    });
  });
});
