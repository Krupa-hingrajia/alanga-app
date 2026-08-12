import { UserEntity } from '../entities/user.entity';
import { Prisma } from '@prisma/client';

export abstract class IUsersRepository {
  abstract create(data: Prisma.UserCreateInput): Promise<UserEntity>;
  abstract findById(id: string): Promise<UserEntity | null>;
  abstract findByEmail(email: string): Promise<UserEntity | null>;
  abstract findByMobileNumber(mobileNumber: string): Promise<UserEntity | null>;
  abstract update(id: string, data: Prisma.UserUpdateInput): Promise<UserEntity>;
  abstract findManyVendors(filters?: {
    status?: string;
    search?: string;
    skip?: number;
    take?: number;
  }): Promise<{ items: UserEntity[]; total: number }>;
}
