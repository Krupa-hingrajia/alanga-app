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
      phoneNumber: user.phoneNumber,
      password: user.password,
      role: user.role,
      status: user.status,
      kycStatus: user.kycStatus,
      profileImage: user.profileImage,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      deletedAt: user.deletedAt,
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

  async findUserByMobile(phoneNumber: string): Promise<UserEntity | null> {
    const user = await this.prisma.user.findFirst({ where: { phoneNumber } });
    if (!user) return null;
    return this.mapToEntity(user);
  }

  async updateRefreshToken(id: string, token: string | null): Promise<UserEntity> {
    const user = await this.prisma.user.findUnique({ where: { id } });
    return this.mapToEntity(user);
  }
}
