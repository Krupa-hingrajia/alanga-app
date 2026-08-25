import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, MaxLength } from 'class-validator';

export class RequestBrandDto {
  @ApiProperty({ description: 'Brand Name', example: 'Nike' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name: string;

  @ApiPropertyOptional({ description: 'Brand Logo URL', example: 'https://example.com/nike.png' })
  @IsString()
  @IsOptional()
  logo?: string;

  @ApiPropertyOptional({ description: 'Brand Description', example: 'Sports and footwear brand' })
  @IsString()
  @IsOptional()
  @MaxLength(500)
  description?: string;
}
