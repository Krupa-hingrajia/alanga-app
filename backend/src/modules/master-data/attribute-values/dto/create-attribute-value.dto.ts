import { IsNotEmpty, IsString, IsUUID, IsOptional, IsInt, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateAttributeValueDto {
  @ApiProperty({ example: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', description: 'Attribute ID (UUID) this value belongs to' })
  @IsNotEmpty()
  @IsUUID()
  attributeId: string;

  @ApiProperty({ example: 'Black', description: 'The value (e.g. Black, M, 128 GB)' })
  @IsNotEmpty()
  @IsString()
  value: string;

  @ApiProperty({ required: false, default: 0, example: 1, description: 'Display sort order' })
  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number;

  @ApiProperty({ required: false, default: 'ACTIVE', example: 'ACTIVE', description: 'Status of the attribute value (ACTIVE, INACTIVE)' })
  @IsOptional()
  @IsString()
  status?: string;
}
