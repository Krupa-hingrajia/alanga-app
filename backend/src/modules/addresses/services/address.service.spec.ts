import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { AddressService } from './address.service';
import { AddressRepository } from '../repositories/address.repository';
import { AddressType } from '../dto/create-address.dto';
import { CustomerAddressEntity } from '../entities/customer-address.entity';

describe('AddressService', () => {
  let service: AddressService;
  let mockAddressRepository: any;

  const mockCustomerId = 'customer-uuid-1';
  const mockAddressId1 = 'address-uuid-1';
  const mockAddressId2 = 'address-uuid-2';

  const mockAddress1: CustomerAddressEntity = new CustomerAddressEntity({
    id: mockAddressId1,
    customerId: mockCustomerId,
    fullName: 'Pooja Hingrajia',
    mobileNumber: '9876543210',
    alternateMobile: '9123456789',
    addressLine1: 'Flat 402, Green Heights',
    addressLine2: 'SG Highway',
    landmark: 'Near YMCA Club',
    city: 'Ahmedabad',
    state: 'Gujarat',
    country: 'India',
    postalCode: '380015',
    addressType: 'HOME',
    isDefault: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
  });

  const mockAddress2: CustomerAddressEntity = new CustomerAddressEntity({
    id: mockAddressId2,
    customerId: mockCustomerId,
    fullName: 'Pooja Office',
    mobileNumber: '9876543210',
    alternateMobile: null,
    addressLine1: 'Office 101, Tech Park',
    addressLine2: null,
    landmark: null,
    city: 'Ahmedabad',
    state: 'Gujarat',
    country: 'India',
    postalCode: '380054',
    addressType: 'OFFICE',
    isDefault: false,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
  });

  beforeEach(async () => {
    mockAddressRepository = {
      findByCustomer: jest.fn(),
      findById: jest.fn(),
      findDefault: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      unsetCustomerDefaults: jest.fn(),
      setDefault: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AddressService,
        { provide: AddressRepository, useValue: mockAddressRepository },
      ],
    }).compile();

    service = module.get<AddressService>(AddressService);
  });

  describe('getCustomerAddresses', () => {
    it('should return list of addresses sorted with default first', async () => {
      mockAddressRepository.findByCustomer.mockResolvedValue([mockAddress1, mockAddress2]);

      const result = await service.getCustomerAddresses(mockCustomerId);

      expect(mockAddressRepository.findByCustomer).toHaveBeenCalledWith(mockCustomerId);
      expect(result).toHaveLength(2);
      expect(result[0].isDefault).toBe(true);
    });
  });

  describe('getAddressById', () => {
    it('should return address when owned by customer', async () => {
      mockAddressRepository.findById.mockResolvedValue(mockAddress1);

      const result = await service.getAddressById(mockCustomerId, mockAddressId1);

      expect(result).toEqual(mockAddress1);
    });

    it('should throw NotFoundException if address not found or belongs to another customer', async () => {
      mockAddressRepository.findById.mockResolvedValue({ ...mockAddress1, customerId: 'other-customer' });

      await expect(service.getAddressById(mockCustomerId, mockAddressId1)).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('getDefaultAddress', () => {
    it('should return default address when found', async () => {
      mockAddressRepository.findDefault.mockResolvedValue(mockAddress1);

      const result = await service.getDefaultAddress(mockCustomerId);

      expect(result).toEqual(mockAddress1);
    });

    it('should fall back to first address if no explicit default', async () => {
      mockAddressRepository.findDefault.mockResolvedValue(null);
      mockAddressRepository.findByCustomer.mockResolvedValue([mockAddress2]);

      const result = await service.getDefaultAddress(mockCustomerId);

      expect(result).toEqual(mockAddress2);
    });
  });

  describe('createAddress', () => {
    it('should automatically set isDefault to true for the first address', async () => {
      mockAddressRepository.findByCustomer.mockResolvedValue([]);
      mockAddressRepository.create.mockImplementation((_, data) => Promise.resolve(new CustomerAddressEntity(data)));

      const dto = {
        fullName: 'First Address',
        mobileNumber: '9999999999',
        addressLine1: 'Street 1',
        city: 'Surat',
        state: 'Gujarat',
        country: 'India',
        postalCode: '395007',
        isDefault: false,
      };

      const result = await service.createAddress(mockCustomerId, dto);

      expect(mockAddressRepository.unsetCustomerDefaults).toHaveBeenCalledWith(mockCustomerId);
      expect(result.isDefault).toBe(true);
    });

    it('should unset previous defaults when a new default address is created', async () => {
      mockAddressRepository.findByCustomer.mockResolvedValue([mockAddress1]);
      mockAddressRepository.create.mockImplementation((_, data) => Promise.resolve(new CustomerAddressEntity(data)));

      const dto = {
        fullName: 'New Default',
        mobileNumber: '9999999999',
        addressLine1: 'Street 2',
        city: 'Surat',
        state: 'Gujarat',
        country: 'India',
        postalCode: '395007',
        isDefault: true,
      };

      const result = await service.createAddress(mockCustomerId, dto);

      expect(mockAddressRepository.unsetCustomerDefaults).toHaveBeenCalledWith(mockCustomerId);
      expect(result.isDefault).toBe(true);
    });
  });

  describe('deleteAddress', () => {
    it('should promote another address to default if the deleted address was default', async () => {
      mockAddressRepository.findById.mockResolvedValue(mockAddress1);
      mockAddressRepository.delete.mockResolvedValue(mockAddress1);
      mockAddressRepository.findByCustomer.mockResolvedValue([mockAddress2]);
      mockAddressRepository.setDefault.mockResolvedValue({ ...mockAddress2, isDefault: true });

      const result = await service.deleteAddress(mockCustomerId, mockAddressId1);

      expect(mockAddressRepository.delete).toHaveBeenCalledWith(mockAddressId1);
      expect(mockAddressRepository.setDefault).toHaveBeenCalledWith(mockCustomerId, mockAddressId2);
      expect(result.success).toBe(true);
      expect(result.promotedDefaultId).toBe(mockAddressId2);
    });
  });

  describe('setDefaultAddress', () => {
    it('should mark address as default and unset previous defaults', async () => {
      mockAddressRepository.findById.mockResolvedValue(mockAddress2);
      mockAddressRepository.setDefault.mockResolvedValue({ ...mockAddress2, isDefault: true });

      const result = await service.setDefaultAddress(mockCustomerId, mockAddressId2);

      expect(mockAddressRepository.setDefault).toHaveBeenCalledWith(mockCustomerId, mockAddressId2);
      expect(result.isDefault).toBe(true);
    });
  });
});
