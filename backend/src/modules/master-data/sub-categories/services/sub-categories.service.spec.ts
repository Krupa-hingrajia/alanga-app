import { Test, TestingModule } from '@nestjs/testing';
import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { SubCategoriesService } from './sub-categories.service';
import { ISubCategoriesRepository } from '../interfaces/sub-categories-repository.interface';
import { CategoriesService } from '../../categories/services/categories.service';
import { SubCategoryEntity } from '../entities/sub-category.entity';

describe('SubCategoriesService', () => {
  let service: SubCategoriesService;
  let repository: jest.Mocked<ISubCategoriesRepository>;

  const mockSubCategory = new SubCategoryEntity({
    id: 'sub-1',
    categoryId: 'cat-1',
    name: 'Smartphones',
    description: 'Mobile phones',
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
    const mockRepo: Partial<jest.Mocked<ISubCategoriesRepository>> = {
      create: jest.fn(),
      findMany: jest.fn(),
      findById: jest.fn(),
      findByNameAndCategory: jest.fn(),
      update: jest.fn(),
      softDelete: jest.fn(),
      countProducts: jest.fn(),
      findForAdmin: jest.fn(),
    };

    const mockCategoriesService = {
      findOne: jest.fn().mockResolvedValue({ id: 'cat-1' }),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SubCategoriesService,
        {
          provide: ISubCategoriesRepository,
          useValue: mockRepo,
        },
        {
          provide: CategoriesService,
          useValue: mockCategoriesService,
        },
      ],
    }).compile();

    service = module.get<SubCategoriesService>(SubCategoriesService);
    repository = module.get(ISubCategoriesRepository);
  });

  describe('updateByVendor', () => {
    it('should reset status to PENDING when vendor edits an APPROVED subcategory', async () => {
      repository.findById.mockResolvedValue(mockSubCategory);
      repository.findByNameAndCategory.mockResolvedValue(null);
      repository.update.mockResolvedValue(mockSubCategory);

      await service.updateByVendor('sub-1', { name: 'Updated Smartphones' }, 'vendor-1');

      expect(repository.update).toHaveBeenCalledWith(
        'sub-1',
        expect.objectContaining({
          name: 'Updated Smartphones',
          status: 'PENDING',
          approvedByAdminId: null,
          approvedAt: null,
        }),
        'vendor-1',
      );
    });

    it('should throw ForbiddenException if vendor does not own subcategory', async () => {
      repository.findById.mockResolvedValue(mockSubCategory);

      await expect(
        service.updateByVendor('sub-1', { name: 'Hack' }, 'other-vendor'),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('removeByVendor', () => {
    it('should soft delete subcategory if vendor owns it and no products exist', async () => {
      repository.findById.mockResolvedValue(mockSubCategory);
      repository.countProducts.mockResolvedValue(0);
      repository.softDelete.mockResolvedValue(mockSubCategory);

      await service.removeByVendor('sub-1', 'vendor-1');

      expect(repository.softDelete).toHaveBeenCalledWith('sub-1', 'vendor-1');
    });

    it('should throw ConflictException if subcategory contains products', async () => {
      repository.findById.mockResolvedValue(mockSubCategory);
      repository.countProducts.mockResolvedValue(3);

      await expect(service.removeByVendor('sub-1', 'vendor-1')).rejects.toThrow(
        'This sub-category cannot be deleted because it contains products. Please delete all products first.',
      );
    });

    it('should throw ForbiddenException if vendor does not own subcategory', async () => {
      repository.findById.mockResolvedValue(mockSubCategory);

      await expect(service.removeByVendor('sub-1', 'other-vendor')).rejects.toThrow(ForbiddenException);
    });
  });
});
