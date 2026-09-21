import { Address } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CustomerAddressEntity implements Address {
  @ApiProperty({ description: 'Unique identifier for the address', example: 'd3b07384-d113-4a44-9c8e-aa9d8b375b4f' })
  id: string;

  @ApiProperty({ description: 'Customer ID of the address owner', example: 'c2a16281-c309-482a-9e12-bb912389104c' })
  customerId: string;

  @ApiProperty({ description: 'Full name of recipient', example: 'Pooja Hingrajia' })
  fullName: string;

  @ApiProperty({ description: 'Primary 10-digit mobile number', example: '9876543210' })
  mobileNumber: string;

  @ApiPropertyOptional({ description: 'Alternate mobile number', example: '9123456789', nullable: true })
  alternateMobile: string | null;

  @ApiProperty({ description: 'Flat, House no., Building, Company, Apartment', example: 'Flat 402, Green Heights' })
  addressLine1: string;

  @ApiPropertyOptional({ description: 'Area, Street, Sector, Village', example: 'SG Highway', nullable: true })
  addressLine2: string | null;

  @ApiPropertyOptional({ description: 'Nearby landmark', example: 'Near YMCA Club', nullable: true })
  landmark: string | null;

  @ApiProperty({ description: 'Town or City', example: 'Ahmedabad' })
  city: string;

  @ApiProperty({ description: 'State or Province', example: 'Gujarat' })
  state: string;

  @ApiProperty({ description: 'Country', example: 'India' })
  country: string;

  @ApiProperty({ description: '6-digit Postal code / Pincode', example: '380015' })
  postalCode: string;

  @ApiProperty({ description: 'Address categorization type', example: 'HOME', enum: ['HOME', 'OFFICE', 'OTHER'] })
  addressType: string;

  @ApiProperty({ description: 'Indicates if this is the primary default shipping address', example: true })
  isDefault: boolean;

  @ApiProperty({ description: 'Creation timestamp' })
  createdAt: Date;

  @ApiProperty({ description: 'Last update timestamp' })
  updatedAt: Date;

  @ApiPropertyOptional({ description: 'Soft deletion timestamp', nullable: true })
  deletedAt: Date | null;

  constructor(partial: Partial<CustomerAddressEntity>) {
    Object.assign(this, partial);
  }
}
