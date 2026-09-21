import {
  Controller,
  Get,
  Patch,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam, ApiBody } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { ReviewService } from '../services/review.service';
import { AdminReviewQueryDto } from '../dto/review-query.dto';
import { UpdateReviewStatusDto } from '../dto/update-review-status.dto';

@ApiTags('Admin Reviews')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@Controller('admin/reviews')
export class AdminReviewController {
  constructor(private readonly reviewService: ReviewService) {}

  @Get()
  @ApiOperation({ summary: 'List all marketplace reviews with search and filters' })
  @ApiResponse({ status: 200, description: 'Marketplace reviews retrieved successfully.' })
  async getAdminReviews(@Query() query: AdminReviewQueryDto) {
    const data = await this.reviewService.getAdminReviews(query);
    return {
      success: true,
      message: 'Reviews retrieved successfully',
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Update review moderation status (ACTIVE or HIDDEN)' })
  @ApiParam({ name: 'id', description: 'Review UUID' })
  @ApiBody({ type: UpdateReviewStatusDto })
  @ApiResponse({ status: 200, description: 'Review status updated successfully.' })
  @ApiResponse({ status: 404, description: 'Review not found.' })
  async updateReviewStatus(
    @Param('id') id: string,
    @Body() dto: UpdateReviewStatusDto,
  ) {
    const data = await this.reviewService.updateReviewStatusByAdmin(id, dto.status);
    return {
      success: true,
      message: `Review status updated to ${dto.status}`,
      data,
      statusCode: HttpStatus.OK,
    };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Admin delete / moderate an inappropriate review' })
  @ApiParam({ name: 'id', description: 'Review UUID' })
  @ApiResponse({ status: 200, description: 'Review removed by administrator.' })
  @ApiResponse({ status: 404, description: 'Review not found.' })
  async deleteReview(@Param('id') id: string) {
    const data = await this.reviewService.deleteReviewByAdmin(id);
    return {
      success: true,
      message: data.message,
      data,
      statusCode: HttpStatus.OK,
    };
  }
}
