import { Injectable } from '@nestjs/common';
import { IUsersRepository } from '../interfaces/users-repository.interface';
import { UserEntity } from '../entities/user.entity';
import { Prisma } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private readonly usersRepository: IUsersRepository) {}

  async create(data: Prisma.UserCreateInput): Promise<UserEntity> {
    return this.usersRepository.create(data);
  }

  async findById(id: string): Promise<UserEntity | null> {
    return this.usersRepository.findById(id);
  }

  async findByEmail(email: string): Promise<UserEntity | null> {
    return this.usersRepository.findByEmail(email);
  }

  async findByMobileNumber(mobileNumber: string): Promise<UserEntity | null> {
    return this.usersRepository.findByMobileNumber(mobileNumber);
  }

  async updateRefreshToken(id: string, hashedRefreshToken: string | null): Promise<UserEntity> {
    return this.usersRepository.update(id, { hashedRefreshToken });
  }

  async findManyVendors(filters?: {
    status?: string;
    search?: string;
    page?: number;
    limit?: number;
  }) {
    const page = filters?.page || 1;
    const limit = filters?.limit || 10;
    const skip = (page - 1) * limit;

    const { items, total } = await this.usersRepository.findManyVendors({
      status: filters?.status,
      search: filters?.search,
      skip,
      take: limit,
    });

    return {
      items,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async updateStatus(id: string, status: any): Promise<UserEntity> {
    return this.usersRepository.update(id, { status });
  }
}
