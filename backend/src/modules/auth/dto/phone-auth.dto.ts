import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsOptional, IsEmail, IsEnum } from 'class-validator';
import { Role } from '@prisma/client';

export class PhoneAuthDto {
  @ApiProperty({ description: 'Vendor phone number with country code (e.g. +919999999999 or +971501234567)', example: '+919999999999' })
  @IsNotEmpty()
  @IsString()
  phoneNumber: string;

  @ApiPropertyOptional({ description: 'Full name for new registration', example: 'Rahul Sharma' })
  @IsOptional()
  @IsString()
  fullName?: string;

  @ApiPropertyOptional({ description: 'Store or business name for new registration', example: 'Sharma Textiles' })
  @IsOptional()
  @IsString()
  businessName?: string;

  @ApiPropertyOptional({ description: 'Email address', example: 'vendor@example.com' })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ description: 'Target user role', enum: Role, default: Role.VENDOR })
  @IsOptional()
  @IsEnum(Role)
  role?: Role;

  @ApiPropertyOptional({ description: 'Firebase Auth UID for tracking', example: 'firebase-uid-123' })
  @IsOptional()
  @IsString()
  firebaseUid?: string;
}
