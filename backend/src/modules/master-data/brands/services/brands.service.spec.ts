import { Test, TestingModule } from '@nestjs/testing';
import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { BrandsService } from './brands.service';
import { IBrandsRepository } from '../interfaces/brands-repository.interface';
import { BrandEntity } from '../entities/brand.entity';

describe('BrandsService', () => {
  let service: BrandsService;
  let repository: jest.Mocked<IBrandsRepository>;

  const mockBrand = new BrandEntity({
    id: 'brand-1',
    name: 'Apple',
    logo: null,
    description: 'Tech company',
    status: 'ACTIVE',
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
    const mockRepo: Partial<jest.Mocked<IBrandsRepository>> = {
      create: jest.fn(),
      findMany: jest.fn(),
      findById: jest.fn(),
      findByName: jest.fn(),
      update: jest.fn(),
      softDelete: jest.fn(),
      countProducts: jest.fn(),
      findForAdmin: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BrandsService,
        {
          provide: IBrandsRepository,
          useValue: mockRepo,
        },
      ],
    }).compile();

    service = module.get<BrandsService>(BrandsService);
    repository = module.get(IBrandsRepository);
  });

  describe('updateByVendor', () => {
    it('should reset status to PENDING when vendor edits an APPROVED brand', async () => {
      repository.findById.mockResolvedValue(mockBrand);
      repository.findByName.mockResolvedValue(null);
      repository.update.mockResolvedValue(mockBrand);

      await service.updateByVendor('brand-1', { name: 'Apple Inc' }, 'vendor-1');

      expect(repository.update).toHaveBeenCalledWith(
        'brand-1',
        expect.objectContaining({
          name: 'Apple Inc',
          status: 'PENDING',
          approvedByAdminId: null,
          approvedAt: null,
        }),
        'vendor-1',
      );
    });

    it('should throw ForbiddenException if vendor does not own brand', async () => {
      repository.findById.mockResolvedValue(mockBrand);

      await expect(
        service.updateByVendor('brand-1', { name: 'Hack' }, 'other-vendor'),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('removeByVendor', () => {
    it('should soft delete brand if vendor owns it and no products exist', async () => {
      repository.findById.mockResolvedValue(mockBrand);
      repository.countProducts.mockResolvedValue(0);
      repository.softDelete.mockResolvedValue(mockBrand);

      await service.removeByVendor('brand-1', 'vendor-1');

      expect(repository.softDelete).toHaveBeenCalledWith('brand-1', 'vendor-1');
    });

    it('should throw ConflictException if brand is associated with products', async () => {
      repository.findById.mockResolvedValue(mockBrand);
      repository.countProducts.mockResolvedValue(5);

      await expect(service.removeByVendor('brand-1', 'vendor-1')).rejects.toThrow(
        'This brand cannot be deleted because it is being used by one or more products.',
      );
    });

    it('should throw ForbiddenException if vendor does not own brand', async () => {
      repository.findById.mockResolvedValue(mockBrand);

      await expect(service.removeByVendor('brand-1', 'other-vendor')).rejects.toThrow(ForbiddenException);
    });
  });
});
