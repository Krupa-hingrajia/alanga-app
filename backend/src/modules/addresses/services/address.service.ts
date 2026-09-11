import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { AddressRepository } from '../repositories/address.repository';
import { CreateAddressDto } from '../dto/create-address.dto';
import { UpdateAddressDto } from '../dto/update-address.dto';

@Injectable()
export class AddressService {
  constructor(private readonly addressRepository: AddressRepository) {}

  async getCustomerAddresses(customerId: string) {
    return this.addressRepository.findByCustomer(customerId);
  }

  async getAddressById(customerId: string, addressId: string) {
    const address = await this.addressRepository.findById(addressId);
    if (!address || address.customerId !== customerId) {
      throw new NotFoundException(`Address with ID "${addressId}" not found.`);
    }
    return address;
  }

  async createAddress(customerId: string, dto: CreateAddressDto) {
    const existingAddresses = await this.addressRepository.findByCustomer(customerId);
    const shouldBeDefault = dto.isDefault || existingAddresses.length === 0;

    if (shouldBeDefault) {
      await this.addressRepository.unsetCustomerDefaults(customerId);
    }

    return this.addressRepository.create(customerId, {
      ...dto,
      isDefault: shouldBeDefault,
    });
  }

  async updateAddress(customerId: string, addressId: string, dto: UpdateAddressDto) {
    const address = await this.addressRepository.findById(addressId);
    if (!address || address.customerId !== customerId) {
      throw new NotFoundException(`Address with ID "${addressId}" not found.`);
    }

    if (dto.isDefault) {
      await this.addressRepository.unsetCustomerDefaults(customerId);
    }

    return this.addressRepository.update(addressId, dto);
  }

  async deleteAddress(customerId: string, addressId: string) {
    const address = await this.addressRepository.findById(addressId);
    if (!address || address.customerId !== customerId) {
      throw new NotFoundException(`Address with ID "${addressId}" not found.`);
    }

    const isWasDefault = address.isDefault;
    await this.addressRepository.delete(addressId);

    // If deleted address was default, set another remaining address as default if available
    if (isWasDefault) {
      const remaining = await this.addressRepository.findByCustomer(customerId);
      if (remaining.length > 0) {
        await this.addressRepository.setDefault(customerId, remaining[0].id);
      }
    }

    return { success: true, message: 'Address deleted successfully' };
  }

  async setDefaultAddress(customerId: string, addressId: string) {
    const address = await this.addressRepository.findById(addressId);
    if (!address || address.customerId !== customerId) {
      throw new NotFoundException(`Address with ID "${addressId}" not found.`);
    }

    return this.addressRepository.setDefault(customerId, addressId);
  }
}
