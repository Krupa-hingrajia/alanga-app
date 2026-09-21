import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { IAddressRepository } from '../interfaces/address-repository.interface';
import { CreateAddressDto } from '../dto/create-address.dto';
import { UpdateAddressDto } from '../dto/update-address.dto';
import { CustomerAddressEntity } from '../entities/customer-address.entity';

@Injectable()
export class AddressRepository implements IAddressRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByCustomer(customerId: string): Promise<CustomerAddressEntity[]> {
    const records = await this.prisma.address.findMany({
      where: { customerId, deletedAt: null },
      orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
    });
    return records.map((record) => new CustomerAddressEntity(record));
  }

  async findById(id: string): Promise<CustomerAddressEntity | null> {
    const record = await this.prisma.address.findFirst({
      where: { id, deletedAt: null },
    });
    return record ? new CustomerAddressEntity(record) : null;
  }

  async findDefault(customerId: string): Promise<CustomerAddressEntity | null> {
    const record = await this.prisma.address.findFirst({
      where: { customerId, isDefault: true, deletedAt: null },
    });
    return record ? new CustomerAddressEntity(record) : null;
  }

  async create(customerId: string, dto: CreateAddressDto): Promise<CustomerAddressEntity> {
    const record = await this.prisma.address.create({
      data: {
        customerId,
        fullName: dto.fullName,
        mobileNumber: dto.mobileNumber,
        alternateMobile: dto.alternateMobile || null,
        addressLine1: dto.addressLine1,
        addressLine2: dto.addressLine2 || null,
        landmark: dto.landmark || null,
        city: dto.city,
        state: dto.state,
        country: dto.country || 'India',
        postalCode: dto.postalCode,
        addressType: dto.addressType || 'HOME',
        isDefault: dto.isDefault ?? false,
      },
    });
    return new CustomerAddressEntity(record);
  }

  async update(id: string, dto: UpdateAddressDto): Promise<CustomerAddressEntity> {
    const record = await this.prisma.address.update({
      where: { id },
      data: {
        ...(dto.fullName !== undefined && { fullName: dto.fullName }),
        ...(dto.mobileNumber !== undefined && { mobileNumber: dto.mobileNumber }),
        ...(dto.alternateMobile !== undefined && { alternateMobile: dto.alternateMobile }),
        ...(dto.addressLine1 !== undefined && { addressLine1: dto.addressLine1 }),
        ...(dto.addressLine2 !== undefined && { addressLine2: dto.addressLine2 }),
        ...(dto.landmark !== undefined && { landmark: dto.landmark }),
        ...(dto.city !== undefined && { city: dto.city }),
        ...(dto.state !== undefined && { state: dto.state }),
        ...(dto.country !== undefined && { country: dto.country }),
        ...(dto.postalCode !== undefined && { postalCode: dto.postalCode }),
        ...(dto.addressType !== undefined && { addressType: dto.addressType }),
        ...(dto.isDefault !== undefined && { isDefault: dto.isDefault }),
      },
    });
    return new CustomerAddressEntity(record);
  }

  async delete(id: string): Promise<CustomerAddressEntity> {
    const record = await this.prisma.address.update({
      where: { id },
      data: { deletedAt: new Date(), isDefault: false },
    });
    return new CustomerAddressEntity(record);
  }

  async unsetCustomerDefaults(customerId: string): Promise<void> {
    await this.prisma.address.updateMany({
      where: { customerId, isDefault: true, deletedAt: null },
      data: { isDefault: false },
    });
  }

  async setDefault(customerId: string, id: string): Promise<CustomerAddressEntity> {
    await this.unsetCustomerDefaults(customerId);
    const record = await this.prisma.address.update({
      where: { id },
      data: { isDefault: true },
    });
    return new CustomerAddressEntity(record);
  }
}
