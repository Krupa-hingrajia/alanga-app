import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength } from 'class-validator';

export class VendorReplyDto {
  @ApiProperty({
    description: 'Vendor response or reply to the customer review',
    example: 'Thank you for your valuable feedback! We are thrilled that you loved the product.',
  })
  @IsString()
  @MinLength(3, { message: 'Reply must be at least 3 characters long' })
  reply: string;
}
