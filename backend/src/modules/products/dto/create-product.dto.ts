import { IsNotEmpty, IsString, IsOptional, IsUUID, IsNumber, Min, IsInt, IsIn } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProductDto {
  @ApiProperty({ example: 'iPhone 15 Pro Max', description: 'Name of the product' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ required: false, example: 'Apple flagship smartphone with titanium body.', description: 'Product description' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ required: false, example: 'Apple flagship titanium phone.', description: 'Product short description' })
  @IsOptional()
  @IsString()
  shortDescription?: string;

  @ApiProperty({ example: 'a0b1c2d3-e4f5-6789-0123-456789abcdef', description: 'Category UUID reference' })
  @IsNotEmpty()
  @IsUUID()
  categoryId: string;

  @ApiProperty({ example: 'b0c1d2e3-f4a5-6789-0123-456789abcdef', description: 'SubCategory UUID reference' })
  @IsNotEmpty()
  @IsUUID()
  subCategoryId: string;

  @ApiProperty({ example: 'c0d1e2f3-a4b5-6789-0123-456789abcdef', description: 'Brand UUID reference' })
  @IsNotEmpty()
  @IsUUID()
  brandId: string;

  @ApiProperty({ example: 120000, description: 'Selling price of the product (cannot exceed MRP)' })
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  sellingPrice: number;

  @ApiProperty({ example: 139900, description: 'Maximum Retail Price (MRP), must be greater than zero' })
  @IsNotEmpty()
  @IsNumber()
  @Min(0.01)
  mrp: number;

  @ApiProperty({ required: false, example: 18, description: 'Tax percentage applied to product' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  taxPercentage?: number;

  @ApiProperty({ required: false, example: 100, description: 'Initial stock of the product' })
  @IsOptional()
  @IsInt()
  @Min(0)
  stock?: number;

  @ApiProperty({ required: false, example: 0.187, description: 'Weight of the product in kg' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  weight?: number;

  @ApiProperty({ required: false, example: 15.99, description: 'Length of the product packaging in cm' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  length?: number;

  @ApiProperty({ required: false, example: 7.67, description: 'Width of the product packaging in cm' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  width?: number;

  @ApiProperty({ required: false, example: 0.83, description: 'Height of the product packaging in cm' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  height?: number;

  @ApiProperty({ required: false, example: 'https://example.com/iphone.png', description: 'Product image URL or base64 data' })
  @IsOptional()
  @IsString()
  image?: string;

  @ApiProperty({ required: false, example: 'DRAFT', enum: ['DRAFT', 'PENDING'], description: 'Product creation status' })
  @IsOptional()
  @IsString()
  @IsIn(['DRAFT', 'PENDING'])
  status?: string;
}
