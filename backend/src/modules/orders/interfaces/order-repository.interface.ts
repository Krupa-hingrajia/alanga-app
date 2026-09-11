import { AdminOrderQueryDto } from '../dto/admin-order-query.dto';

export interface IOrderRepository {
  createOrder(data: any, tx?: any): Promise<any>;
  findById(id: string): Promise<any | null>;
  findByOrderNumber(orderNumber: string): Promise<any | null>;
  findByCustomer(customerId: string): Promise<any[]>;
  findByVendor(vendorId: string): Promise<any[]>;
  findAll(query: AdminOrderQueryDto): Promise<{ items: any[]; total: number; page: number; limit: number }>;
  updateStatus(orderId: string, status: string, tx?: any): Promise<any>;
  updateOrderItemStatus(orderItemId: string, status: string, tx?: any): Promise<any>;
  countTodayOrders(): Promise<number>;
}
