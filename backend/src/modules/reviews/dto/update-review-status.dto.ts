import { ApiProperty } from '@nestjs/swagger';
import { IsIn } from 'class-validator';

export class UpdateReviewStatusDto {
  @ApiProperty({
    description: 'Updated review status: ACTIVE or HIDDEN',
    example: 'HIDDEN',
    enum: ['ACTIVE', 'HIDDEN'],
  })
  @IsIn(['ACTIVE', 'HIDDEN'], {
    message: 'Status must be either ACTIVE or HIDDEN',
  })
  status: 'ACTIVE' | 'HIDDEN';
}
