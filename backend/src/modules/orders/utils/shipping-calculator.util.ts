export interface ShippingRule {
  isFreeShipping?: boolean | null;
  freeShippingAboveAmount?: number | null;
  shippingCharge?: number | null;
  estimatedDeliveryMinDays?: number | null;
  estimatedDeliveryMaxDays?: number | null;
}

/**
 * Calculates shipping fee for an item based on its subtotal and product shipping configuration.
 */
export function calculateItemShippingFee(
  shipping: ShippingRule | null | undefined,
  itemSubtotal: number,
): number {
  if (!shipping) return 0;
  if (shipping.isFreeShipping) return 0;
  if (
    shipping.freeShippingAboveAmount != null &&
    shipping.freeShippingAboveAmount > 0 &&
    itemSubtotal >= shipping.freeShippingAboveAmount
  ) {
    return 0;
  }
  return Number(shipping.shippingCharge ?? 0);
}
