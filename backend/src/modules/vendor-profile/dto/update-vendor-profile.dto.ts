import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class UpdateVendorProfileDto {
  // 1. Business Identity
  @ApiProperty({ example: 'Alanga Superstore', required: false })
  @IsOptional()
  @IsString()
  storeName?: string;

  @ApiProperty({ example: 'Alanga Enterprises Private Limited', required: false })
  @IsOptional()
  @IsString()
  legalName?: string;

  @ApiProperty({ example: 'Retailer', required: false })
  @IsOptional()
  @IsString()
  businessType?: string;

  @ApiProperty({ example: 'Official fashion and electronics supplier', required: false })
  @IsOptional()
  @IsString()
  businessDescription?: string;

  // 2. Tax & Legal (KYC)
  @ApiProperty({ example: 'ABCDE1234F', required: false })
  @IsOptional()
  @IsString()
  panNumber?: string;

  @ApiProperty({ example: 'https://storage.../pan.jpg', required: false })
  @IsOptional()
  @IsString()
  panCardUrl?: string;

  @ApiProperty({ example: '24AAAAA0000A1Z5', required: false })
  @IsOptional()
  @IsString()
  gstNumber?: string;

  @ApiProperty({ example: 'https://storage.../gst.pdf', required: false })
  @IsOptional()
  @IsString()
  gstCertificateUrl?: string;

  // 3. Pickup & Warehouse Address
  @ApiProperty({ example: 'Building 4, Plot 12, Industrial Estate', required: false })
  @IsOptional()
  @IsString()
  pickupAddressLine1?: string;

  @ApiProperty({ example: 'Opposite Metro Station Gate 2', required: false })
  @IsOptional()
  @IsString()
  pickupAddressLine2?: string;

  @ApiProperty({ example: 'Ahmedabad', required: false })
  @IsOptional()
  @IsString()
  pickupCity?: string;

  @ApiProperty({ example: 'Gujarat', required: false })
  @IsOptional()
  @IsString()
  pickupState?: string;

  @ApiProperty({ example: '380001', required: false })
  @IsOptional()
  @IsString()
  pickupPincode?: string;

  @ApiProperty({ example: '9876543210', required: false })
  @IsOptional()
  @IsString()
  pickupContactPhone?: string;

  // 4. Bank Account Details (Payouts)
  @ApiProperty({ example: 'Alanga Superstore Pvt Ltd', required: false })
  @IsOptional()
  @IsString()
  bankAccountHolderName?: string;

  @ApiProperty({ example: '50200012345678', required: false })
  @IsOptional()
  @IsString()
  bankAccountNumber?: string;

  @ApiProperty({ example: 'HDFC0001234', required: false })
  @IsOptional()
  @IsString()
  bankIfscCode?: string;

  @ApiProperty({ example: 'HDFC Bank', required: false })
  @IsOptional()
  @IsString()
  bankName?: string;

  @ApiProperty({ example: 'CURRENT', required: false })
  @IsOptional()
  @IsString()
  bankAccountType?: string;

  @ApiProperty({ example: 'https://storage.../cheque.jpg', required: false })
  @IsOptional()
  @IsString()
  cancelledChequeUrl?: string;

  // 5. Digital Signature
  @ApiProperty({ example: 'https://storage.../signature.png or authorized name', required: false })
  @IsOptional()
  @IsString()
  digitalSignatureUrl?: string;
}
