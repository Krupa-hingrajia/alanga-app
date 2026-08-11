import { Module } from '@nestjs/common';
import { AdminAuthController } from './admin-auth.controller';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [AdminAuthController],
})
export class AdminAuthModule {}
