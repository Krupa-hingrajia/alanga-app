import React from 'react';
import {
  ShoppingCart,
  User,
  Store,
  MapPin,
  Package,
  CreditCard,
  Calendar,
  Edit,
  Truck,
  CheckCircle2,
  Clock,
  RotateCw,
  Box,
  XCircle,
  AlertTriangle,
  Phone,
  Mail,
  Receipt,
  Layers,
} from 'lucide-react';
import { Order } from '../api';
import { StatusBadge } from '@/components/StatusBadge';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';

interface OrderDetailModalProps {
  order: Order | null;
  vendorNameMap?: Record<string, string>;
  vendorMap?: Record<string, { name: string; email?: string; phone?: string }>;
  open: boolean;
  onClose: () => void;
  onOpenStatusDialog: (order: Order) => void;
}

const TIMELINE_STEPS = [
  { key: 'PENDING', label: 'Order Placed', desc: 'Customer placed order' },
  { key: 'CONFIRMED', label: 'Confirmed', desc: 'Accepted by vendor' },
  { key: 'PROCESSING', label: 'Processing', desc: 'Warehouse packaging' },
  { key: 'PACKED', label: 'Packed', desc: 'Ready for dispatch' },
  { key: 'SHIPPED', label: 'Shipped', desc: 'In transit with courier' },
  { key: 'OUT_FOR_DELIVERY', label: 'Out for Delivery', desc: 'Last-mile delivery' },
  { key: 'DELIVERED', label: 'Delivered', desc: 'Completed & received' },
];

function getStatusRank(status: string): number {
  switch (status?.toUpperCase()) {
    case 'PENDING':
      return 0;
    case 'CONFIRMED':
      return 1;
    case 'PROCESSING':
      return 2;
    case 'PACKED':
      return 3;
    case 'SHIPPED':
      return 4;
    case 'OUT_FOR_DELIVERY':
      return 5;
    case 'DELIVERED':
    case 'PARTIALLY_DELIVERED':
      return 6;
    case 'CANCELLED':
      return -1;
    default:
      return 0;
  }
}

export function OrderDetailModal({
  order,
  vendorNameMap = {},
  vendorMap = {},
  open,
  onClose,
  onOpenStatusDialog,
}: OrderDetailModalProps) {
  if (!order) return null;

  const formatPrice = (value?: number) => {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 0,
    }).format(value || 0);
  };

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return 'N/A';
    try {
      return new Date(dateStr).toLocaleString('en-IN', {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      });
    } catch {
      return dateStr;
    }
  };

  const isCancelled = order.status?.toUpperCase() === 'CANCELLED';
  const currentRank = getStatusRank(order.status);
  const address = order.address || order.shippingAddressSnapshot;
  const grandTotal = order.grandTotal || order.totalAmount || 0;

  // Group items by Vendor to clearly separate packages in multi-vendor orders
  const vendorPackages = React.useMemo(() => {
    const map = new Map<
      string,
      {
        vendorId: string;
        vendorName: string;
        vendorEmail?: string;
        vendorPhone?: string;
        items: NonNullable<typeof order.orderItems>;
        subtotal: number;
        shippingCharge: number;
        total: number;
        status: string;
      }
    >();

    for (const item of order.orderItems || []) {
      const vId = item.vendorId || (item.product as any)?.vendorId || 'marketplace';
      if (!map.has(vId)) {
        const vProduct = (item.product as any)?.vendor;
        const vGlobal = vendorMap?.[vId];
        map.set(vId, {
          vendorId: vId,
          vendorName:
            vProduct?.fullName ||
            vGlobal?.name ||
            vendorNameMap[vId] ||
            `Vendor #${vId.slice(0, 6)}`,
          vendorEmail: vProduct?.email || vGlobal?.email,
          vendorPhone: vProduct?.phoneNumber || vGlobal?.phone,
          items: [],
          subtotal: 0,
          shippingCharge: 0,
          total: 0,
          status: item.status,
        });
      }
      const pkg = map.get(vId)!;
      pkg.items.push(item);
      pkg.subtotal += item.unitPrice * item.quantity;
      pkg.shippingCharge += item.shippingCharge || 0;
      pkg.total += item.totalPrice;
      if (item.status !== pkg.status) {
        pkg.status = 'MIXED';
      }
    }
    return Array.from(map.values());
  }, [order.orderItems, vendorMap, vendorNameMap]);

  const isMultiVendor = vendorPackages.length > 1;

  return (
    <Dialog open={open} onOpenChange={(val) => { if (!val) onClose(); }}>
      <DialogContent className="sm:max-w-4xl rounded-3xl p-6 max-h-[88vh] overflow-y-auto">
        <DialogHeader className="border-b border-zinc-100 dark:border-zinc-800 pb-4">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div className="flex items-center gap-3">
              <div className="p-2.5 bg-teal-500/10 text-teal-600 dark:bg-teal-500/20 dark:text-teal-400 rounded-2xl shrink-0">
                <ShoppingCart className="h-6 w-6" />
              </div>
              <div>
                <DialogTitle className="text-lg font-bold text-zinc-900 dark:text-zinc-50 flex items-center gap-2">
                  <span>Order #{order.orderNumber}</span>
                  {isMultiVendor && (
                    <span className="px-2 py-0.5 rounded-md bg-purple-50 dark:bg-purple-950/40 text-purple-700 dark:text-purple-300 text-[10px] font-semibold border border-purple-200 dark:border-purple-800">
                      Multi-Vendor ({vendorPackages.length})
                    </span>
                  )}
                </DialogTitle>
                <p className="text-xs text-zinc-400 mt-0.5">
                  Placed on {formatDate(order.createdAt)} • Payment via {order.paymentMethod}
                </p>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <StatusBadge status={order.status} />
              <Button
                variant="outline"
                size="sm"
                onClick={() => onOpenStatusDialog(order)}
                className="h-8 px-3 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold gap-1.5 cursor-pointer hover:bg-zinc-100 dark:hover:bg-zinc-800"
              >
                <Edit className="h-3.5 w-3.5 text-blue-500" />
                <span>Update Status</span>
              </Button>
            </div>
          </div>
        </DialogHeader>

        <div className="space-y-6 pt-3 text-xs">
          {/* 4 Summary Cards: Customer, Address, Payment, Fulfillment Overview */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
            {/* 1. Customer Info */}
            <div className="p-4 rounded-2xl bg-zinc-50/80 dark:bg-zinc-900/60 border border-zinc-200/60 dark:border-zinc-800 space-y-2">
              <div className="flex items-center gap-2 text-zinc-500 dark:text-zinc-400 font-bold uppercase text-[10px] tracking-wider">
                <User className="h-3.5 w-3.5 text-emerald-600" />
                <span>Customer</span>
              </div>
              <div className="space-y-1">
                <p className="font-bold text-zinc-900 dark:text-zinc-100 text-sm">
                  {order.customer?.fullName || address?.fullName || 'Customer'}
                </p>
                {order.customer?.email && (
                  <p className="text-zinc-500 dark:text-zinc-400 flex items-center gap-1.5 truncate">
                    <Mail className="h-3 w-3 text-zinc-400 shrink-0" />
                    <span>{order.customer.email}</span>
                  </p>
                )}
                {(order.customer?.phoneNumber || address?.mobileNumber) && (
                  <p className="text-zinc-500 dark:text-zinc-400 flex items-center gap-1.5">
                    <Phone className="h-3 w-3 text-zinc-400 shrink-0" />
                    <span>{order.customer?.phoneNumber || address?.mobileNumber}</span>
                  </p>
                )}
              </div>
            </div>

            {/* 2. Delivery Address */}
            <div className="p-4 rounded-2xl bg-zinc-50/80 dark:bg-zinc-900/60 border border-zinc-200/60 dark:border-zinc-800 space-y-2">
              <div className="flex items-center gap-2 text-zinc-500 dark:text-zinc-400 font-bold uppercase text-[10px] tracking-wider">
                <MapPin className="h-3.5 w-3.5 text-rose-600" />
                <span>Delivery Address</span>
              </div>
              {address ? (
                <div className="text-zinc-600 dark:text-zinc-400 space-y-0.5">
                  <p className="font-bold text-zinc-900 dark:text-zinc-100 truncate">
                    {address.fullName}
                  </p>
                  <p className="text-xs leading-relaxed">
                    {address.addressLine1}
                    {address.addressLine2 ? `, ${address.addressLine2}` : ''}
                  </p>
                  <p className="text-xs font-semibold text-zinc-700 dark:text-zinc-300">
                    {address.city}, {address.state} - {address.postalCode}
                  </p>
                  {address.landmark && (
                    <p className="text-[11px] text-zinc-400 truncate">Landmark: {address.landmark}</p>
                  )}
                </div>
              ) : (
                <p className="text-zinc-400 italic">No address provided</p>
              )}
            </div>

            {/* 3. Payment Details */}
            <div className="p-4 rounded-2xl bg-zinc-50/80 dark:bg-zinc-900/60 border border-zinc-200/60 dark:border-zinc-800 space-y-2">
              <div className="flex items-center gap-2 text-zinc-500 dark:text-zinc-400 font-bold uppercase text-[10px] tracking-wider">
                <CreditCard className="h-3.5 w-3.5 text-purple-600" />
                <span>Payment Details</span>
              </div>
              <div className="space-y-1">
                <div className="flex items-center justify-between">
                  <span className="text-zinc-400">Method:</span>
                  <span className="font-semibold text-zinc-800 dark:text-zinc-200">{order.paymentMethod}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-zinc-400">Status:</span>
                  <StatusBadge status={order.paymentStatus || 'PENDING'} className="text-[10px] px-2 py-0" />
                </div>
                <div className="flex items-center justify-between pt-1 border-t border-zinc-200/60 dark:border-zinc-800">
                  <span className="text-zinc-400 font-medium">Grand Total:</span>
                  <span className="font-bold text-emerald-600 dark:text-emerald-400 font-mono text-sm">
                    {formatPrice(grandTotal)}
                  </span>
                </div>
              </div>
            </div>

            {/* 4. Marketplace Vendors Summary */}
            <div className="p-4 rounded-2xl bg-zinc-50/80 dark:bg-zinc-900/60 border border-zinc-200/60 dark:border-zinc-800 space-y-2">
              <div className="flex items-center gap-2 text-zinc-500 dark:text-zinc-400 font-bold uppercase text-[10px] tracking-wider">
                <Store className="h-3.5 w-3.5 text-blue-600" />
                <span>Vendors ({vendorPackages.length})</span>
              </div>
              <div className="space-y-1.5">
                {vendorPackages.map((pkg) => (
                  <div key={pkg.vendorId} className="flex items-center justify-between gap-2">
                    <span className="font-semibold text-zinc-800 dark:text-zinc-200 truncate">
                      {pkg.vendorName}
                    </span>
                    <StatusBadge status={pkg.status} className="text-[9px] px-1.5 py-0 shrink-0" />
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* 7-Step Fulfillment Timeline */}
          <div className="p-4 rounded-2xl bg-zinc-50/60 dark:bg-zinc-900/40 border border-zinc-200/60 dark:border-zinc-800 space-y-3">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300 font-bold text-xs uppercase tracking-wider">
                <Truck className="h-4 w-4 text-teal-600" />
                <span>Marketplace Fulfillment Progress</span>
              </div>
              {isCancelled ? (
                <span className="text-xs font-bold text-rose-600 flex items-center gap-1">
                  <XCircle className="h-4 w-4" /> Cancelled
                </span>
              ) : (
                <span className="text-xs font-semibold text-zinc-500">
                  Current Stage: <span className="text-emerald-600 font-bold">{order.status}</span>
                </span>
              )}
            </div>

            {/* Timeline Steps */}
            <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-7 gap-2 pt-1">
              {TIMELINE_STEPS.map((step, idx) => {
                const isPassed = !isCancelled && currentRank >= idx;
                const isCurrent = !isCancelled && currentRank === idx;

                return (
                  <div
                    key={step.key}
                    className={`p-2.5 rounded-xl border text-center transition-all ${
                      isCurrent
                        ? 'bg-emerald-500/10 border-emerald-500 ring-1 ring-emerald-500/30'
                        : isPassed
                        ? 'bg-emerald-50/60 dark:bg-emerald-950/20 border-emerald-200/60 dark:border-emerald-900/40 text-zinc-700 dark:text-zinc-300'
                        : 'bg-white dark:bg-zinc-950 border-zinc-200/60 dark:border-zinc-800 text-zinc-400'
                    }`}
                  >
                    <div className="flex justify-center mb-1">
                      {isPassed ? (
                        <CheckCircle2 className="h-4 w-4 text-emerald-600" />
                      ) : (
                        <div className="h-4 w-4 rounded-full border border-zinc-300 dark:border-zinc-700 flex items-center justify-center text-[9px] font-bold">
                          {idx + 1}
                        </div>
                      )}
                    </div>
                    <p className={`font-bold text-[11px] truncate ${isCurrent ? 'text-emerald-700 dark:text-emerald-300' : ''}`}>
                      {step.label}
                    </p>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Ordered Products Grouped by Vendor / Package */}
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="font-bold text-sm text-zinc-900 dark:text-zinc-100 flex items-center gap-2">
                <Package className="h-4 w-4 text-emerald-600" />
                <span>
                  Ordered Products ({order.orderItems?.length || 0} items across {vendorPackages.length} package
                  {vendorPackages.length > 1 ? 's' : ''})
                </span>
              </h3>
            </div>

            {/* Vendor Packages */}
            <div className="space-y-4">
              {vendorPackages.map((pkg, pkgIdx) => (
                <div
                  key={pkg.vendorId}
                  className="rounded-2xl border border-zinc-200/80 dark:border-zinc-800 bg-white dark:bg-zinc-950 overflow-hidden shadow-2xs"
                >
                  {/* Package Header */}
                  <div className="p-3.5 bg-zinc-50/90 dark:bg-zinc-900/90 border-b border-zinc-200/80 dark:border-zinc-800 flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                    <div className="flex items-center gap-2.5">
                      <div className="p-2 bg-blue-50 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400 rounded-xl">
                        <Store className="h-4 w-4" />
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <p className="font-bold text-xs text-zinc-900 dark:text-zinc-100">
                            Package {pkgIdx + 1}: Fulfilled by {pkg.vendorName}
                          </p>
                          <StatusBadge status={pkg.status} className="text-[9px] px-2 py-0" />
                        </div>
                        <p className="text-[11px] text-zinc-400">
                          {pkg.vendorEmail || 'Verified Vendor'} {pkg.vendorPhone ? `• ${pkg.vendorPhone}` : ''}
                        </p>
                      </div>
                    </div>

                    <div className="text-right text-xs">
                      <span className="text-zinc-400 text-[11px]">Package Subtotal: </span>
                      <span className="font-bold text-zinc-900 dark:text-zinc-100 font-mono">
                        {formatPrice(pkg.total)}
                      </span>
                    </div>
                  </div>

                  {/* Items Table for this Vendor */}
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs">
                      <thead className="bg-zinc-50/50 dark:bg-zinc-900/50 text-zinc-400 font-semibold uppercase text-[10px] border-b border-zinc-100 dark:border-zinc-850">
                        <tr>
                          <th className="p-3">Product</th>
                          <th className="p-3">SKU</th>
                          <th className="p-3 text-center">Qty</th>
                          <th className="p-3 text-right">Unit Price</th>
                          <th className="p-3 text-right">Shipping</th>
                          <th className="p-3 text-right">Total</th>
                          <th className="p-3 text-center">Fulfillment</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-zinc-100 dark:divide-zinc-900">
                        {pkg.items.map((item) => (
                          <tr key={item.id} className="hover:bg-zinc-50/50 dark:hover:bg-zinc-900/30">
                            <td className="p-3">
                              <div className="flex items-center gap-3">
                                <div className="h-10 w-10 rounded-xl bg-zinc-100 dark:bg-zinc-800 flex items-center justify-center shrink-0 overflow-hidden border border-zinc-200 dark:border-zinc-700">
                                  {item.product?.image ? (
                                    <img
                                      src={item.product.image}
                                      alt={item.productNameSnapshot}
                                      className="h-full w-full object-cover"
                                    />
                                  ) : (
                                    <Package className="h-5 w-5 text-zinc-400" />
                                  )}
                                </div>
                                <div>
                                  <p className="font-semibold text-zinc-900 dark:text-zinc-100 line-clamp-1">
                                    {item.productNameSnapshot}
                                  </p>
                                  {item.variantNameSnapshot && (
                                    <p className="text-[11px] text-zinc-500">
                                      Variant: {item.variantNameSnapshot}
                                    </p>
                                  )}
                                </div>
                              </div>
                            </td>
                            <td className="p-3 font-mono text-[11px] text-zinc-500">
                              {item.sku || 'N/A'}
                            </td>
                            <td className="p-3 text-center font-semibold text-zinc-800 dark:text-zinc-200">
                              {item.quantity}
                            </td>
                            <td className="p-3 text-right text-zinc-600 dark:text-zinc-400 font-mono">
                              {formatPrice(item.unitPrice)}
                            </td>
                            <td className="p-3 text-right text-zinc-600 dark:text-zinc-400 font-mono">
                              {item.shippingCharge > 0 ? formatPrice(item.shippingCharge) : 'Free'}
                            </td>
                            <td className="p-3 text-right font-bold text-zinc-900 dark:text-zinc-100 font-mono">
                              {formatPrice(item.totalPrice)}
                            </td>
                            <td className="p-3 text-center">
                              <StatusBadge status={item.status} className="text-[9px] px-1.5 py-0" />
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Grand Total Breakdown Card */}
          <div className="flex flex-col sm:flex-row justify-end pt-2">
            <div className="w-full sm:w-80 p-4 rounded-2xl bg-zinc-50/80 dark:bg-zinc-900/60 border border-zinc-200/60 dark:border-zinc-800 space-y-2 text-xs">
              <div className="flex justify-between text-zinc-500">
                <span>Total Items Subtotal</span>
                <span className="font-semibold text-zinc-700 dark:text-zinc-300 font-mono">
                  {formatPrice(order.subtotal)}
                </span>
              </div>
              <div className="flex justify-between text-zinc-500">
                <span>Total Shipping Charges</span>
                <span className="font-semibold text-zinc-700 dark:text-zinc-300 font-mono">
                  {order.shippingCharge > 0 ? formatPrice(order.shippingCharge) : 'Free'}
                </span>
              </div>
              <div className="border-t border-zinc-200 dark:border-zinc-800 pt-2 flex justify-between items-center text-sm">
                <span className="font-bold text-zinc-900 dark:text-zinc-100">Grand Total</span>
                <span className="font-bold text-emerald-600 dark:text-emerald-400 text-base font-mono">
                  {formatPrice(grandTotal)}
                </span>
              </div>
            </div>
          </div>
        </div>

        <DialogFooter className="pt-4 border-t border-zinc-100 dark:border-zinc-800 flex justify-between items-center">
          <p className="text-[11px] text-zinc-400">
            Marketplace Super Admin Order Inspection
          </p>
          <Button
            variant="outline"
            onClick={onClose}
            className="rounded-xl h-9 text-xs px-4"
          >
            Close
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
