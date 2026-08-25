import { Test, TestingModule } from '@nestjs/testing';
import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { CategoriesService } from './categories.service';
import { ICategoriesRepository } from '../interfaces/categories-repository.interface';
import { CategoryEntity } from '../entities/category.entity';

describe('CategoriesService', () => {
  let service: CategoriesService;
  let repository: jest.Mocked<ICategoriesRepository>;

  const mockCategory = new CategoryEntity({
    id: 'cat-1',
    name: 'Electronics',
    description: 'Tech gadgets',
    image: null,
    sortOrder: 1,
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
    const mockRepo: Partial<jest.Mocked<ICategoriesRepository>> = {
      create: jest.fn(),
      findMany: jest.fn(),
      findById: jest.fn(),
      findByName: jest.fn(),
      update: jest.fn(),
      softDelete: jest.fn(),
      countSubCategories: jest.fn(),
      findForAdmin: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CategoriesService,
        {
          provide: ICategoriesRepository,
          useValue: mockRepo,
        },
      ],
    }).compile();

    service = module.get<CategoriesService>(CategoriesService);
    repository = module.get(ICategoriesRepository);
  });

  describe('updateByVendor', () => {
    it('should reset status to PENDING and clear approval fields when vendor edits an APPROVED category', async () => {
      repository.findById.mockResolvedValue(mockCategory);
      repository.findByName.mockResolvedValue(null);
      repository.update.mockResolvedValue(mockCategory);

      await service.updateByVendor('cat-1', { name: 'Updated Electronics' }, 'vendor-1');

      expect(repository.update).toHaveBeenCalledWith(
        'cat-1',
        expect.objectContaining({
          name: 'Updated Electronics',
          status: 'PENDING',
          approvedByAdminId: null,
          approvedAt: null,
          rejectedReason: null,
        }),
        'vendor-1',
      );
    });

    it('should throw ForbiddenException if vendor does not own the category', async () => {
      repository.findById.mockResolvedValue(mockCategory);

      await expect(
        service.updateByVendor('cat-1', { name: 'Hack' }, 'other-vendor'),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('removeByVendor', () => {
    it('should soft delete category if vendor owns it and no subcategories exist', async () => {
      repository.findById.mockResolvedValue(mockCategory);
      repository.countSubCategories.mockResolvedValue(0);
      repository.softDelete.mockResolvedValue(mockCategory);

      await service.removeByVendor('cat-1', 'vendor-1');

      expect(repository.softDelete).toHaveBeenCalledWith('cat-1', 'vendor-1');
    });

    it('should throw ConflictException if category contains subcategories', async () => {
      repository.findById.mockResolvedValue(mockCategory);
      repository.countSubCategories.mockResolvedValue(2);

      await expect(service.removeByVendor('cat-1', 'vendor-1')).rejects.toThrow(
        'This category cannot be deleted because it contains sub-categories. Please delete all sub-categories first.',
      );
    });

    it('should throw ForbiddenException if vendor does not own the category', async () => {
      repository.findById.mockResolvedValue(mockCategory);

      await expect(service.removeByVendor('cat-1', 'other-vendor')).rejects.toThrow(ForbiddenException);
    });
  });

  describe('approve & reject', () => {
    it('should approve pending category and set status ACTIVE', async () => {
      repository.findById.mockResolvedValue(mockCategory);
      repository.update.mockResolvedValue(mockCategory);

      await service.approve('cat-1', 'admin-1');

      expect(repository.update).toHaveBeenCalledWith(
        'cat-1',
        expect.objectContaining({
          status: 'ACTIVE',
          approvedByAdminId: 'admin-1',
          rejectedReason: null,
        }),
        'admin-1',
      );
    });

    it('should reject pending category with reason', async () => {
      repository.findById.mockResolvedValue(mockCategory);
      repository.update.mockResolvedValue(mockCategory);

      await service.reject('cat-1', 'admin-1', 'Duplicate category');

      expect(repository.update).toHaveBeenCalledWith(
        'cat-1',
        expect.objectContaining({
          status: 'REJECTED',
          approvedByAdminId: 'admin-1',
          rejectedReason: 'Duplicate category',
        }),
        'admin-1',
      );
    });
  });
});
