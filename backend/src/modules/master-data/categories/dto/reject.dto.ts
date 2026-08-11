import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RejectDto {
  @ApiProperty({ example: 'Invalid image URL or wrong category classification.', description: 'The reason why this item is being rejected.' })
  @IsNotEmpty()
  @IsString()
  reason: string;
}
