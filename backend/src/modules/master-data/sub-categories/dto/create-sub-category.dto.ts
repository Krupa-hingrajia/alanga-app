import { IsNotEmpty, IsString, IsUUID, IsOptional, IsInt, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateSubCategoryDto {
  @ApiProperty({ example: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', description: 'Category ID (UUID) this subcategory belongs to' })
  @IsNotEmpty()
  @IsUUID()
  categoryId: string;

  @ApiProperty({ example: 'Smartphones', description: 'Name of the subcategory' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ required: false, example: 'Mobile phones and smartphones', description: 'Subcategory description' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ required: false, example: 'https://example.com/smartphones.png', description: 'Subcategory image URL' })
  @IsOptional()
  @IsString()
  image?: string;

  @ApiProperty({ required: false, default: 0, example: 1, description: 'Display sort order' })
  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number;

  @ApiProperty({ required: false, default: 'ACTIVE', example: 'ACTIVE', description: 'Status of the subcategory (ACTIVE, INACTIVE)' })
  @IsOptional()
  @IsString()
  status?: string;
}
