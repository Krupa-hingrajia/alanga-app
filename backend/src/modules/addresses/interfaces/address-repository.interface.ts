import { CreateAddressDto } from '../dto/create-address.dto';
import { UpdateAddressDto } from '../dto/update-address.dto';
import { CustomerAddressEntity } from '../entities/customer-address.entity';

export interface IAddressRepository {
  findByCustomer(customerId: string): Promise<CustomerAddressEntity[]>;
  findById(id: string): Promise<CustomerAddressEntity | null>;
  findDefault(customerId: string): Promise<CustomerAddressEntity | null>;
  create(customerId: string, dto: CreateAddressDto): Promise<CustomerAddressEntity>;
  update(id: string, dto: UpdateAddressDto): Promise<CustomerAddressEntity>;
  delete(id: string): Promise<CustomerAddressEntity>;
  unsetCustomerDefaults(customerId: string): Promise<void>;
  setDefault(customerId: string, id: string): Promise<CustomerAddressEntity>;
}
