import { Module } from '@nestjs/common';
import { UsersService } from './services/users.service';
import { IUsersRepository } from './interfaces/users-repository.interface';
import { UsersRepository } from './repositories/users.repository';
import { AdminUsersController } from './controllers/admin-users.controller';

@Module({
  controllers: [AdminUsersController],
  providers: [
    UsersService,
    {
      provide: IUsersRepository,
      useClass: UsersRepository,
    },
  ],
  exports: [UsersService],
})
export class UsersModule {}
