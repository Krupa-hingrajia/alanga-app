import { IsNotEmpty, IsString, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateUnitDto {
  @ApiProperty({ example: 'Kilogram', description: 'Name of the unit (must be unique)' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ example: 'Kg', description: 'Short/abbreviation name of the unit' })
  @IsNotEmpty()
  @IsString()
  shortName: string;

  @ApiProperty({ required: false, default: 'ACTIVE', example: 'ACTIVE', description: 'Status of the unit (ACTIVE, INACTIVE)' })
  @IsOptional()
  @IsString()
  status?: string;
}
