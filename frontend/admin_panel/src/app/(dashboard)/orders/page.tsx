'use client';

import React, { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
  ShoppingCart,
  Search,
  Eye,
  Edit,
  Trash2,
  Calendar,
  CreditCard,
  MapPin,
  User,
  Package,
  ArrowUpDown,
  ArrowUp,
  ArrowDown,
  Inbox,
  Clock,
  CheckCircle,
  Truck,
  IndianRupee,
} from 'lucide-react';

import {
  getAdminOrders,
  updateAdminOrderStatus,
  Order,
} from '@/features/orders/api';
import { StatusBadge } from '@/components/StatusBadge';
import { MarketplacePagination } from '@/components/MarketplacePagination';
import { ConfirmDialog } from '@/components/ConfirmDialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

const ORDER_STATUS_FILTERS = [
  'ALL',
  'PENDING',
  'CONFIRMED',
  'PROCESSING',
  'SHIPPED',
  'DELIVERED',
  'CANCELLED',
];

export default function OrdersPage() {
  const queryClient = useQueryClient();

  // Filters & Pagination
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [page, setPage] = useState(1);
  const limit = 10;

  // Sorting
  const [sortField, setSortField] = useState<'orderNumber' | 'createdAt' | 'totalAmount' | 'status'>('createdAt');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Modals
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [editingOrder, setEditingOrder] = useState<Order | null>(null);
  const [editStatus, setEditStatus] = useState<string>('CONFIRMED');

  // Confirmation dialogs
  const [cancelTarget, setCancelTarget] = useState<Order | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['adminOrders', search, statusFilter, page],
    queryFn: () =>
      getAdminOrders({
        search: search.trim() || undefined,
        status: statusFilter === 'ALL' ? undefined : statusFilter,
        page,
        limit,
      }),
  });

  const orders: Order[] = data?.items ?? [];

  // Sorting
  const sortedOrders = useMemo(() => {
    if (!orders) return [];
    return [...orders].sort((a, b) => {
      let aVal: any = a[sortField];
      let bVal: any = b[sortField];

      if (sortField === 'totalAmount') {
        aVal = a.totalAmount || 0;
        bVal = b.totalAmount || 0;
        return sortDirection === 'asc' ? aVal - bVal : bVal - aVal;
      }

      if (typeof aVal === 'string') {
        return sortDirection === 'asc'
          ? aVal.localeCompare(bVal || '')
          : (bVal || '').localeCompare(aVal);
      }
      return sortDirection === 'asc' ? (aVal > bVal ? 1 : -1) : aVal < bVal ? 1 : -1;
    });
  }, [orders, sortField, sortDirection]);

  const handleSort = (field: 'orderNumber' | 'createdAt' | 'totalAmount' | 'status') => {
    if (sortField === field) {
      setSortDirection((prev) => (prev === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortField(field);
      setSortDirection('asc');
    }
  };

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ['adminOrders'] });
    queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
  };

  const updateStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      updateAdminOrderStatus(id, status),
    onSuccess: (updated) => {
      toast.success(`Order status updated to ${updated.status}`);
      invalidate();
      setEditingOrder(null);
      if (selectedOrder && selectedOrder.id === updated.id) {
        setSelectedOrder(updated);
      }
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Update failed'),
  });

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
      return new Date(dateStr).toLocaleDateString('en-IN', {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
      });
    } catch {
      return dateStr;
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-3 bg-teal-500/10 text-teal-600 dark:bg-teal-500/20 dark:text-teal-400 rounded-2xl">
            <ShoppingCart className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Orders
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              Marketplace customer orders, payment receipts, and fulfillment tracking.
            </p>
          </div>
        </div>
      </div>

      {/* Filter & Search Toolbar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-3 bg-white dark:bg-zinc-950 p-4 rounded-2xl border border-zinc-200/80 dark:border-zinc-800 shadow-2xs">
        <div className="relative w-full sm:w-80">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-zinc-400" />
          <Input
            placeholder="Search by order # (e.g. ALG-2026-000001)..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
            className="pl-9 h-9 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs"
          />
        </div>

        <div className="flex items-center gap-3 w-full sm:w-auto">
          <Select
            value={statusFilter}
            onValueChange={(val) => {
              if (val) setStatusFilter(val);
              setPage(1);
            }}
          >
            <SelectTrigger className="w-[160px] h-9 rounded-xl text-xs border-zinc-200 dark:border-zinc-800">
              <SelectValue placeholder="All Status" />
            </SelectTrigger>
            <SelectContent>
              {ORDER_STATUS_FILTERS.map((st) => (
                <SelectItem key={st} value={st}>
                  {st === 'ALL' ? 'All Orders' : st}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      {/* Table */}
      <div className="rounded-2xl border border-zinc-200/80 dark:border-zinc-800 bg-white dark:bg-zinc-950 overflow-hidden shadow-2xs">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-zinc-50/90 dark:bg-zinc-900/90 text-zinc-500 dark:text-zinc-400 text-xs font-bold uppercase tracking-wider border-b border-zinc-200/80 dark:border-zinc-800">
              <tr>
                <th className="p-4">
                  <button
                    onClick={() => handleSort('orderNumber')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Order Number</span>
                    {sortField === 'orderNumber' ? (
                      sortDirection === 'asc' ? <ArrowUp className="h-3.5 w-3.5 text-emerald-600" /> : <ArrowDown className="h-3.5 w-3.5 text-emerald-600" />
                    ) : (
                      <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4">Customer</th>
                <th className="p-4">
                  <button
                    onClick={() => handleSort('totalAmount')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Total Amount</span>
                    {sortField === 'totalAmount' ? (
                      sortDirection === 'asc' ? <ArrowUp className="h-3.5 w-3.5 text-emerald-600" /> : <ArrowDown className="h-3.5 w-3.5 text-emerald-600" />
                    ) : (
                      <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4">Payment</th>
                <th className="p-4">
                  <button
                    onClick={() => handleSort('status')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Order Status</span>
                    {sortField === 'status' ? (
                      sortDirection === 'asc' ? <ArrowUp className="h-3.5 w-3.5 text-emerald-600" /> : <ArrowDown className="h-3.5 w-3.5 text-emerald-600" />
                    ) : (
                      <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4">
                  <button
                    onClick={() => handleSort('createdAt')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Placed Date</span>
                    {sortField === 'createdAt' ? (
                      sortDirection === 'asc' ? <ArrowUp className="h-3.5 w-3.5 text-emerald-600" /> : <ArrowDown className="h-3.5 w-3.5 text-emerald-600" />
                    ) : (
                      <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100 dark:divide-zinc-900">
              {isLoading ? (
                Array.from({ length: 6 }).map((_, idx) => (
                  <tr key={idx} className="animate-pulse">
                    <td className="p-4" colSpan={7}>
                      <div className="h-7 bg-zinc-100 dark:bg-zinc-800 rounded-xl" />
                    </td>
                  </tr>
                ))
              ) : sortedOrders.length === 0 ? (
                <tr>
                  <td colSpan={7} className="p-12 text-center">
                    <div className="flex flex-col items-center justify-center space-y-2">
                      <div className="p-3 bg-zinc-100 dark:bg-zinc-850 rounded-full text-zinc-400">
                        <Inbox className="h-8 w-8" />
                      </div>
                      <p className="text-sm font-semibold text-zinc-800 dark:text-zinc-200">
                        No Orders Found
                      </p>
                      <p className="text-xs text-zinc-400 max-w-sm">
                        No marketplace orders match your search or filter selection.
                      </p>
                    </div>
                  </td>
                </tr>
              ) : (
                sortedOrders.map((order) => (
                  <tr
                    key={order.id}
                    className="hover:bg-zinc-50/80 dark:hover:bg-zinc-900/40 transition-colors"
                  >
                    <td className="p-4">
                      <div className="flex items-center gap-2">
                        <span className="font-mono font-bold text-zinc-900 dark:text-zinc-100 text-xs">
                          {order.orderNumber}
                        </span>
                      </div>
                    </td>
                    <td className="p-4 text-xs">
                      <p className="font-semibold text-zinc-800 dark:text-zinc-200">
                        {order.customer?.fullName || order.shippingAddressSnapshot?.fullName || 'Customer'}
                      </p>
                      <p className="text-zinc-400 text-[11px]">
                        {order.customer?.email || order.shippingAddressSnapshot?.city || ''}
                      </p>
                    </td>
                    <td className="p-4 font-bold text-zinc-900 dark:text-zinc-100 text-xs">
                      {formatPrice(order.totalAmount)}
                    </td>
                    <td className="p-4 text-xs space-y-1">
                      <div className="flex items-center gap-1.5 font-medium text-zinc-700 dark:text-zinc-300">
                        <CreditCard className="h-3.5 w-3.5 text-zinc-400" />
                        <span>{order.paymentMethod}</span>
                      </div>
                      <StatusBadge status={order.paymentStatus} className="text-[10px] px-2 py-0" />
                    </td>
                    <td className="p-4">
                      <StatusBadge status={order.status} />
                    </td>
                    <td className="p-4 text-xs text-zinc-500">
                      {formatDate(order.createdAt)}
                    </td>
                    <td className="p-4 text-right">
                      <div className="flex items-center justify-end gap-1.5">
                        <Button
                          variant="outline"
                          size="sm"
                          title="View Order Details"
                          onClick={() => setSelectedOrder(order)}
                          className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                        >
                          <Eye className="h-3.5 w-3.5 text-zinc-500" />
                          View
                        </Button>

                        <Button
                          variant="outline"
                          size="sm"
                          title="Update Status"
                          onClick={() => {
                            setEditingOrder(order);
                            setEditStatus(order.status);
                          }}
                          className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                        >
                          <Edit className="h-3.5 w-3.5 text-blue-500" />
                          Status
                        </Button>

                        {order.status !== 'CANCELLED' && order.status !== 'DELIVERED' && (
                          <Button
                            variant="outline"
                            size="sm"
                            title="Cancel Order"
                            onClick={() => setCancelTarget(order)}
                            className="h-8 px-2.5 rounded-xl border-rose-200 dark:border-rose-900/50 text-xs font-semibold text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/30 gap-1.5"
                          >
                            <Trash2 className="h-3.5 w-3.5" />
                            Cancel
                          </Button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Pagination */}
      {data && (
        <MarketplacePagination
          page={data.page}
          limit={data.limit}
          total={data.total}
          totalPages={data.totalPages}
          onPageChange={(p) => setPage(p)}
        />
      )}

      {/* View Order Detail Modal */}
      <Dialog open={!!selectedOrder} onOpenChange={(open) => !open && setSelectedOrder(null)}>
        <DialogContent className="sm:max-w-xl rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold flex items-center gap-2">
              <ShoppingCart className="h-5 w-5 text-teal-600" />
              Order #{selectedOrder?.orderNumber}
            </DialogTitle>
          </DialogHeader>

          {selectedOrder && (
            <div className="space-y-4 pt-2 text-xs max-h-[70vh] overflow-y-auto pr-1">
              {/* Order Status & Financial Summary */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 p-3.5 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800">
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Status</span>
                  <div className="mt-0.5">
                    <StatusBadge status={selectedOrder.status} />
                  </div>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Total Amount</span>
                  <span className="font-bold text-zinc-900 dark:text-zinc-100 text-sm">
                    {formatPrice(selectedOrder.totalAmount)}
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Payment Method</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {selectedOrder.paymentMethod} ({selectedOrder.paymentStatus})
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Order Date</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {formatDate(selectedOrder.createdAt)}
                  </span>
                </div>
              </div>

              {/* Shipping Address Snapshot */}
              {selectedOrder.shippingAddressSnapshot && (
                <div className="p-3.5 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 space-y-1">
                  <div className="flex items-center gap-1.5 text-zinc-400 font-bold uppercase text-[10px]">
                    <MapPin className="h-3 w-3" />
                    <span>Shipping Address</span>
                  </div>
                  <p className="font-semibold text-zinc-900 dark:text-zinc-100">
                    {selectedOrder.shippingAddressSnapshot.fullName} ({selectedOrder.shippingAddressSnapshot.mobileNumber})
                  </p>
                  <p className="text-zinc-600 dark:text-zinc-400">
                    {selectedOrder.shippingAddressSnapshot.addressLine1}
                    {selectedOrder.shippingAddressSnapshot.addressLine2 ? `, ${selectedOrder.shippingAddressSnapshot.addressLine2}` : ''}
                    {selectedOrder.shippingAddressSnapshot.landmark ? `, Landmark: ${selectedOrder.shippingAddressSnapshot.landmark}` : ''}
                  </p>
                  <p className="text-zinc-600 dark:text-zinc-400">
                    {selectedOrder.shippingAddressSnapshot.city}, {selectedOrder.shippingAddressSnapshot.state} - {selectedOrder.shippingAddressSnapshot.postalCode}
                  </p>
                </div>
              )}

              {/* Order Items */}
              {selectedOrder.orderItems && selectedOrder.orderItems.length > 0 && (
                <div className="space-y-2">
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Order Items</span>
                  <div className="space-y-2">
                    {selectedOrder.orderItems.map((item) => (
                      <div
                        key={item.id}
                        className="flex items-center justify-between p-3 rounded-xl border border-zinc-100 dark:border-zinc-800 bg-white dark:bg-zinc-950"
                      >
                        <div className="flex items-center gap-3">
                          <div className="p-2 bg-zinc-100 dark:bg-zinc-900 rounded-lg text-zinc-500">
                            <Package className="h-4 w-4" />
                          </div>
                          <div>
                            <p className="font-semibold text-zinc-900 dark:text-zinc-100">{item.productNameSnapshot}</p>
                            <p className="text-[11px] text-zinc-400">
                              Qty: {item.quantity} × {formatPrice(item.unitPrice)}
                            </p>
                          </div>
                        </div>
                        <div className="text-right">
                          <p className="font-bold text-zinc-900 dark:text-zinc-100">{formatPrice(item.totalPrice)}</p>
                          <StatusBadge status={item.status} className="text-[9px] px-1.5 py-0" />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              <DialogFooter className="pt-2">
                <Button
                  variant="outline"
                  onClick={() => setSelectedOrder(null)}
                  className="rounded-xl h-9 text-xs font-semibold"
                >
                  Close
                </Button>
                <Button
                  onClick={() => {
                    const ord = selectedOrder;
                    setSelectedOrder(null);
                    setEditingOrder(ord);
                    setEditStatus(ord.status);
                  }}
                  className="rounded-xl h-9 text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs"
                >
                  <Edit className="h-3.5 w-3.5 mr-1.5" />
                  Update Status
                </Button>
              </DialogFooter>
            </div>
          )}
        </DialogContent>
      </Dialog>

      {/* Edit Order Status Modal */}
      <Dialog open={!!editingOrder} onOpenChange={(open) => !open && setEditingOrder(null)}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold">Update Order Status</DialogTitle>
          </DialogHeader>

          {editingOrder && (
            <div className="space-y-4 pt-2">
              <div className="p-3 bg-zinc-50 dark:bg-zinc-900 rounded-xl border border-zinc-100 dark:border-zinc-800 text-xs">
                <p className="font-bold text-zinc-900 dark:text-zinc-100">Order #{editingOrder.orderNumber}</p>
                <p className="text-zinc-400">Total Amount: {formatPrice(editingOrder.totalAmount)}</p>
              </div>

              <div className="space-y-1.5">
                <Label className="text-xs font-bold">Fulfillment Status</Label>
                <Select value={editStatus} onValueChange={(val) => { if (val) setEditStatus(val); }}>
                  <SelectTrigger className="h-9 rounded-xl text-xs">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="PENDING">PENDING (Awaiting Review)</SelectItem>
                    <SelectItem value="CONFIRMED">CONFIRMED (Accepted)</SelectItem>
                    <SelectItem value="PROCESSING">PROCESSING (Packaging)</SelectItem>
                    <SelectItem value="SHIPPED">SHIPPED (In Transit)</SelectItem>
                    <SelectItem value="DELIVERED">DELIVERED (Completed)</SelectItem>
                    <SelectItem value="CANCELLED">CANCELLED (Revoked)</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <DialogFooter className="pt-2">
                <Button
                  variant="outline"
                  onClick={() => setEditingOrder(null)}
                  className="rounded-xl h-9 text-xs"
                >
                  Cancel
                </Button>
                <Button
                  onClick={() => {
                    updateStatusMutation.mutate({
                      id: editingOrder.id,
                      status: editStatus,
                    });
                  }}
                  className="bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl h-9 text-xs font-semibold"
                >
                  Apply Status
                </Button>
              </DialogFooter>
            </div>
          )}
        </DialogContent>
      </Dialog>

      {/* Cancel Order Confirmation Dialog */}
      <ConfirmDialog
        open={!!cancelTarget}
        onClose={() => setCancelTarget(null)}
        onConfirm={() => {
          if (cancelTarget) {
            updateStatusMutation.mutate({ id: cancelTarget.id, status: 'CANCELLED' });
            setCancelTarget(null);
          }
        }}
        title="Cancel Order"
        description={
          cancelTarget ? (
            <span>
              Are you sure you want to cancel order <strong>#{cancelTarget.orderNumber}</strong>? The order status will be marked as CANCELLED.
            </span>
          ) : undefined
        }
        confirmText="Cancel Order"
        variant="destructive"
        isLoading={updateStatusMutation.isPending}
      />
    </div>
  );
}
