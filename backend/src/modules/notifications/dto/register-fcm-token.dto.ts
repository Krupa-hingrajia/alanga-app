import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class RegisterFcmTokenDto {
  @ApiProperty({ description: 'FCM device registration token', example: 'dK8...x9z' })
  @IsNotEmpty()
  @IsString()
  token: string;

  @ApiProperty({ description: 'Device platform', example: 'ANDROID', required: false })
  @IsOptional()
  @IsString()
  deviceType?: string;
}

export class RemoveFcmTokenDto {
  @ApiProperty({ description: 'FCM device registration token to remove' })
  @IsNotEmpty()
  @IsString()
  token: string;
}
