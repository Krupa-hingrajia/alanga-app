import { Module } from '@nestjs/common';
import { DatabaseModule } from '../../database/database.module';
import { ReviewRepository } from './repositories/review.repository';
import { ReviewService } from './services/review.service';
import { CustomerReviewController } from './controllers/customer-review.controller';
import { ProductReviewController } from './controllers/product-review.controller';
import { VendorReviewController } from './controllers/vendor-review.controller';
import { AdminReviewController } from './controllers/admin-review.controller';

@Module({
  imports: [DatabaseModule],
  controllers: [
    CustomerReviewController,
    ProductReviewController,
    VendorReviewController,
    AdminReviewController,
  ],
  providers: [ReviewRepository, ReviewService],
  exports: [ReviewRepository, ReviewService],
})
export class ReviewsModule {}
