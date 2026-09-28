import { Module } from '@nestjs/common';
import { DatabaseModule } from '../../database/database.module';
import { VendorProfileController } from './controllers/vendor-profile.controller';
import { VendorProfileService } from './services/vendor-profile.service';

@Module({
  imports: [DatabaseModule],
  controllers: [VendorProfileController],
  providers: [VendorProfileService],
  exports: [VendorProfileService],
})
export class VendorProfileModule {}
