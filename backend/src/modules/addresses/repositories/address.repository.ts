import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { IAddressRepository } from '../interfaces/address-repository.interface';
import { CreateAddressDto } from '../dto/create-address.dto';
import { UpdateAddressDto } from '../dto/update-address.dto';

@Injectable()
export class AddressRepository implements IAddressRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByCustomer(customerId: string): Promise<any[]> {
    return this.prisma.address.findMany({
      where: { customerId, deletedAt: null },
      orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
    });
  }

  async findById(id: string): Promise<any | null> {
    return this.prisma.address.findFirst({
      where: { id, deletedAt: null },
    });
  }

  async findDefault(customerId: string): Promise<any | null> {
    return this.prisma.address.findFirst({
      where: { customerId, isDefault: true, deletedAt: null },
    });
  }

  async create(customerId: string, dto: CreateAddressDto): Promise<any> {
    return this.prisma.address.create({
      data: {
        customerId,
        fullName: dto.fullName,
        mobileNumber: dto.mobileNumber,
        alternateMobile: dto.alternateMobile,
        addressLine1: dto.addressLine1,
        addressLine2: dto.addressLine2,
        landmark: dto.landmark,
        city: dto.city,
        state: dto.state,
        country: dto.country || 'India',
        postalCode: dto.postalCode,
        addressType: dto.addressType || 'HOME',
        isDefault: dto.isDefault ?? false,
      },
    });
  }

  async update(id: string, dto: UpdateAddressDto): Promise<any> {
    return this.prisma.address.update({
      where: { id },
      data: dto,
    });
  }

  async delete(id: string): Promise<any> {
    return this.prisma.address.update({
      where: { id },
      data: { deletedAt: new Date(), isDefault: false },
    });
  }

  async unsetCustomerDefaults(customerId: string): Promise<void> {
    await this.prisma.address.updateMany({
      where: { customerId, isDefault: true, deletedAt: null },
      data: { isDefault: false },
    });
  }

  async setDefault(customerId: string, id: string): Promise<any> {
    await this.unsetCustomerDefaults(customerId);
    return this.prisma.address.update({
      where: { id },
      data: { isDefault: true },
    });
  }
}
