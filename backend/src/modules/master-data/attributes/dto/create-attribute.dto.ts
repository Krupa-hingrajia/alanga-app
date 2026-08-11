import { IsNotEmpty, IsString, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateAttributeDto {
  @ApiProperty({ example: 'Color', description: 'Name of the product attribute (must be unique)' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ required: false, default: 'ACTIVE', example: 'ACTIVE', description: 'Status of the attribute (ACTIVE, INACTIVE)' })
  @IsOptional()
  @IsString()
  status?: string;
}
