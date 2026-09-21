import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsEnum } from 'class-validator';

export enum AddressType {
  HOME = 'HOME',
  OFFICE = 'OFFICE',
  OTHER = 'OTHER',
}

export class CreateAddressDto {
  @ApiProperty({ description: 'Full name of recipient', example: 'Pooja Hingrajia' })
  @IsString()
  @IsNotEmpty({ message: 'Full Name is required' })
  fullName: string;

  @ApiProperty({ description: 'Primary 10-digit mobile number', example: '9876543210' })
  @IsString()
  @IsNotEmpty({ message: 'Mobile Number is required' })
  mobileNumber: string;

  @ApiPropertyOptional({ description: 'Alternate contact number', example: '9123456789' })
  @IsString()
  @IsOptional()
  alternateMobile?: string;

  @ApiProperty({ description: 'House / Flat / Building / Street address', example: 'Flat 402, Green Heights' })
  @IsString()
  @IsNotEmpty({ message: 'Address Line 1 is required' })
  addressLine1: string;

  @ApiPropertyOptional({ description: 'Area / Colony / Sector', example: 'SG Highway' })
  @IsString()
  @IsOptional()
  addressLine2?: string;

  @ApiPropertyOptional({ description: 'Nearby landmark', example: 'Near YMCA Club' })
  @IsString()
  @IsOptional()
  landmark?: string;

  @ApiProperty({ description: 'City / Town', example: 'Ahmedabad' })
  @IsString()
  @IsNotEmpty({ message: 'City is required' })
  city: string;

  @ApiProperty({ description: 'State / Province', example: 'Gujarat' })
  @IsString()
  @IsNotEmpty({ message: 'State is required' })
  state: string;

  @ApiProperty({ description: 'Country', example: 'India', default: 'India' })
  @IsString()
  @IsNotEmpty({ message: 'Country is required' })
  country: string = 'India';

  @ApiProperty({ description: 'Postal Code / Pincode', example: '380015' })
  @IsString()
  @IsNotEmpty({ message: 'Postal Code is required' })
  postalCode: string;

  @ApiPropertyOptional({
    description: 'Categorization of address (HOME | OFFICE | OTHER)',
    enum: AddressType,
    default: AddressType.HOME,
  })
  @IsEnum(AddressType, { message: 'Address Type must be HOME, OFFICE, or OTHER' })
  @IsOptional()
  addressType?: AddressType = AddressType.HOME;

  @ApiPropertyOptional({ description: 'Mark as default shipping address', example: false, default: false })
  @IsBoolean()
  @IsOptional()
  isDefault?: boolean = false;
}
