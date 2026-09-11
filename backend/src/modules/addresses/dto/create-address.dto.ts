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
  @IsNotEmpty()
  fullName: string;

  @ApiProperty({ description: 'Mobile number', example: '9876543210' })
  @IsString()
  @IsNotEmpty()
  mobileNumber: string;

  @ApiPropertyOptional({ description: 'Alternate mobile number', example: '9123456789' })
  @IsString()
  @IsOptional()
  alternateMobile?: string;

  @ApiProperty({ description: 'House / Flat / Building No. / Street', example: 'Flat 402, Green Heights' })
  @IsString()
  @IsNotEmpty()
  addressLine1: string;

  @ApiPropertyOptional({ description: 'Area / Colony / Sector', example: 'SG Highway' })
  @IsString()
  @IsOptional()
  addressLine2?: string;

  @ApiPropertyOptional({ description: 'Nearby Landmark', example: 'Near YMCA Club' })
  @IsString()
  @IsOptional()
  landmark?: string;

  @ApiProperty({ description: 'City / Town', example: 'Ahmedabad' })
  @IsString()
  @IsNotEmpty()
  city: string;

  @ApiProperty({ description: 'State', example: 'Gujarat' })
  @IsString()
  @IsNotEmpty()
  state: string;

  @ApiProperty({ description: 'Country', example: 'India', default: 'India' })
  @IsString()
  @IsOptional()
  country?: string = 'India';

  @ApiProperty({ description: 'Postal Code / Pincode', example: '380015' })
  @IsString()
  @IsNotEmpty()
  postalCode: string;

  @ApiProperty({ description: 'Address Type (HOME / OFFICE / OTHER)', example: 'HOME', enum: AddressType, default: 'HOME' })
  @IsEnum(AddressType)
  @IsOptional()
  addressType?: AddressType = AddressType.HOME;

  @ApiPropertyOptional({ description: 'Set as default address', example: false, default: false })
  @IsBoolean()
  @IsOptional()
  isDefault?: boolean = false;
}
