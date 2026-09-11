import { Module } from '@nestjs/common';
import { DatabaseModule } from '../../database/database.module';
import { AddressRepository } from './repositories/address.repository';
import { AddressService } from './services/address.service';
import { CustomerAddressController } from './controllers/customer-address.controller';

@Module({
  imports: [DatabaseModule],
  controllers: [CustomerAddressController],
  providers: [AddressRepository, AddressService],
  exports: [AddressRepository, AddressService],
})
export class AddressModule {}
