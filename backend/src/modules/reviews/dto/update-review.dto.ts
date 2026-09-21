import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsInt,
  Min,
  Max,
  IsOptional,
  IsArray,
  MinLength,
} from 'class-validator';

export class UpdateReviewDto {
  @ApiPropertyOptional({
    description: 'Updated rating score between 1 and 5',
    example: 4,
    minimum: 1,
    maximum: 5,
  })
  @IsOptional()
  @IsInt({ message: 'Rating must be an integer' })
  @Min(1, { message: 'Rating must be at least 1' })
  @Max(5, { message: 'Rating cannot exceed 5' })
  rating?: number;

  @ApiPropertyOptional({
    description: 'Updated review title',
    example: 'Great dress after 1 week use',
  })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({
    description: 'Updated review text (minimum 10 characters)',
    example: 'Still looks like new after gentle wash.',
  })
  @IsOptional()
  @IsString()
  @MinLength(10, { message: 'Review must be at least 10 characters long' })
  review?: string;

  @ApiPropertyOptional({
    description: 'Updated review description (backward compatibility alias, minimum 10 characters)',
    example: 'Still looks like new after gentle wash.',
  })
  @IsOptional()
  @IsString()
  @MinLength(10, { message: 'Review description must be at least 10 characters long' })
  description?: string;

  @ApiPropertyOptional({
    description: 'Updated array of review image URLs',
    type: [String],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  images?: string[];
}
