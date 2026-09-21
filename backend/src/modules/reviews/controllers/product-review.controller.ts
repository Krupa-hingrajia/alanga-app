import { Controller, Get, Param, Query, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam } from '@nestjs/swagger';
import { ReviewService } from '../services/review.service';
import { ReviewQueryDto } from '../dto/review-query.dto';

@ApiTags('Product Reviews')
@Controller('products')
export class ProductReviewController {
  constructor(private readonly reviewService: ReviewService) {}

  @Get(':id/reviews')
  @ApiOperation({ summary: 'Get public reviews, average rating, and star breakdown for a product' })
  @ApiParam({ name: 'id', description: 'Product UUID' })
  @ApiResponse({ status: 200, description: 'Product reviews retrieved successfully.' })
  async getProductReviews(
    @Param('id') id: string,
    @Query() query: ReviewQueryDto,
  ) {
    const data = await this.reviewService.getProductReviews(id, query);
    return {
      success: true,
      message: 'Product reviews retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get(':id/rating-summary')
  @ApiOperation({ summary: 'Get rating summary (Average rating, total reviews, and 5 to 1 star counts)' })
  @ApiParam({ name: 'id', description: 'Product UUID' })
  @ApiResponse({ status: 200, description: 'Product rating summary retrieved successfully.' })
  async getRatingSummary(@Param('id') id: string) {
    const data = await this.reviewService.getProductRatingSummary(id);
    return {
      success: true,
      message: 'Rating summary retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
