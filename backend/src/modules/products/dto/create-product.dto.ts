import { IsNotEmpty, IsString, IsOptional, IsNumber, IsInt, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProductDto {
  @ApiProperty({ example: 'iPhone 15 Pro', description: 'Name of the product' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ required: false, example: 'Apple flagship smartphone', description: 'Product description' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ example: 999.99, description: 'Price of the product' })
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  price: number;

  @ApiProperty({ example: 50, description: 'Inventory stock level' })
  @IsNotEmpty()
  @IsInt()
  @Min(0)
  stock: number;
}
