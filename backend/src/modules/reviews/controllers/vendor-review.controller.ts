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
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { ReviewService } from '../services/review.service';
import { VendorReplyDto } from '../dto/vendor-reply.dto';
import { ReviewQueryDto } from '../dto/review-query.dto';

@ApiTags('Vendor Reviews')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.VENDOR)
@Controller('vendor/reviews')
export class VendorReviewController {
  constructor(private readonly reviewService: ReviewService) {}

  @Get()
  @ApiOperation({ summary: 'Get reviews received on vendor products' })
  @ApiResponse({ status: 200, description: 'Vendor reviews retrieved successfully.' })
  async getVendorReviews(
    @CurrentUser('id') vendorId: string,
    @Query() query: ReviewQueryDto,
  ) {
    const data = await this.reviewService.getVendorReviews(vendorId, query);
    return {
      success: true,
      message: 'Vendor reviews retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Post(':id/reply')
  @ApiOperation({ summary: 'Reply to a review on vendor product' })
  @ApiParam({ name: 'id', description: 'Review UUID' })
  @ApiResponse({ status: 201, description: 'Reply posted successfully.' })
  @ApiResponse({ status: 403, description: 'Vendor does not own the product.' })
  @ApiResponse({ status: 404, description: 'Review not found.' })
  async replyToReview(
    @CurrentUser('id') vendorId: string,
    @Param('id') id: string,
    @Body() dto: VendorReplyDto,
  ) {
    const data = await this.reviewService.replyToReview(vendorId, id, dto);
    return {
      success: true,
      message: 'Reply posted successfully',
      data,
      statusCode: HttpStatus.CREATED,
    };
  }

  @Put('replies/:replyId')
  @ApiOperation({ summary: 'Update a vendor reply' })
  @ApiParam({ name: 'replyId', description: 'Review Reply UUID' })
  @ApiResponse({ status: 200, description: 'Reply updated successfully.' })
  @ApiResponse({ status: 403, description: 'Not authorized to edit this reply.' })
  @ApiResponse({ status: 404, description: 'Reply not found.' })
  async updateReply(
    @CurrentUser('id') vendorId: string,
    @Param('replyId') replyId: string,
    @Body() dto: VendorReplyDto,
  ) {
    const data = await this.reviewService.updateVendorReply(vendorId, replyId, dto);
    return {
      success: true,
      message: 'Reply updated successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete('replies/:replyId')
  @ApiOperation({ summary: 'Delete a vendor reply' })
  @ApiParam({ name: 'replyId', description: 'Review Reply UUID' })
  @ApiResponse({ status: 200, description: 'Reply deleted successfully.' })
  @ApiResponse({ status: 403, description: 'Not authorized to delete this reply.' })
  @ApiResponse({ status: 404, description: 'Reply not found.' })
  async deleteReply(
    @CurrentUser('id') vendorId: string,
    @Param('replyId') replyId: string,
  ) {
    const data = await this.reviewService.deleteVendorReply(vendorId, replyId);
    return {
      success: true,
      message: 'Reply deleted successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
