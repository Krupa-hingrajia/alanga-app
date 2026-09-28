import { Injectable } from '@nestjs/common';
import { IUsersRepository } from '../interfaces/users-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { UserEntity } from '../entities/user.entity';
import { Prisma } from '@prisma/client';

@Injectable()
export class UsersRepository implements IUsersRepository {
  constructor(private readonly prisma: PrismaService) {}

  private mapToEntity(user: any): UserEntity {
    return new UserEntity({
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      password: user.password,
      role: user.role,
      status: user.status,
      kycStatus: user.kycStatus,
      profileImage: user.profileImage,
      vendorProfile: user.vendorProfile,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      deletedAt: user.deletedAt,
    });
  }

  async create(data: Prisma.UserCreateInput): Promise<UserEntity> {
    const user = await this.prisma.user.create({ data });
    return this.mapToEntity(user);
  }

  async findById(id: string): Promise<UserEntity | null> {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: { vendorProfile: true },
    });
    if (!user) return null;
    return this.mapToEntity(user);
  }

  async findByEmail(email: string): Promise<UserEntity | null> {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) return null;
    return this.mapToEntity(user);
  }

  async findByPhoneNumber(phoneNumber: string): Promise<UserEntity | null> {
    const user = await this.prisma.user.findFirst({ where: { phoneNumber } });
    if (!user) return null;
    return this.mapToEntity(user);
  }

  async update(id: string, data: Prisma.UserUpdateInput): Promise<UserEntity> {
    const user = await this.prisma.user.update({
      where: { id },
      data,
    });
    return this.mapToEntity(user);
  }

  async findManyVendors(filters?: {
    status?: string;
    search?: string;
    skip?: number;
    take?: number;
  }): Promise<{ items: UserEntity[]; total: number }> {
    const whereClause: any = { role: 'VENDOR' };
    if (filters) {
      if (filters.status) {
        if (filters.status === 'PENDING') {
          whereClause.OR = [
            { status: 'PENDING' },
            { kycStatus: 'PENDING' },
          ];
        } else {
          whereClause.status = filters.status;
        }
      }
      if (filters.search) {
        const searchArr = [
          { fullName: { contains: filters.search, mode: 'insensitive' } },
          { email: { contains: filters.search, mode: 'insensitive' } },
          { phoneNumber: { contains: filters.search, mode: 'insensitive' } },
          { vendorProfile: { is: { storeName: { contains: filters.search, mode: 'insensitive' } } } },
        ];
        if (whereClause.OR) {
          whereClause.AND = [
            { OR: whereClause.OR },
            { OR: searchArr },
          ];
          delete whereClause.OR;
        } else {
          whereClause.OR = searchArr;
        }
      }
    }
    const [items, total] = await Promise.all([
      this.prisma.user.findMany({
        where: whereClause,
        include: { vendorProfile: true },
        orderBy: { createdAt: 'desc' },
        skip: filters?.skip,
        take: filters?.take,
      }),
      this.prisma.user.count({ where: whereClause }),
    ]);

    return {
      items: items.map((u) => this.mapToEntity(u)),
      total,
    };
  }

  async findManyCustomers(filters?: {
    status?: string;
    search?: string;
    skip?: number;
    take?: number;
  }): Promise<{ items: UserEntity[]; total: number }> {
    const whereClause: any = { role: 'CUSTOMER' };
    if (filters) {
      if (filters.status) {
        whereClause.status = filters.status;
      }
      if (filters.search) {
        whereClause.OR = [
          { fullName: { contains: filters.search, mode: 'insensitive' } },
          { email: { contains: filters.search, mode: 'insensitive' } },
          { phoneNumber: { contains: filters.search, mode: 'insensitive' } },
        ];
      }
    }
    const [items, total] = await Promise.all([
      this.prisma.user.findMany({
        where: whereClause,
        orderBy: { createdAt: 'desc' },
        skip: filters?.skip,
        take: filters?.take,
      }),
      this.prisma.user.count({ where: whereClause }),
    ]);

    return {
      items: items.map((u) => this.mapToEntity(u)),
      total,
    };
  }
}

