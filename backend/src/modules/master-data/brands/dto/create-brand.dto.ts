import { IsNotEmpty, IsString, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateBrandDto {
  @ApiProperty({ example: 'Samsung', description: 'Name of the brand (must be unique)' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ required: false, example: 'https://example.com/samsung-logo.png', description: 'Brand logo image URL' })
  @IsOptional()
  @IsString()
  logo?: string;

  @ApiProperty({ required: false, example: 'Consumer electronics manufacturer', description: 'Brand description' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ required: false, default: 'ACTIVE', example: 'ACTIVE', description: 'Status of the brand (ACTIVE, INACTIVE)' })
  @IsOptional()
  @IsString()
  status?: string;
}
