import { Injectable, NotFoundException } from '@nestjs/common';
import { AddressRepository } from '../repositories/address.repository';
import { CreateAddressDto } from '../dto/create-address.dto';
import { UpdateAddressDto } from '../dto/update-address.dto';
import { CustomerAddressEntity } from '../entities/customer-address.entity';

@Injectable()
export class AddressService {
  constructor(private readonly addressRepository: AddressRepository) {}

  /**
   * Return all saved addresses for a customer, with the default address first.
   */
  async getCustomerAddresses(customerId: string): Promise<CustomerAddressEntity[]> {
    return this.addressRepository.findByCustomer(customerId);
  }

  /**
   * Return single address details ensuring customer ownership.
   */
  async getAddressById(customerId: string, addressId: string): Promise<CustomerAddressEntity> {
    const address = await this.addressRepository.findById(addressId);
    if (!address || address.customerId !== customerId) {
      throw new NotFoundException(`Address with ID "${addressId}" not found.`);
    }
    return address;
  }

  /**
   * Return the customer's default shipping address (or first available address).
   * Reusable for Checkout, Orders, and Order Tracking.
   */
  async getDefaultAddress(customerId: string): Promise<CustomerAddressEntity | null> {
    const defaultAddress = await this.addressRepository.findDefault(customerId);
    if (defaultAddress) {
      return defaultAddress;
    }
    const all = await this.addressRepository.findByCustomer(customerId);
    return all.length > 0 ? all[0] : null;
  }

  /**
   * Create a new address for a customer.
   * If customer has no existing addresses, this becomes default automatically.
   * If marked default, unsets default on all previous addresses.
   */
  async createAddress(customerId: string, dto: CreateAddressDto): Promise<CustomerAddressEntity> {
    const existingAddresses = await this.addressRepository.findByCustomer(customerId);
    const shouldBeDefault = dto.isDefault === true || existingAddresses.length === 0;

    if (shouldBeDefault) {
      await this.addressRepository.unsetCustomerDefaults(customerId);
    }

    return this.addressRepository.create(customerId, {
      ...dto,
      isDefault: shouldBeDefault,
    });
  }

  /**
   * Update an address.
   * Enforces customer ownership and handles default flag transitions.
   */
  async updateAddress(
    customerId: string,
    addressId: string,
    dto: UpdateAddressDto,
  ): Promise<CustomerAddressEntity> {
    const address = await this.getAddressById(customerId, addressId);

    if (dto.isDefault === true) {
      await this.addressRepository.unsetCustomerDefaults(customerId);
    } else if (dto.isDefault === false && address.isDefault) {
      // If unsetting default on current default address, promote another address if available
      const remaining = await this.addressRepository.findByCustomer(customerId);
      const other = remaining.find((a) => a.id !== addressId);
      if (other) {
        await this.addressRepository.setDefault(customerId, other.id);
      }
    }

    return this.addressRepository.update(addressId, dto);
  }

  /**
   * Delete an address.
   * If the deleted address was default, automatically promote another address to default (if available).
   */
  async deleteAddress(
    customerId: string,
    addressId: string,
  ): Promise<{ success: boolean; message: string; promotedDefaultId?: string }> {
    const address = await this.getAddressById(customerId, addressId);
    const wasDefault = address.isDefault;

    await this.addressRepository.delete(addressId);

    let promotedDefaultId: string | undefined = undefined;
    if (wasDefault) {
      const remaining = await this.addressRepository.findByCustomer(customerId);
      if (remaining.length > 0) {
        const newDefault = await this.addressRepository.setDefault(customerId, remaining[0].id);
        promotedDefaultId = newDefault.id;
      }
    }

    return {
      success: true,
      message: 'Address deleted successfully',
      ...(promotedDefaultId && { promotedDefaultId }),
    };
  }

  /**
   * Set a specific address as the customer's default address.
   */
  async setDefaultAddress(customerId: string, addressId: string): Promise<CustomerAddressEntity> {
    await this.getAddressById(customerId, addressId);
    return this.addressRepository.setDefault(customerId, addressId);
  }
}
