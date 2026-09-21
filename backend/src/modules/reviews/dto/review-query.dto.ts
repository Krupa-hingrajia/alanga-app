import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsInt, Min, Max, IsIn } from 'class-validator';
import { Type } from 'class-transformer';

export class ReviewQueryDto {
  @ApiPropertyOptional({ description: 'Filter by Rating (1-5)', minimum: 1, maximum: 5 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(5)
  rating?: number;

  @ApiPropertyOptional({
    description: 'Sort reviews by newest, highest_rating, lowest_rating',
    enum: ['newest', 'highest_rating', 'lowest_rating'],
    default: 'newest',
  })
  @IsOptional()
  @IsString()
  @IsIn(['newest', 'highest_rating', 'lowest_rating'])
  sortBy?: 'newest' | 'highest_rating' | 'lowest_rating' = 'newest';

  @ApiPropertyOptional({ description: 'Page number', default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Number of items per page', default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 10;
}

export class AdminReviewQueryDto extends ReviewQueryDto {
  @ApiPropertyOptional({ description: 'Filter by Product UUID' })
  @IsOptional()
  @IsString()
  productId?: string;

  @ApiPropertyOptional({ description: 'Filter by Vendor UUID' })
  @IsOptional()
  @IsString()
  vendorId?: string;

  @ApiPropertyOptional({ description: 'Filter by Customer UUID' })
  @IsOptional()
  @IsString()
  customerId?: string;

  @ApiPropertyOptional({ description: 'Filter by Status (ACTIVE, HIDDEN, DELETED)' })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ description: 'Search review title or description' })
  @IsOptional()
  @IsString()
  search?: string;
}
