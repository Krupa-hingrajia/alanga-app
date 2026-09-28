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

  @ApiProperty({ example: 'My Store Pvt Ltd', description: 'Legal Entity Name', required: false })
  @IsOptional()
  @IsString()
  legalName?: string;

  @ApiProperty({ example: 'Shop 12, Main Market', description: 'Pickup Address Line 1', required: false })
  @IsOptional()
  @IsString()
  pickupAddressLine1?: string;

  @ApiProperty({ example: 'Near Metro Station', description: 'Pickup Address Line 2 / Landmark', required: false })
  @IsOptional()
  @IsString()
  pickupAddressLine2?: string;

  @ApiProperty({ example: '9876543210', description: 'Pickup Contact Phone', required: false })
  @IsOptional()
  @IsString()
  pickupContactPhone?: string;

  @ApiProperty({ example: 'John Doe', description: 'Bank Account Holder Name', required: false })
  @IsOptional()
  @IsString()
  bankAccountHolderName?: string;

  @ApiProperty({ example: '123456789012', description: 'Bank Account Number', required: false })
  @IsOptional()
  @IsString()
  bankAccountNumber?: string;

  @ApiProperty({ example: 'HDFC0001234', description: 'Bank IFSC Code', required: false })
  @IsOptional()
  @IsString()
  bankIfscCode?: string;

  @ApiProperty({ example: 'HDFC Bank', description: 'Bank Name', required: false })
  @IsOptional()
  @IsString()
  bankName?: string;

  @ApiProperty({ example: 'CURRENT', description: 'Bank Account Type (CURRENT / SAVINGS)', required: false })
  @IsOptional()
  @IsString()
  bankAccountType?: string;

  @ApiProperty({ description: 'PAN Card Image / URL', required: false })
  @IsOptional()
  @IsString()
  panCardUrl?: string;

  @ApiProperty({ description: 'GST Certificate Image / URL', required: false })
  @IsOptional()
  @IsString()
  gstCertificateUrl?: string;

  @ApiProperty({ description: 'Cancelled Cheque Image / URL', required: false })
  @IsOptional()
  @IsString()
  cancelledChequeUrl?: string;

  @ApiProperty({ description: 'Digital Signature Image / URL', required: false })
  @IsOptional()
  @IsString()
  digitalSignatureUrl?: string;
}
