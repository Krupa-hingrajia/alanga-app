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
}
