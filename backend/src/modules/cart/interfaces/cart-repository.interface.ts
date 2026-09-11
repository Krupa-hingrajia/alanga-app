export abstract class ICartRepository {
  abstract findByCustomer(customerId: string): Promise<any[]>;
  abstract findById(id: string): Promise<any | null>;
  abstract findExistingItem(customerId: string, productId: string, productVariantId: string): Promise<any | null>;
  abstract create(data: { customerId: string; productId: string; productVariantId: string; quantity: number }): Promise<any>;
  abstract updateQuantity(id: string, quantity: number): Promise<any>;
  abstract delete(id: string): Promise<any>;
  abstract clearCustomerCart(customerId: string): Promise<any>;
}
