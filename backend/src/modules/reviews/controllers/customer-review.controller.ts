import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { ReviewService } from '../services/review.service';
import { CreateReviewDto } from '../dto/create-review.dto';
import { UpdateReviewDto } from '../dto/update-review.dto';
import { ReviewQueryDto } from '../dto/review-query.dto';

@ApiTags('Customer Reviews')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('CUSTOMER')
@Controller('customer/reviews')
export class CustomerReviewController {
  constructor(private readonly reviewService: ReviewService) {}

  @Post()
  @ApiOperation({ summary: 'Submit a product review (only for delivered purchases)' })
  @ApiResponse({ status: 201, description: 'Review submitted successfully.' })
  @ApiResponse({ status: 400, description: 'Product not delivered or not purchased.' })
  @ApiResponse({ status: 409, description: 'Review already submitted for this product.' })
  async createReview(
    @CurrentUser('id') customerId: string,
    @Body() dto: CreateReviewDto,
  ) {
    const data = await this.reviewService.createReview(customerId, dto);
    return {
      success: true,
      message: 'Review submitted successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Get('eligible')
  @ApiOperation({ summary: 'List delivered products eligible to review' })
  @ApiResponse({ status: 200, description: 'Eligible products retrieved successfully.' })
  async getEligibleProducts(@CurrentUser('id') customerId: string) {
    const data = await this.reviewService.getEligibleProductsForReview(customerId);
    return {
      success: true,
      message: 'Eligible products retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Get()
  @ApiOperation({ summary: 'Get all reviews written by current customer' })
  @ApiResponse({ status: 200, description: 'Reviews retrieved successfully.' })
  async getCustomerReviews(
    @CurrentUser('id') customerId: string,
    @Query() query: ReviewQueryDto,
  ) {
    const data = await this.reviewService.getCustomerReviews(customerId, query);
    return {
      success: true,
      message: 'Reviews retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update an existing review' })
  @ApiParam({ name: 'id', description: 'Review UUID' })
  @ApiResponse({ status: 200, description: 'Review updated successfully.' })
  @ApiResponse({ status: 404, description: 'Review not found.' })
  @ApiResponse({ status: 403, description: 'Not authorized to edit this review.' })
  async updateReview(
    @CurrentUser('id') customerId: string,
    @Param('id') id: string,
    @Body() dto: UpdateReviewDto,
  ) {
    const data = await this.reviewService.updateReview(customerId, id, dto);
    return {
      success: true,
      message: 'Review updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a review' })
  @ApiParam({ name: 'id', description: 'Review UUID' })
  @ApiResponse({ status: 200, description: 'Review deleted successfully.' })
  @ApiResponse({ status: 404, description: 'Review not found.' })
  @ApiResponse({ status: 403, description: 'Not authorized to delete this review.' })
  async deleteReview(
    @CurrentUser('id') customerId: string,
    @Param('id') id: string,
  ) {
    const data = await this.reviewService.deleteReview(customerId, id);
    return {
      success: true,
      message: 'Review deleted successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
