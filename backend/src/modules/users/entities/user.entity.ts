import { Role, AccountStatus, KYCStatus } from '@prisma/client';
import { Exclude } from 'class-transformer';

export class UserEntity {
  id: string;
  fullName: string;
  email: string;
  phoneNumber?: string | null;

  @Exclude()
  password?: string;

  role: Role;
  status: AccountStatus;
  kycStatus: KYCStatus;
  profileImage?: string | null;

  createdAt: Date;
  updatedAt: Date;
  deletedAt?: Date | null;

  constructor(partial: Partial<UserEntity>) {
    Object.assign(this, partial);
  }
}
