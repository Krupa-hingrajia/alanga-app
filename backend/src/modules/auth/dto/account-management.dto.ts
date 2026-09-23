import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MinLength, IsOptional } from 'class-validator';

export class ForgotPasswordDto {
  @ApiProperty({
    example: 'vendor@alanga.com',
    description: 'Registered email or phone number',
  })
  @IsNotEmpty()
  @IsString()
  identifier: string;
}

export class VerifyOtpDto {
  @ApiProperty({
    example: 'vendor@alanga.com',
    description: 'Registered email or phone number',
  })
  @IsNotEmpty()
  @IsString()
  identifier: string;

  @ApiProperty({
    example: '123456',
    description: '6-digit verification OTP',
  })
  @IsNotEmpty()
  @IsString()
  @MinLength(4)
  otp: string;
}

export class ResetPasswordDto {
  @ApiProperty({
    example: 'vendor@alanga.com',
    description: 'Registered email or phone number',
  })
  @IsNotEmpty()
  @IsString()
  identifier: string;

  @ApiProperty({
    example: '123456',
    description: '6-digit verification OTP',
  })
  @IsNotEmpty()
  @IsString()
  otp: string;

  @ApiProperty({
    example: 'NewSecurePass123!',
    description: 'New password',
  })
  @IsNotEmpty()
  @IsString()
  @MinLength(6)
  newPassword: string;
}

export class ChangePasswordDto {
  @ApiProperty({
    example: 'CurrentPass123!',
    description: 'Current user password',
  })
  @IsNotEmpty()
  @IsString()
  currentPassword: string;

  @ApiProperty({
    example: 'NewSecurePass123!',
    description: 'New desired password',
  })
  @IsNotEmpty()
  @IsString()
  @MinLength(6)
  newPassword: string;
}

export class DeleteAccountDto {
  @ApiPropertyOptional({
    example: 'CurrentPass123!',
    description: 'User password to verify account deletion',
  })
  @IsOptional()
  @IsString()
  password?: string;

  @ApiPropertyOptional({
    example: 'Closing business',
    description: 'Reason for account deletion',
  })
  @IsOptional()
  @IsString()
  reason?: string;
}

export class UpdateProfileDto {
  @ApiPropertyOptional({ example: 'Alanga Store Owner', description: 'User full name' })
  @IsOptional()
  @IsString()
  fullName?: string;

  @ApiPropertyOptional({ example: '+919876543210', description: 'Contact phone number' })
  @IsOptional()
  @IsString()
  phoneNumber?: string;

  @ApiPropertyOptional({ example: 'https://cdn.example.com/avatar.jpg', description: 'Avatar URL' })
  @IsOptional()
  @IsString()
  profileImage?: string;
}
