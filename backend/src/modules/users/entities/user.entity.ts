import { Role, UserStatus } from '@prisma/client';
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
  status: UserStatus;
  businessName?: string | null;
  businessType?: string | null;
  city?: string | null;
  state?: string | null;
  pincode?: string | null;
  gstNumber?: string | null;
  panNumber?: string | null;

  @Exclude()
  hashedRefreshToken?: string | null;

  createdAt: Date;
  updatedAt: Date;

  constructor(partial: Partial<UserEntity>) {
    Object.assign(this, partial);
  }
}
