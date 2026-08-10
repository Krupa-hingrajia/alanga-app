import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsEnum, IsNotEmpty, IsOptional, IsString, Matches, MinLength } from 'class-validator';
import { Role } from '@prisma/client';
import { Match } from '../../../common/decorators/match.decorator';

export class RegisterDto {
  @ApiProperty({ example: 'John Doe', description: 'Full name of the user' })
  @IsNotEmpty()
  @IsString()
  @MinLength(2)
  fullName: string;

  @ApiProperty({ example: 'john.doe@example.com', description: 'Unique email address' })
  @IsNotEmpty()
  @IsEmail()
  email: string;

  @ApiProperty({ example: '+91', description: 'Country dialing code' })
  @IsNotEmpty()
  @IsString()
  countryCode: string;

  @ApiProperty({ example: '9876543210', description: 'Unique mobile number' })
  @IsNotEmpty()
  @IsString()
  @Matches(/^\d{7,15}$/, { message: 'Mobile number must be between 7 and 15 digits' })
  mobileNumber: string;

  @ApiProperty({
    example: 'SecurePass123!',
    description: 'Password containing min 8 chars, uppercase, lowercase, number, and special character',
  })
  @IsNotEmpty()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/, {
    message: 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character (@$!%*?&)',
  })
  password: string;

  @ApiProperty({ example: 'SecurePass123!', description: 'Must match password' })
  @IsNotEmpty()
  @Match('password', { message: 'Confirm password does not match password' })
  confirmPassword: string;

  @ApiProperty({ enum: Role, example: Role.CUSTOMER, description: 'Role of the user' })
  @IsNotEmpty()
  @IsEnum(Role)
  role: Role;

  @ApiProperty({ example: 'My Store', description: 'Business Name (Vendors only)', required: false })
  @IsOptional()
  @IsString()
  businessName?: string;

  @ApiProperty({ example: 'Retailer', description: 'Business Type (Vendors only)', required: false })
  @IsOptional()
  @IsString()
  businessType?: string;

  @ApiProperty({ example: 'Mumbai', description: 'City (Vendors only)', required: false })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiProperty({ example: 'Maharashtra', description: 'State (Vendors only)', required: false })
  @IsOptional()
  @IsString()
  state?: string;

  @ApiProperty({ example: '400001', description: 'Pincode (Vendors only)', required: false })
  @IsOptional()
  @IsString()
  pincode?: string;

  @ApiProperty({ example: '22AAAAA0000A1Z5', description: 'GST Number (Optional)', required: false })
  @IsOptional()
  @IsString()
  gstNumber?: string;

  @ApiProperty({ example: 'ABCDE1234F', description: 'PAN Number (Optional)', required: false })
  @IsOptional()
  @IsString()
  panNumber?: string;
}
