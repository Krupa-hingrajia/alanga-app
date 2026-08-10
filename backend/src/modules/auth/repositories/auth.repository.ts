import { Injectable } from '@nestjs/common';
import { IAuthRepository } from '../interfaces/auth-repository.interface';
import { PrismaService } from '../../../database/prisma.service';
import { UserEntity } from '../../users/entities/user.entity';
import { Prisma } from '@prisma/client';

@Injectable()
export class AuthRepository implements IAuthRepository {
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

  async createUser(data: Prisma.UserCreateInput): Promise<UserEntity> {
    const user = await this.prisma.user.create({ data });
    return this.mapToEntity(user);
  }

  async findUserByEmail(email: string): Promise<UserEntity | null> {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) return null;
    return this.mapToEntity(user);
  }

  async findUserByMobile(mobileNumber: string): Promise<UserEntity | null> {
    const user = await this.prisma.user.findUnique({ where: { mobileNumber } });
    if (!user) return null;
    return this.mapToEntity(user);
  }

  async updateRefreshToken(id: string, token: string | null): Promise<UserEntity> {
    const user = await this.prisma.user.update({
      where: { id },
      data: { hashedRefreshToken: token },
    });
    return this.mapToEntity(user);
  }
}
