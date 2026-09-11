import { CreateAddressDto } from '../dto/create-address.dto';
import { UpdateAddressDto } from '../dto/update-address.dto';

export interface IAddressRepository {
  findByCustomer(customerId: string): Promise<any[]>;
  findById(id: string): Promise<any | null>;
  findDefault(customerId: string): Promise<any | null>;
  create(customerId: string, dto: CreateAddressDto): Promise<any>;
  update(id: string, dto: UpdateAddressDto): Promise<any>;
  delete(id: string): Promise<any>;
  unsetCustomerDefaults(customerId: string): Promise<void>;
  setDefault(customerId: string, id: string): Promise<any>;
}
