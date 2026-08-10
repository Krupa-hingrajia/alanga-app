import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsEnum, IsNotEmpty, IsString, Matches, MinLength } from 'class-validator';
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
}
