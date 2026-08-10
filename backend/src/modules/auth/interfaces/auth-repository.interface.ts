import { UserEntity } from '../../users/entities/user.entity';
import { Prisma } from '@prisma/client';

export abstract class IAuthRepository {
  abstract createUser(data: Prisma.UserCreateInput): Promise<UserEntity>;
  abstract findUserByEmail(email: string): Promise<UserEntity | null>;
  abstract findUserByMobile(mobileNumber: string): Promise<UserEntity | null>;
  abstract updateRefreshToken(id: string, token: string | null): Promise<UserEntity>;
}
