import { IsOptional, IsDateString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SalesQueryDto {
  @ApiProperty({
    required: false,
    description: 'Filter sales from start date (ISO date string, e.g., 2026-08-01)',
  })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiProperty({
    required: false,
    description: 'Filter sales to end date (ISO date string, e.g., 2026-08-31)',
  })
  @IsOptional()
  @IsDateString()
  endDate?: string;
}
