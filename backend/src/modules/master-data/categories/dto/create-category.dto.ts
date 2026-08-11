import { IsNotEmpty, IsString, IsOptional, IsInt, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCategoryDto {
  @ApiProperty({ example: 'Electronics', description: 'Name of the category (must be unique)' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ required: false, example: 'Electronic gadgets and appliances', description: 'Category description' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ required: false, example: 'https://example.com/electronics.png', description: 'Category image URL' })
  @IsOptional()
  @IsString()
  image?: string;

  @ApiProperty({ required: false, default: 0, example: 1, description: 'Display sort order' })
  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number;

  @ApiProperty({ required: false, default: 'ACTIVE', example: 'ACTIVE', description: 'Status of the category (ACTIVE, INACTIVE)' })
  @IsOptional()
  @IsString()
  status?: string;
}
