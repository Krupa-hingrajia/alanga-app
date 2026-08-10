import { Role } from '@prisma/client';
import { Exclude } from 'class-transformer';

export class UserEntity {
  id: string;
  fullName: string;
  email: string;
  countryCode: string;
  mobileNumber: string;

  @Exclude()
  password?: string;

  role: Role;

  @Exclude()
  hashedRefreshToken?: string | null;

  createdAt: Date;
  updatedAt: Date;

  constructor(partial: Partial<UserEntity>) {
    Object.assign(this, partial);
  }
}
