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
  User,
  Store,
  ArrowUpDown,
  ArrowUp,
  ArrowDown,
  Inbox,
  Clock,
  Download,
  FilterX,
  FileSpreadsheet,
  FileText,
  ChevronDown,
  X,
  Layers,
} from 'lucide-react';

import {
  getAdminOrders,
  getAllAdminOrders,
  updateAdminOrderStatus,
  Order,
} from '@/features/orders/api';
import { getVendors } from '@/features/vendors/api';
import { getCustomers } from '@/features/customers/api';

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
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

import { OrderSummaryCards } from '@/features/orders/components/OrderSummaryCards';
import { OrderDetailModal } from '@/features/orders/components/OrderDetailModal';

const ORDER_STATUS_FILTERS = [
  'ALL',
  'PENDING',
  'CONFIRMED',
  'PROCESSING',
  'PACKED',
  'SHIPPED',
  'DELIVERED',
  'PARTIALLY_DELIVERED',
  'CANCELLED',
];

const PAYMENT_METHOD_FILTERS = [
  { value: 'ALL', label: 'All Payment Methods' },
  { value: 'COD', label: 'Cash on Delivery (COD)' },
  { value: 'ONLINE', label: 'Online / Card Payment' },
];

const DATE_PRESETS = [
  { value: 'ALL', label: 'All Time' },
  { value: 'TODAY', label: 'Today' },
  { value: 'LAST_7_DAYS', label: 'Last 7 Days' },
  { value: 'LAST_30_DAYS', label: 'Last 30 Days' },
  { value: 'CUSTOM', label: 'Custom Date Range' },
];

export default function OrdersPage() {
  const queryClient = useQueryClient();

  // Filters & Search
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [vendorFilter, setVendorFilter] = useState('ALL');
  const [customerFilter, setCustomerFilter] = useState('ALL');
  const [paymentMethodFilter, setPaymentMethodFilter] = useState('ALL');
  const [datePreset, setDatePreset] = useState('ALL');
  const [customStartDate, setCustomStartDate] = useState('');
  const [customEndDate, setCustomEndDate] = useState('');

  // Pagination & Sorting
  const [page, setPage] = useState(1);
  const limit = 10;
  const [sortField, setSortField] = useState<'orderNumber' | 'createdAt' | 'totalAmount' | 'status'>('createdAt');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Modals & Dialogs
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [editingOrder, setEditingOrder] = useState<Order | null>(null);
  const [editStatus, setEditStatus] = useState<string>('CONFIRMED');
  const [cancelTarget, setCancelTarget] = useState<Order | null>(null);
  const [isExporting, setIsExporting] = useState(false);

  // Compute ISO dates based on preset
  const { startDate, endDate } = useMemo(() => {
    if (datePreset === 'ALL') return { startDate: undefined, endDate: undefined };
    if (datePreset === 'CUSTOM') {
      return {
        startDate: customStartDate ? new Date(customStartDate).toISOString() : undefined,
        endDate: customEndDate ? new Date(customEndDate).toISOString() : undefined,
      };
    }

    const now = new Date();
    if (datePreset === 'TODAY') {
      const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      return { startDate: todayStart.toISOString(), endDate: now.toISOString() };
    }
    if (datePreset === 'LAST_7_DAYS') {
      const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      return { startDate: sevenDaysAgo.toISOString(), endDate: now.toISOString() };
    }
    if (datePreset === 'LAST_30_DAYS') {
      const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      return { startDate: thirtyDaysAgo.toISOString(), endDate: now.toISOString() };
    }
    return { startDate: undefined, endDate: undefined };
  }, [datePreset, customStartDate, customEndDate]);

  // Fetch Vendors for Filter and Name Mapping
  const { data: vendorsData } = useQuery({
    queryKey: ['adminVendorsList'],
    queryFn: () => getVendors({ limit: 100 }),
    staleTime: 60000,
  });

  const vendors = vendorsData?.items || [];
  const vendorNameMap = useMemo(() => {
    const map: Record<string, string> = {};
    for (const v of vendors) {
      map[v.id] = v.businessName || v.fullName;
    }
    return map;
  }, [vendors]);

  const vendorMap = useMemo(() => {
    const map: Record<string, { name: string; email?: string; phone?: string }> = {};
    for (const v of vendors) {
      map[v.id] = {
        name: v.businessName || v.fullName,
        email: v.email || undefined,
        phone: v.phoneNumber || undefined,
      };
    }
    return map;
  }, [vendors]);

  // Fetch Customers for Filter
  const { data: customersData } = useQuery({
    queryKey: ['adminCustomersList'],
    queryFn: () => getCustomers({ limit: 100 }),
    staleTime: 60000,
  });

  const customers = customersData?.items || [];

  // Fetch Orders
  const { data, isLoading } = useQuery({
    queryKey: [
      'adminOrders',
      statusFilter,
      vendorFilter,
      customerFilter,
      startDate,
      endDate,
      page,
      limit,
    ],
    queryFn: () =>
      getAdminOrders({
        status: statusFilter === 'ALL' ? undefined : statusFilter,
        vendorId: vendorFilter === 'ALL' ? undefined : vendorFilter,
        customerId: customerFilter === 'ALL' ? undefined : customerFilter,
        startDate,
        endDate,
        page,
        limit,
      }),
  });

  // Fetch All Orders for Dashboard Summary Metrics (stale for 30s)
  const { data: allOrdersData } = useQuery({
    queryKey: ['adminOrdersSummaryMetrics'],
    queryFn: () => getAllAdminOrders(),
    staleTime: 30000,
  });

  const allOrdersList = allOrdersData || [];

  // Calculate summary metrics (all 10 requested metrics)
  const summaryMetrics = useMemo(() => {
    let pending = 0;
    let confirmed = 0;
    let processing = 0;
    let packed = 0;
    let shipped = 0;
    let delivered = 0;
    let cancelled = 0;
    let today = 0;
    let revenue = 0;

    const todayDateStr = new Date().toDateString();

    for (const ord of allOrdersList) {
      const s = ord.status?.toUpperCase();
      if (s === 'PENDING') pending++;
      else if (s === 'CONFIRMED') confirmed++;
      else if (s === 'PROCESSING') processing++;
      else if (s === 'PACKED') packed++;
      else if (s === 'SHIPPED' || s === 'OUT_FOR_DELIVERY') shipped++;
      else if (s === 'DELIVERED' || s === 'PARTIALLY_DELIVERED') delivered++;
      else if (s === 'CANCELLED') cancelled++;

      if (s !== 'CANCELLED') {
        revenue += ord.grandTotal || ord.totalAmount || 0;
      }

      if (ord.createdAt && new Date(ord.createdAt).toDateString() === todayDateStr) {
        today++;
      }
    }

    return {
      total: allOrdersList.length,
      pending,
      confirmed,
      processing,
      packed,
      shipped,
      delivered,
      cancelled,
      today,
      revenue,
    };
  }, [allOrdersList]);

  const statusTabs = useMemo(() => [
    { key: 'ALL', label: 'All Orders', count: summaryMetrics.total },
    { key: 'PENDING', label: 'Pending', count: summaryMetrics.pending },
    { key: 'CONFIRMED', label: 'Confirmed', count: summaryMetrics.confirmed },
    { key: 'PROCESSING', label: 'Processing', count: summaryMetrics.processing },
    { key: 'PACKED', label: 'Packed', count: summaryMetrics.packed },
    { key: 'SHIPPED', label: 'Shipped', count: summaryMetrics.shipped },
    { key: 'DELIVERED', label: 'Delivered', count: summaryMetrics.delivered },
    { key: 'CANCELLED', label: 'Cancelled', count: summaryMetrics.cancelled },
  ], [summaryMetrics]);

  const rawOrders: Order[] = data?.items ?? [];

  // Client-side search and payment method filter
  const filteredOrders = useMemo(() => {
    const q = search.toLowerCase().trim();

    return rawOrders.filter((order) => {
      // 1. Payment Method Filter
      if (paymentMethodFilter !== 'ALL') {
        if (order.paymentMethod?.toUpperCase() !== paymentMethodFilter) {
          return false;
        }
      }

      // 2. Search across Order Number, Customer Name, Vendor Name
      if (q) {
        const matchesNumber = order.orderNumber.toLowerCase().includes(q);
        const matchesCustomer =
          order.customer?.fullName.toLowerCase().includes(q) ||
          order.shippingAddressSnapshot?.fullName?.toLowerCase().includes(q);

        const matchesVendor = order.orderItems?.some((item) => {
          const vName = vendorNameMap[item.vendorId] || '';
          return (
            vName.toLowerCase().includes(q) ||
            item.vendorId.toLowerCase().includes(q) ||
            item.productNameSnapshot.toLowerCase().includes(q)
          );
        });

        if (!matchesNumber && !matchesCustomer && !matchesVendor) {
          return false;
        }
      }

      return true;
    });
  }, [rawOrders, search, paymentMethodFilter, vendorNameMap]);

  // Sorting
  const sortedOrders = useMemo(() => {
    return [...filteredOrders].sort((a, b) => {
      let aVal: any = a[sortField];
      let bVal: any = b[sortField];

      if (sortField === 'totalAmount') {
        aVal = a.grandTotal || a.totalAmount || 0;
        bVal = b.grandTotal || b.totalAmount || 0;
        return sortDirection === 'asc' ? aVal - bVal : bVal - aVal;
      }

      if (typeof aVal === 'string') {
        return sortDirection === 'asc'
          ? aVal.localeCompare(bVal || '')
          : (bVal || '').localeCompare(aVal);
      }
      return sortDirection === 'asc' ? (aVal > bVal ? 1 : -1) : aVal < bVal ? 1 : -1;
    });
  }, [filteredOrders, sortField, sortDirection]);

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
    queryClient.invalidateQueries({ queryKey: ['adminOrdersSummaryMetrics'] });
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

  const resetAllFilters = () => {
    setSearch('');
    setStatusFilter('ALL');
    setVendorFilter('ALL');
    setCustomerFilter('ALL');
    setPaymentMethodFilter('ALL');
    setDatePreset('ALL');
    setCustomStartDate('');
    setCustomEndDate('');
    setPage(1);
  };

  const hasActiveFilters =
    search.trim() !== '' ||
    statusFilter !== 'ALL' ||
    vendorFilter !== 'ALL' ||
    customerFilter !== 'ALL' ||
    paymentMethodFilter !== 'ALL' ||
    datePreset !== 'ALL';

  // Export handlers
  const handleExportCSV = async () => {
    try {
      setIsExporting(true);
      toast.info('Preparing orders export...');

      // Fetch all orders matching current filters
      const exportOrders = await getAllAdminOrders({
        status: statusFilter === 'ALL' ? undefined : statusFilter,
        vendorId: vendorFilter === 'ALL' ? undefined : vendorFilter,
        customerId: customerFilter === 'ALL' ? undefined : customerFilter,
        startDate,
        endDate,
      });

      if (exportOrders.length === 0) {
        toast.error('No orders available to export.');
        setIsExporting(false);
        return;
      }

      // Generate CSV content
      const headers = [
        'Order Number',
        'Placed Date',
        'Customer Name',
        'Customer Email',
        'Customer Phone',
        'Vendor Name(s)',
        'Product Count',
        'Total Quantity',
        'Subtotal',
        'Shipping',
        'Grand Total',
        'Payment Method',
        'Payment Status',
        'Order Status',
        'Delivery City',
        'Delivery State',
        'Delivery Pincode',
      ];

      const rows = exportOrders.map((ord) => {
        const vNames = Array.from(
          new Set(ord.orderItems?.map((i) => vendorNameMap[i.vendorId] || i.vendorId).filter(Boolean) || [])
        ).join('; ');

        const addr = ord.address || ord.shippingAddressSnapshot;
        const total = ord.grandTotal || ord.totalAmount || 0;
        const totalQty = ord.orderItems?.reduce((acc, i) => acc + (i.quantity || 1), 0) || 0;

        return [
          `"${ord.orderNumber}"`,
          `"${new Date(ord.createdAt).toISOString().split('T')[0]}"`,
          `"${ord.customer?.fullName || addr?.fullName || 'Customer'}"`,
          `"${ord.customer?.email || ''}"`,
          `"${ord.customer?.phoneNumber || addr?.mobileNumber || ''}"`,
          `"${vNames || 'N/A'}"`,
          `"${ord.orderItems?.length || 0}"`,
          `"${totalQty}"`,
          `"${ord.subtotal || 0}"`,
          `"${ord.shippingCharge || 0}"`,
          `"${total}"`,
          `"${ord.paymentMethod}"`,
          `"${ord.paymentStatus}"`,
          `"${ord.status}"`,
          `"${addr?.city || ''}"`,
          `"${addr?.state || ''}"`,
          `"${addr?.postalCode || ''}"`,
        ].join(',');
      });

      const csvContent = [headers.join(','), ...rows].join('\n');
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.setAttribute('href', url);
      link.setAttribute('download', `alanga_orders_export_${new Date().toISOString().split('T')[0]}.csv`);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      toast.success(`Exported ${exportOrders.length} orders successfully!`);
    } catch (e: any) {
      toast.error('Failed to export orders. Please try again.');
    } finally {
      setIsExporting(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header with Title and Export Actions */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-3 bg-teal-500/10 text-teal-600 dark:bg-teal-500/20 dark:text-teal-400 rounded-2xl">
            <ShoppingCart className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Orders Management
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              Monitor, filter, and oversee all marketplace orders, fulfillments, and revenue.
            </p>
          </div>
        </div>

        {/* Export Buttons */}
        <div className="flex items-center gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger
              disabled={isExporting}
              className="inline-flex items-center justify-center h-9 px-3.5 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-950 text-xs font-semibold text-zinc-800 dark:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-850 gap-2 shadow-2xs transition-colors cursor-pointer disabled:opacity-50"
            >
              <Download className="h-3.5 w-3.5 text-zinc-500" />
              <span>{isExporting ? 'Exporting...' : 'Export Orders'}</span>
              <ChevronDown className="h-3 w-3 text-zinc-400" />
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-48 rounded-xl text-xs">
              <DropdownMenuItem onClick={handleExportCSV} className="cursor-pointer gap-2 py-2">
                <FileText className="h-4 w-4 text-emerald-600" />
                <span>Export as CSV</span>
              </DropdownMenuItem>
              <DropdownMenuItem onClick={handleExportCSV} className="cursor-pointer gap-2 py-2">
                <FileSpreadsheet className="h-4 w-4 text-blue-600" />
                <span>Export as Excel (XLSX)</span>
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* 1. Order Dashboard: 10 Summary Cards */}
      <OrderSummaryCards
        totalOrders={summaryMetrics.total}
        pendingOrders={summaryMetrics.pending}
        confirmedOrders={summaryMetrics.confirmed}
        processingOrders={summaryMetrics.processing}
        packedOrders={summaryMetrics.packed}
        shippedOrders={summaryMetrics.shipped}
        deliveredOrders={summaryMetrics.delivered}
        cancelledOrders={summaryMetrics.cancelled}
        todayOrders={summaryMetrics.today}
        totalRevenue={summaryMetrics.revenue}
        isLoading={isLoading && allOrdersList.length === 0}
        selectedStatus={statusFilter}
        selectedDatePreset={datePreset}
        onStatusClick={(st) => {
          setStatusFilter(st);
          setPage(1);
        }}
        onTodayClick={() => {
          setDatePreset('TODAY');
          setPage(1);
        }}
      />

      {/* 2. Interactive Status Tabs */}
      <div className="bg-white dark:bg-zinc-950 px-4 pt-3 pb-0 rounded-2xl border border-zinc-200/80 dark:border-zinc-800 shadow-2xs">
        <div className="flex items-center gap-1 overflow-x-auto no-scrollbar pb-px">
          {statusTabs.map((tab) => {
            const isActive = statusFilter === tab.key;
            return (
              <button
                key={tab.key}
                onClick={() => {
                  setStatusFilter(tab.key);
                  setPage(1);
                }}
                className={`flex items-center gap-2 px-3.5 py-2 text-xs font-semibold whitespace-nowrap transition-all border-b-2 -mb-px cursor-pointer ${
                  isActive
                    ? 'border-emerald-600 text-emerald-600 dark:text-emerald-400 font-bold'
                    : 'border-transparent text-zinc-500 hover:text-zinc-800 dark:hover:text-zinc-200'
                }`}
              >
                <span>{tab.label}</span>
                <span
                  className={`px-1.5 py-0.5 rounded-full text-[10px] font-bold ${
                    isActive
                      ? 'bg-emerald-100 dark:bg-emerald-950/60 text-emerald-700 dark:text-emerald-300'
                      : 'bg-zinc-100 dark:bg-zinc-800 text-zinc-500'
                  }`}
                >
                  {tab.count}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* 3. Comprehensive Filter & Search Toolbar */}
      <div className="bg-white dark:bg-zinc-950 p-4 rounded-2xl border border-zinc-200/80 dark:border-zinc-800 shadow-2xs space-y-3">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-6 gap-3">
          {/* Search Box */}
          <div className="relative sm:col-span-2">
            <Search className="absolute left-3 top-2.5 h-4 w-4 text-zinc-400" />
            <Input
              placeholder="Search order #, customer, or vendor..."
              value={search}
              onChange={(e) => {
                setSearch(e.target.value);
                setPage(1);
              }}
              className="pl-9 h-9 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs"
            />
          </div>

          {/* Status Filter */}
          <div>
            <Select
              value={statusFilter}
              onValueChange={(val) => {
                if (val) setStatusFilter(val);
                setPage(1);
              }}
            >
              <SelectTrigger className="w-full h-9 rounded-xl text-xs border-zinc-200 dark:border-zinc-800">
                <SelectValue placeholder="All Status" />
              </SelectTrigger>
              <SelectContent>
                {ORDER_STATUS_FILTERS.map((st) => (
                  <SelectItem key={st} value={st}>
                    {st === 'ALL' ? 'All Statuses' : st}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Vendor Filter */}
          <div>
            <Select
              value={vendorFilter}
              onValueChange={(val) => {
                if (val) setVendorFilter(val);
                setPage(1);
              }}
            >
              <SelectTrigger className="w-full h-9 rounded-xl text-xs border-zinc-200 dark:border-zinc-800">
                <SelectValue placeholder="All Vendors">
                  {vendorFilter === 'ALL'
                    ? 'All Vendors'
                    : vendors.find((v) => v.id === vendorFilter)?.businessName ||
                      vendors.find((v) => v.id === vendorFilter)?.fullName ||
                      'Selected Vendor'}
                </SelectValue>
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="ALL">All Vendors</SelectItem>
                {vendors.map((v) => (
                  <SelectItem key={v.id} value={v.id}>
                    {v.businessName || v.fullName}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Customer Filter */}
          <div>
            <Select
              value={customerFilter}
              onValueChange={(val) => {
                if (val) setCustomerFilter(val);
                setPage(1);
              }}
            >
              <SelectTrigger className="w-full h-9 rounded-xl text-xs border-zinc-200 dark:border-zinc-800">
                <SelectValue placeholder="All Customers">
                  {customerFilter === 'ALL'
                    ? 'All Customers'
                    : customers.find((c) => c.id === customerFilter)?.fullName || 'Selected Customer'}
                </SelectValue>
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="ALL">All Customers</SelectItem>
                {customers.map((c) => (
                  <SelectItem key={c.id} value={c.id}>
                    {c.fullName} {c.email ? `(${c.email})` : ''}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Payment Method Filter */}
          <div>
            <Select
              value={paymentMethodFilter}
              onValueChange={(val) => {
                if (val) setPaymentMethodFilter(val);
                setPage(1);
              }}
            >
              <SelectTrigger className="w-full h-9 rounded-xl text-xs border-zinc-200 dark:border-zinc-800">
                <SelectValue placeholder="Payment Method" />
              </SelectTrigger>
              <SelectContent>
                {PAYMENT_METHOD_FILTERS.map((pm) => (
                  <SelectItem key={pm.value} value={pm.value}>
                    {pm.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>

        {/* Second Filter Row: Date Range & Clear */}
        <div className="flex flex-col sm:flex-row items-center justify-between gap-3 pt-2 border-t border-zinc-100 dark:border-zinc-800 text-xs">
          <div className="flex flex-wrap items-center gap-2.5 w-full sm:w-auto">
            <span className="text-zinc-400 font-semibold flex items-center gap-1.5 text-[11px]">
              <Calendar className="h-3.5 w-3.5" />
              <span>Date Range:</span>
            </span>

            <div className="w-40">
              <Select
                value={datePreset}
                onValueChange={(val) => {
                  if (val) setDatePreset(val);
                  setPage(1);
                }}
              >
                <SelectTrigger className="h-8 rounded-xl text-xs border-zinc-200 dark:border-zinc-800">
                  <SelectValue placeholder="Date Range" />
                </SelectTrigger>
                <SelectContent>
                  {DATE_PRESETS.map((dp) => (
                    <SelectItem key={dp.value} value={dp.value}>
                      {dp.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {datePreset === 'CUSTOM' && (
              <div className="flex items-center gap-2">
                <Input
                  type="date"
                  value={customStartDate}
                  onChange={(e) => {
                    setCustomStartDate(e.target.value);
                    setPage(1);
                  }}
                  className="h-8 text-xs w-36 rounded-xl border-zinc-200 dark:border-zinc-800"
                />
                <span className="text-zinc-400">to</span>
                <Input
                  type="date"
                  value={customEndDate}
                  onChange={(e) => {
                    setCustomEndDate(e.target.value);
                    setPage(1);
                  }}
                  className="h-8 text-xs w-36 rounded-xl border-zinc-200 dark:border-zinc-800"
                />
              </div>
            )}
          </div>

          {hasActiveFilters && (
            <Button
              variant="ghost"
              size="sm"
              onClick={resetAllFilters}
              className="h-8 px-2.5 text-xs text-rose-600 hover:text-rose-700 hover:bg-rose-50 dark:hover:bg-rose-950/30 rounded-xl gap-1.5 self-end cursor-pointer"
            >
              <FilterX className="h-3.5 w-3.5" />
              <span>Reset All Filters</span>
            </Button>
          )}
        </div>

        {/* Active Filter Chips with 1-Click Removal */}
        {hasActiveFilters && (
          <div className="flex flex-wrap items-center gap-1.5 pt-2 border-t border-zinc-100 dark:border-zinc-800/60 text-xs">
            <span className="text-zinc-400 font-semibold text-[11px] mr-1">Active:</span>
            {search.trim() && (
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-lg bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 text-[11px] font-medium border border-zinc-200 dark:border-zinc-700">
                Search: "{search}"
                <button onClick={() => setSearch('')} className="hover:text-rose-500 cursor-pointer ml-0.5"><X className="h-3 w-3" /></button>
              </span>
            )}
            {statusFilter !== 'ALL' && (
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-lg bg-teal-50 dark:bg-teal-950/40 text-teal-700 dark:text-teal-300 border border-teal-200 dark:border-teal-800 text-[11px] font-medium">
                Status: {statusFilter}
                <button onClick={() => setStatusFilter('ALL')} className="hover:text-rose-500 cursor-pointer ml-0.5"><X className="h-3 w-3" /></button>
              </span>
            )}
            {vendorFilter !== 'ALL' && (
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-lg bg-blue-50 dark:bg-blue-950/40 text-blue-700 dark:text-blue-300 border border-blue-200 dark:border-blue-800 text-[11px] font-medium">
                Vendor: {vendorNameMap[vendorFilter] || 'Selected Vendor'}
                <button onClick={() => setVendorFilter('ALL')} className="hover:text-rose-500 cursor-pointer ml-0.5"><X className="h-3 w-3" /></button>
              </span>
            )}
            {customerFilter !== 'ALL' && (
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-lg bg-purple-50 dark:bg-purple-950/40 text-purple-700 dark:text-purple-300 border border-purple-200 dark:border-purple-800 text-[11px] font-medium">
                Customer: {customers.find((c) => c.id === customerFilter)?.fullName || 'Selected Customer'}
                <button onClick={() => setCustomerFilter('ALL')} className="hover:text-rose-500 cursor-pointer ml-0.5"><X className="h-3 w-3" /></button>
              </span>
            )}
            {paymentMethodFilter !== 'ALL' && (
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-lg bg-amber-50 dark:bg-amber-950/40 text-amber-700 dark:text-amber-300 border border-amber-200 dark:border-amber-800 text-[11px] font-medium">
                Payment: {paymentMethodFilter}
                <button onClick={() => setPaymentMethodFilter('ALL')} className="hover:text-rose-500 cursor-pointer ml-0.5"><X className="h-3 w-3" /></button>
              </span>
            )}
            {datePreset !== 'ALL' && (
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-lg bg-orange-50 dark:bg-orange-950/40 text-orange-700 dark:text-orange-300 border border-orange-200 dark:border-orange-800 text-[11px] font-medium">
                Date: {datePreset}
                <button onClick={() => setDatePreset('ALL')} className="hover:text-rose-500 cursor-pointer ml-0.5"><X className="h-3 w-3" /></button>
              </span>
            )}
          </div>
        )}
      </div>

      {/* 3. ShadCN Data Table */}
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
                <th className="p-4">Vendor</th>
                <th className="p-4 text-center">Products</th>
                <th className="p-4 text-center">Total Qty</th>
                <th className="p-4">
                  <button
                    onClick={() => handleSort('totalAmount')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Grand Total</span>
                    {sortField === 'totalAmount' ? (
                      sortDirection === 'asc' ? <ArrowUp className="h-3.5 w-3.5 text-emerald-600" /> : <ArrowDown className="h-3.5 w-3.5 text-emerald-600" />
                    ) : (
                      <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4">Payment Method</th>
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
                    <span>Order Date</span>
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
                    <td className="p-4" colSpan={10}>
                      <div className="h-7 bg-zinc-100 dark:bg-zinc-800 rounded-xl" />
                    </td>
                  </tr>
                ))
              ) : sortedOrders.length === 0 ? (
                <tr>
                  <td colSpan={10} className="p-12 text-center">
                    <div className="flex flex-col items-center justify-center space-y-2">
                      <div className="p-3 bg-zinc-100 dark:bg-zinc-850 rounded-full text-zinc-400">
                        <Inbox className="h-8 w-8" />
                      </div>
                      <p className="text-sm font-semibold text-zinc-800 dark:text-zinc-200">
                        No Orders Found
                      </p>
                      <p className="text-xs text-zinc-400 max-w-sm">
                        No marketplace orders match your search or filter criteria.
                      </p>
                      {hasActiveFilters && (
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={resetAllFilters}
                          className="mt-2 text-xs rounded-xl"
                        >
                          Clear Filters
                        </Button>
                      )}
                    </div>
                  </td>
                </tr>
              ) : (
                sortedOrders.map((order) => {
                  const addr = order.address || order.shippingAddressSnapshot;
                  const grandTotal = order.grandTotal || order.totalAmount || 0;
                  const productCount = order.orderItems?.length || 0;
                  const totalQuantity = order.orderItems?.reduce((acc, i) => acc + (i.quantity || 1), 0) || 0;

                  // Vendor name mapping
                  const itemVendorIds = Array.from(
                    new Set(order.orderItems?.map((i) => i.vendorId).filter(Boolean) || [])
                  );
                  const vendorNames =
                    itemVendorIds.map((id) => vendorNameMap[id] || `Vendor #${id.slice(0, 6)}`).join(', ') ||
                    'Marketplace Vendor';

                  return (
                    <tr
                      key={order.id}
                      className="hover:bg-zinc-50/80 dark:hover:bg-zinc-900/40 transition-colors"
                    >
                      {/* Order Number */}
                      <td className="p-4">
                        <span className="font-mono font-bold text-zinc-900 dark:text-zinc-100 text-xs block">
                          {order.orderNumber}
                        </span>
                        <span className="text-[11px] text-zinc-400 font-normal">
                          {formatDate(order.createdAt)}
                        </span>
                      </td>

                      {/* Customer Name */}
                      <td className="p-4 text-xs">
                        <div className="flex items-center gap-2.5">
                          <div className="h-8 w-8 rounded-full bg-emerald-50 dark:bg-emerald-950/50 border border-emerald-200 dark:border-emerald-800 text-emerald-700 dark:text-emerald-300 flex items-center justify-center font-bold text-xs shrink-0">
                            {(order.customer?.fullName || addr?.fullName || 'C')[0].toUpperCase()}
                          </div>
                          <div>
                            <p className="font-semibold text-zinc-800 dark:text-zinc-200">
                              {order.customer?.fullName || addr?.fullName || 'Customer'}
                            </p>
                            <p className="text-zinc-400 text-[11px] truncate max-w-[130px]">
                              {order.customer?.email || addr?.city || ''}
                            </p>
                          </div>
                        </div>
                      </td>

                      {/* Vendor Name */}
                      <td className="p-4 text-xs">
                        {itemVendorIds.length > 1 ? (
                          <div className="space-y-1">
                            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-purple-50 dark:bg-purple-950/40 text-purple-700 dark:text-purple-300 font-bold text-[10px] border border-purple-200 dark:border-purple-800">
                              <Store className="h-3 w-3" />
                              <span>{itemVendorIds.length} Vendors</span>
                            </span>
                            <p className="text-zinc-500 dark:text-zinc-400 text-[11px] truncate max-w-[140px]" title={vendorNames}>
                              {vendorNames}
                            </p>
                          </div>
                        ) : (
                          <div className="flex items-center gap-1.5">
                            <Store className="h-3.5 w-3.5 text-zinc-400 shrink-0" />
                            <span className="font-medium text-zinc-700 dark:text-zinc-300 truncate max-w-[130px]">
                              {vendorNames}
                            </span>
                          </div>
                        )}
                      </td>

                      {/* Product Count & Thumbnails */}
                      <td className="p-4 text-xs">
                        <div className="flex items-center gap-2 justify-center">
                          <div className="flex -space-x-2 overflow-hidden shrink-0">
                            {order.orderItems?.slice(0, 3).map((item, iIdx) => (
                              <div
                                key={iIdx}
                                className="inline-block h-7 w-7 rounded-lg ring-2 ring-white dark:ring-zinc-950 bg-zinc-100 dark:bg-zinc-800 overflow-hidden border border-zinc-200 dark:border-zinc-700"
                              >
                                {item.product?.image ? (
                                  <img src={item.product.image} alt="" className="h-full w-full object-cover" />
                                ) : (
                                  <div className="h-full w-full flex items-center justify-center text-[9px] font-bold text-zinc-400">
                                    {item.productNameSnapshot?.[0] || 'P'}
                                  </div>
                                )}
                              </div>
                            ))}
                          </div>
                          <span className="font-medium text-zinc-700 dark:text-zinc-300 px-1.5 py-0.5 bg-zinc-100 dark:bg-zinc-800 rounded-md">
                            {productCount}
                          </span>
                        </div>
                      </td>

                      {/* Total Quantity */}
                      <td className="p-4 text-center text-xs">
                        <span className="font-semibold text-zinc-800 dark:text-zinc-200 px-2 py-0.5 bg-emerald-50 dark:bg-emerald-950/40 text-emerald-700 dark:text-emerald-300 rounded-md">
                          {totalQuantity}
                        </span>
                      </td>

                      {/* Grand Total */}
                      <td className="p-4 font-bold text-zinc-900 dark:text-zinc-100 text-xs font-mono">
                        {formatPrice(grandTotal)}
                      </td>

                      {/* Payment Method */}
                      <td className="p-4 text-xs space-y-1">
                        <div className="flex items-center gap-1.5 font-medium text-zinc-700 dark:text-zinc-300">
                          <CreditCard className="h-3.5 w-3.5 text-zinc-400" />
                          <span>{order.paymentMethod}</span>
                        </div>
                        <StatusBadge status={order.paymentStatus} className="text-[10px] px-2 py-0" />
                      </td>

                      {/* Order Status */}
                      <td className="p-4">
                        <StatusBadge status={order.status} />
                      </td>

                      {/* Order Date */}
                      <td className="p-4 text-xs text-zinc-500">
                        {formatDate(order.createdAt)}
                      </td>

                      {/* Actions */}
                      <td className="p-4 text-right">
                        <div className="flex items-center justify-end gap-1.5">
                          <Button
                            variant="outline"
                            size="sm"
                            title="View Order Details"
                            onClick={() => setSelectedOrder(order)}
                            className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5 cursor-pointer"
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
                            className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5 cursor-pointer"
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
                              className="h-8 px-2.5 rounded-xl border-rose-200 dark:border-rose-900/50 text-xs font-semibold text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/30 gap-1.5 cursor-pointer"
                            >
                              <Trash2 className="h-3.5 w-3.5" />
                              Cancel
                            </Button>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* 4. Pagination */}
      {data && (
        <MarketplacePagination
          page={data.page}
          limit={data.limit}
          total={data.total}
          totalPages={data.totalPages}
          onPageChange={(p) => setPage(p)}
        />
      )}

      {/* 5. Order Details Modal */}
      <OrderDetailModal
        order={selectedOrder}
        vendorNameMap={vendorNameMap}
        vendorMap={vendorMap}
        open={!!selectedOrder}
        onClose={() => setSelectedOrder(null)}
        onOpenStatusDialog={(ord) => {
          setEditingOrder(ord);
          setEditStatus(ord.status);
        }}
      />

      {/* 6. Edit Order Status Modal */}
      <Dialog open={!!editingOrder} onOpenChange={(open) => !open && setEditingOrder(null)}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold">Update Order Status</DialogTitle>
          </DialogHeader>

          {editingOrder && (
            <div className="space-y-4 pt-2">
              <div className="p-3.5 bg-zinc-50 dark:bg-zinc-900 rounded-xl border border-zinc-100 dark:border-zinc-800 text-xs space-y-1">
                <p className="font-bold text-zinc-900 dark:text-zinc-100">Order #{editingOrder.orderNumber}</p>
                <p className="text-zinc-500">
                  Current Status: <span className="font-semibold text-zinc-800 dark:text-zinc-200">{editingOrder.status}</span>
                </p>
                <p className="text-zinc-500">
                  Total Amount: <span className="font-semibold text-zinc-800 dark:text-zinc-200">{formatPrice(editingOrder.grandTotal || editingOrder.totalAmount)}</span>
                </p>
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
                    <SelectItem value="PACKED">PACKED (Ready for Dispatch)</SelectItem>
                    <SelectItem value="SHIPPED">SHIPPED (In Transit)</SelectItem>
                    <SelectItem value="OUT_FOR_DELIVERY">OUT FOR DELIVERY (Last Mile)</SelectItem>
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

      {/* 7. Cancel Order Confirmation Dialog */}
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
              Are you sure you want to cancel order <strong>#{cancelTarget.orderNumber}</strong>? The order status will be marked as CANCELLED across the marketplace.
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
