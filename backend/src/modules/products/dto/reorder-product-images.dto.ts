import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsNotEmpty, IsNumber, IsUUID, Min, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class ImageOrderItemDto {
  @ApiProperty({
    example: 'd1e2f3a4-b5c6-7890-1234-56789abcdef0',
    description: 'Product Image UUID',
  })
  @IsNotEmpty()
  @IsUUID()
  id: string;

  @ApiProperty({
    example: 1,
    description: 'New display order index (integer >= 0)',
  })
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  displayOrder: number;
}

export class ReorderProductImagesDto {
  @ApiProperty({
    type: [ImageOrderItemDto],
    description: 'Array of image ID and new display order pairs',
    example: [
      { id: 'd1e2f3a4-b5c6-7890-1234-56789abcdef0', displayOrder: 0 },
      { id: 'e2f3a4b5-c6d7-8901-2345-6789abcdef01', displayOrder: 1 },
    ],
  })
  @IsNotEmpty()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ImageOrderItemDto)
  images: ImageOrderItemDto[];
}
