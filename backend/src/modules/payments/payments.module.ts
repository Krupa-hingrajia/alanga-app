import { Module } from '@nestjs/common';
import { DatabaseModule } from '../../database/database.module';
import { OrderModule } from '../orders/order.module';
import { PaymentsController } from './payments.controller';
import { PaymentsService } from './payments.service';

@Module({
  imports: [DatabaseModule, OrderModule],
  controllers: [PaymentsController],
  providers: [PaymentsService],
  exports: [PaymentsService],
})
export class PaymentsModule {}
