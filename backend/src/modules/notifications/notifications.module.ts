import { Module } from '@nestjs/common';
import { DatabaseModule } from '../../database/database.module';
import { FirebaseAdminService } from './firebase-admin.service';
import { NotificationsService } from './notifications.service';
import { NotificationsController } from './controllers/notifications.controller';

@Module({
  imports: [DatabaseModule],
  controllers: [NotificationsController],
  providers: [FirebaseAdminService, NotificationsService],
  exports: [FirebaseAdminService, NotificationsService],
})
export class NotificationsModule {}
