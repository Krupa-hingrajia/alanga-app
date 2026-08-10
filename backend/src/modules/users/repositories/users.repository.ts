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
      countryCode: user.countryCode,
      mobileNumber: user.mobileNumber,
      password: user.password,
      role: user.role,
      status: user.status,
      businessName: user.businessName,
      businessType: user.businessType,
      city: user.city,
      state: user.state,
      pincode: user.pincode,
      gstNumber: user.gstNumber,
      panNumber: user.panNumber,
      hashedRefreshToken: user.hashedRefreshToken,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    });
  }

  async create(data: Prisma.UserCreateInput): Promise<UserEntity> {
    const user = await this.prisma.user.create({ data });
    return this.mapToEntity(user);
  }

  async findById(id: string): Promise<UserEntity | null> {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) return null;
    return this.mapToEntity(user);
  }

  async findByEmail(email: string): Promise<UserEntity | null> {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) return null;
    return this.mapToEntity(user);
  }

  async findByMobileNumber(mobileNumber: string): Promise<UserEntity | null> {
    const user = await this.prisma.user.findUnique({ where: { mobileNumber } });
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
}
