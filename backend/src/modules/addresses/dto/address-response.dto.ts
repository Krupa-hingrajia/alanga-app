import { ApiProperty } from '@nestjs/swagger';
import { CustomerAddressEntity } from '../entities/customer-address.entity';

export class AddressResponseDto {
  @ApiProperty({ example: true })
  success: boolean;

  @ApiProperty({ example: 'Address retrieved successfully' })
  message: string;

  @ApiProperty({ type: CustomerAddressEntity })
  data: CustomerAddressEntity;

  @ApiProperty({ example: 200 })
  statusCode: number;
}

export class AddressListResponseDto {
  @ApiProperty({ example: true })
  success: boolean;

  @ApiProperty({ example: 'Addresses retrieved successfully' })
  message: string;

  @ApiProperty({ type: [CustomerAddressEntity] })
  data: CustomerAddressEntity[];

  @ApiProperty({ example: 200 })
  statusCode: number;
}
