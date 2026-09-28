'use client';

import React, { useState, useMemo, useEffect, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
  Search,
  Users,
  Eye,
  Edit,
  Trash2,
  CheckCircle,
  XCircle,
  AlertCircle,
  Building,
  Mail,
  Phone,
  Calendar,
  ShieldCheck,
  ArrowUpDown,
  ArrowUp,
  ArrowDown,
  Inbox,
  Clock,
  Landmark,
  MapPin,
  FileText,
} from 'lucide-react';

import {
  getVendors,
  approveVendor,
  rejectVendor,
  suspendVendor,
  Vendor,
} from '@/features/vendors/api';
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

const STATUS_FILTERS = ['ALL', 'PENDING', 'ACTIVE', 'REJECTED', 'SUSPENDED'];

function VendorsPageContent() {
  const queryClient = useQueryClient();
  const searchParams = useSearchParams();
  const urlStatus = searchParams?.get('status')?.toUpperCase();

  // Filters & Pagination
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState(urlStatus || 'ALL');
  const [page, setPage] = useState(1);
  const limit = 10;

  useEffect(() => {
    if (urlStatus && STATUS_FILTERS.includes(urlStatus)) {
      setStatusFilter(urlStatus);
      setPage(1);
    }
  }, [urlStatus]);

  // Sorting
  const [sortField, setSortField] = useState<'fullName' | 'createdAt' | 'status'>('createdAt');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Modals
  const [selectedVendor, setSelectedVendor] = useState<Vendor | null>(null);
  const [editingVendor, setEditingVendor] = useState<Vendor | null>(null);
  const [editStatus, setEditStatus] = useState<string>('ACTIVE');

  // Confirmation dialogs
  const [suspendTarget, setSuspendTarget] = useState<Vendor | null>(null);
  const [approveTarget, setApproveTarget] = useState<Vendor | null>(null);
  const [rejectTarget, setRejectTarget] = useState<Vendor | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['vendors', search, statusFilter, page],
    queryFn: () =>
      getVendors({
        search: search.trim() || undefined,
        status: statusFilter === 'ALL' ? undefined : statusFilter,
        page,
        limit,
      }),
  });

  const vendors: Vendor[] = data?.items ?? [];

  // Sorting
  const sortedVendors = useMemo(() => {
    if (!vendors) return [];
    return [...vendors].sort((a, b) => {
      const aVal = a[sortField] || '';
      const bVal = b[sortField] || '';
      if (sortDirection === 'asc') {
        return aVal.localeCompare(bVal);
      }
      return bVal.localeCompare(aVal);
    });
  }, [vendors, sortField, sortDirection]);

  const handleSort = (field: 'fullName' | 'createdAt' | 'status') => {
    if (sortField === field) {
      setSortDirection((prev) => (prev === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortField(field);
      setSortDirection('asc');
    }
  };

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ['vendors'] });
    queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
  };

  const approveMutation = useMutation({
    mutationFn: approveVendor,
    onSuccess: () => {
      toast.success('Vendor and KYC approved successfully');
      invalidate();
      setSelectedVendor(null);
      setApproveTarget(null);
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Approval failed'),
  });

  const rejectMutation = useMutation({
    mutationFn: rejectVendor,
    onSuccess: () => {
      toast.success('Vendor rejected');
      invalidate();
      setSelectedVendor(null);
      setRejectTarget(null);
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Rejection failed'),
  });

  const suspendMutation = useMutation({
    mutationFn: suspendVendor,
    onSuccess: () => {
      toast.success('Vendor suspended');
      invalidate();
      setSelectedVendor(null);
      setSuspendTarget(null);
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Suspension failed'),
  });

  const formatDate = (d: string) => {
    try {
      return new Date(d).toLocaleDateString('en-IN', {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
      });
    } catch {
      return d;
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-3 bg-blue-500/10 text-blue-600 dark:bg-blue-500/20 dark:text-blue-400 rounded-2xl">
            <Users className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Vendors & KYC Approvals
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              Marketplace merchant accounts, KYC credentials review, bank payouts, and onboarding approval.
            </p>
          </div>
        </div>
      </div>

      {/* Quick Status Filter Tabs */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1">
        {STATUS_FILTERS.map((st) => {
          const isActive = statusFilter === st;
          return (
            <button
              key={st}
              onClick={() => {
                setStatusFilter(st);
                setPage(1);
              }}
              className={`flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer whitespace-nowrap ${
                isActive
                  ? st === 'PENDING'
                    ? 'bg-amber-500 text-white shadow-xs'
                    : 'bg-zinc-900 text-white dark:bg-white dark:text-zinc-900 shadow-xs'
                  : 'bg-white dark:bg-zinc-900 text-zinc-600 dark:text-zinc-400 border border-zinc-200/80 dark:border-zinc-800 hover:bg-zinc-50 dark:hover:bg-zinc-850'
              }`}
            >
              {st === 'PENDING' && <Clock className={`h-3.5 w-3.5 ${isActive ? 'text-white' : 'text-amber-500'}`} />}
              {st === 'ACTIVE' && <CheckCircle className={`h-3.5 w-3.5 ${isActive ? 'text-white' : 'text-emerald-500'}`} />}
              {st === 'SUSPENDED' && <AlertCircle className={`h-3.5 w-3.5 ${isActive ? 'text-white' : 'text-rose-500'}`} />}
              <span>
                {st === 'ALL'
                  ? 'All Vendors'
                  : st === 'PENDING'
                  ? 'Pending Approvals'
                  : st === 'ACTIVE'
                  ? 'Active Vendors'
                  : st === 'REJECTED'
                  ? 'Rejected'
                  : 'Suspended'}
              </span>
            </button>
          );
        })}
      </div>

      {/* Filter & Search Toolbar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-3 bg-white dark:bg-zinc-950 p-4 rounded-2xl border border-zinc-200/80 dark:border-zinc-800 shadow-2xs">
        <div className="relative w-full sm:w-80">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-zinc-400" />
          <Input
            placeholder="Search by vendor name, store, email or phone..."
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
            <SelectTrigger className="w-[170px] h-9 rounded-xl text-xs border-zinc-200 dark:border-zinc-800">
              <SelectValue placeholder="All Status" />
            </SelectTrigger>
            <SelectContent>
              {STATUS_FILTERS.map((st) => (
                <SelectItem key={st} value={st}>
                  {st === 'ALL' ? 'All Status' : st === 'PENDING' ? 'Pending Approval' : st}
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
                    onClick={() => handleSort('fullName')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Vendor & Store</span>
                    {sortField === 'fullName' ? (
                      sortDirection === 'asc' ? <ArrowUp className="h-3.5 w-3.5 text-emerald-600" /> : <ArrowDown className="h-3.5 w-3.5 text-emerald-600" />
                    ) : (
                      <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4">Contact Info</th>
                <th className="p-4">KYC Status</th>
                <th className="p-4">
                  <button
                    onClick={() => handleSort('status')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Account Status</span>
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
                    <span>Registered</span>
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
                    <td className="p-4" colSpan={6}>
                      <div className="h-7 bg-zinc-100 dark:bg-zinc-800 rounded-xl" />
                    </td>
                  </tr>
                ))
              ) : sortedVendors.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-12 text-center">
                    <div className="flex flex-col items-center justify-center space-y-2">
                      <div className="p-3 bg-zinc-100 dark:bg-zinc-850 rounded-full text-zinc-400">
                        <Inbox className="h-8 w-8" />
                      </div>
                      <p className="text-sm font-semibold text-zinc-800 dark:text-zinc-200">
                        No Vendors Found
                      </p>
                      <p className="text-xs text-zinc-400 max-w-sm">
                        No vendors match your search or status filter.
                      </p>
                    </div>
                  </td>
                </tr>
              ) : (
                sortedVendors.map((vendor) => {
                  const isPending = vendor.status === 'PENDING' || vendor.kycStatus === 'PENDING';
                  const storeName = vendor.vendorProfile?.storeName || vendor.businessName;

                  return (
                    <tr
                      key={vendor.id}
                      className={`hover:bg-zinc-50/80 dark:hover:bg-zinc-900/40 transition-colors ${
                        isPending ? 'bg-amber-50/30 dark:bg-amber-950/10' : ''
                      }`}
                    >
                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          <div className="h-10 w-10 rounded-xl bg-gradient-to-tr from-blue-500 to-indigo-500 flex items-center justify-center text-white font-bold text-sm shadow-2xs shrink-0">
                            {vendor.fullName?.charAt(0) || 'V'}
                          </div>
                          <div>
                            <p className="font-bold text-zinc-900 dark:text-zinc-100 flex items-center gap-1.5">
                              {vendor.fullName}
                              {isPending && (
                                <span className="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-bold bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-400">
                                  Review
                                </span>
                              )}
                            </p>
                            {storeName ? (
                              <p className="text-xs font-semibold text-emerald-700 dark:text-emerald-400 flex items-center gap-1">
                                <Building className="h-3 w-3" />
                                {storeName}
                              </p>
                            ) : (
                              <p className="text-xs text-zinc-400 font-mono">ID: {vendor.id.slice(0, 8)}...</p>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="p-4 text-xs text-zinc-600 dark:text-zinc-400 space-y-0.5">
                        <p className="flex items-center gap-1.5">
                          <Mail className="h-3.5 w-3.5 text-zinc-400" />
                          <span>{vendor.email}</span>
                        </p>
                        {vendor.phoneNumber && (
                          <p className="flex items-center gap-1.5 text-zinc-500">
                            <Phone className="h-3.5 w-3.5 text-zinc-400" />
                            <span>{vendor.phoneNumber}</span>
                          </p>
                        )}
                      </td>
                      <td className="p-4">
                        <StatusBadge status={vendor.kycStatus || 'NOT_SUBMITTED'} />
                      </td>
                      <td className="p-4">
                        <StatusBadge status={vendor.status} />
                      </td>
                      <td className="p-4 text-xs text-zinc-500">
                        {formatDate(vendor.createdAt)}
                      </td>
                      <td className="p-4 text-right">
                        <div className="flex items-center justify-end gap-1.5">
                          {/* Approve Button for any Pending status */}
                          {isPending && (
                            <Button
                              size="sm"
                              title="Approve Vendor & KYC"
                              onClick={() => setApproveTarget(vendor)}
                              className="h-8 px-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold gap-1.5 shadow-2xs cursor-pointer"
                            >
                              <CheckCircle className="h-3.5 w-3.5" />
                              Approve
                            </Button>
                          )}

                          {/* Reject Button for Pending */}
                          {isPending && (
                            <Button
                              variant="outline"
                              size="sm"
                              title="Reject Vendor"
                              onClick={() => setRejectTarget(vendor)}
                              className="h-8 px-2.5 rounded-xl border-rose-200 dark:border-rose-900/50 text-xs font-semibold text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/30 gap-1.5 cursor-pointer"
                            >
                              <XCircle className="h-3.5 w-3.5" />
                              Reject
                            </Button>
                          )}

                          <Button
                            variant="outline"
                            size="sm"
                            title="View Full Profile & KYC"
                            onClick={() => setSelectedVendor(vendor)}
                            className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5 cursor-pointer"
                          >
                            <Eye className="h-3.5 w-3.5 text-zinc-500" />
                            View
                          </Button>

                          <Button
                            variant="outline"
                            size="sm"
                            title="Edit Status"
                            onClick={() => {
                              setEditingVendor(vendor);
                              setEditStatus(vendor.status);
                            }}
                            className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5 cursor-pointer"
                          >
                            <Edit className="h-3.5 w-3.5 text-blue-500" />
                            Edit
                          </Button>

                          {vendor.status === 'ACTIVE' && !isPending && (
                            <Button
                              variant="outline"
                              size="sm"
                              title="Suspend Vendor"
                              onClick={() => setSuspendTarget(vendor)}
                              className="h-8 px-2.5 rounded-xl border-rose-200 dark:border-rose-900/50 text-xs font-semibold text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/30 gap-1.5 cursor-pointer"
                            >
                              <Trash2 className="h-3.5 w-3.5" />
                              Suspend
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

      {/* View Vendor Modal */}
      <Dialog open={!!selectedVendor} onOpenChange={(open) => !open && setSelectedVendor(null)}>
        <DialogContent className="sm:max-w-xl max-h-[88vh] overflow-y-auto rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold flex items-center gap-2">
              <Users className="h-5 w-5 text-blue-500" />
              Vendor & KYC Credentials
            </DialogTitle>
          </DialogHeader>

          {selectedVendor && (
            <div className="space-y-4 pt-2 text-xs">
              {/* Header Card */}
              <div className="flex items-center gap-4 p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800">
                <div className="h-14 w-14 rounded-2xl bg-gradient-to-tr from-blue-500 to-indigo-500 flex items-center justify-center text-white font-bold text-xl shadow-xs shrink-0">
                  {selectedVendor.fullName?.charAt(0) || 'V'}
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="text-base font-bold text-zinc-900 dark:text-zinc-50 truncate">
                    {selectedVendor.fullName}
                  </h3>
                  <p className="text-xs text-zinc-400 font-mono">ID: {selectedVendor.id}</p>
                  <div className="flex items-center gap-2 mt-1.5 flex-wrap">
                    <StatusBadge status={selectedVendor.status} />
                    <StatusBadge status={selectedVendor.kycStatus || 'NOT_SUBMITTED'} />
                  </div>
                </div>
              </div>

              {/* Contact Details */}
              <div className="grid grid-cols-2 gap-3 p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800">
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Email Address</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300 break-all">
                    {selectedVendor.email}
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Phone Number</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {selectedVendor.phoneNumber || 'Not provided'}
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Account Role</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {selectedVendor.role}
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Registration Date</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {formatDate(selectedVendor.createdAt)}
                  </span>
                </div>
              </div>

              {/* Business Identity */}
              <div className="p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 space-y-2">
                <div className="flex items-center gap-2 text-xs font-bold text-zinc-900 dark:text-zinc-100 pb-1 border-b border-zinc-200/60 dark:border-zinc-800">
                  <Building className="h-4 w-4 text-emerald-600" />
                  <span>1. Business Identity</span>
                </div>
                <div className="grid grid-cols-2 gap-3 pt-1">
                  <div>
                    <span className="text-zinc-400 block text-[10px] uppercase font-bold">Store / Business Name</span>
                    <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                      {selectedVendor.vendorProfile?.storeName || selectedVendor.businessName || 'N/A'}
                    </span>
                  </div>
                  <div>
                    <span className="text-zinc-400 block text-[10px] uppercase font-bold">Legal Business Name</span>
                    <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                      {selectedVendor.vendorProfile?.legalName || 'N/A'}
                    </span>
                  </div>
                  <div className="col-span-2">
                    <span className="text-zinc-400 block text-[10px] uppercase font-bold">Business Type</span>
                    <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                      {selectedVendor.vendorProfile?.businessType || selectedVendor.businessType || 'Individual Seller'}
                    </span>
                  </div>
                </div>
              </div>

              {/* Tax & Legal (KYC) */}
              <div className="p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 space-y-2">
                <div className="flex items-center gap-2 text-xs font-bold text-zinc-900 dark:text-zinc-100 pb-1 border-b border-zinc-200/60 dark:border-zinc-800">
                  <FileText className="h-4 w-4 text-blue-600" />
                  <span>2. Tax & Legal (KYC)</span>
                </div>
                <div className="grid grid-cols-2 gap-3 pt-1">
                  <div>
                    <span className="text-zinc-400 block text-[10px] uppercase font-bold">PAN Number</span>
                    <span className="font-semibold font-mono text-zinc-700 dark:text-zinc-300">
                      {selectedVendor.vendorProfile?.panNumber || selectedVendor.panNumber || 'Not provided'}
                    </span>
                  </div>
                  <div>
                    <span className="text-zinc-400 block text-[10px] uppercase font-bold">GST Number</span>
                    <span className="font-semibold font-mono text-zinc-700 dark:text-zinc-300">
                      {selectedVendor.vendorProfile?.gstNumber || selectedVendor.gstNumber || 'Not provided'}
                    </span>
                  </div>
                </div>
              </div>

              {/* Pickup & Warehouse Address */}
              <div className="p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 space-y-2">
                <div className="flex items-center gap-2 text-xs font-bold text-zinc-900 dark:text-zinc-100 pb-1 border-b border-zinc-200/60 dark:border-zinc-800">
                  <MapPin className="h-4 w-4 text-amber-600" />
                  <span>3. Pickup & Warehouse Address</span>
                </div>
                <div className="space-y-1.5 pt-1">
                  <div>
                    <span className="text-zinc-400 block text-[10px] uppercase font-bold">Address</span>
                    <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                      {[
                        selectedVendor.vendorProfile?.pickupAddressLine1,
                        selectedVendor.vendorProfile?.pickupAddressLine2,
                      ]
                        .filter(Boolean)
                        .join(', ') || 'Not provided'}
                    </span>
                  </div>
                  <div className="grid grid-cols-3 gap-2 pt-1">
                    <div>
                      <span className="text-zinc-400 block text-[10px] uppercase font-bold">City</span>
                      <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                        {selectedVendor.vendorProfile?.pickupCity || selectedVendor.city || 'N/A'}
                      </span>
                    </div>
                    <div>
                      <span className="text-zinc-400 block text-[10px] uppercase font-bold">State</span>
                      <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                        {selectedVendor.vendorProfile?.pickupState || selectedVendor.state || 'N/A'}
                      </span>
                    </div>
                    <div>
                      <span className="text-zinc-400 block text-[10px] uppercase font-bold">Pincode</span>
                      <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                        {selectedVendor.vendorProfile?.pickupPincode || selectedVendor.pincode || 'N/A'}
                      </span>
                    </div>
                  </div>
                  {selectedVendor.vendorProfile?.pickupContactPhone && (
                    <div className="pt-1">
                      <span className="text-zinc-400 block text-[10px] uppercase font-bold">Pickup Contact Phone</span>
                      <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                        {selectedVendor.vendorProfile.pickupContactPhone}
                      </span>
                    </div>
                  )}
                </div>
              </div>

              {/* Bank Account Details */}
              <div className="p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 space-y-2">
                <div className="flex items-center gap-2 text-xs font-bold text-zinc-900 dark:text-zinc-100 pb-1 border-b border-zinc-200/60 dark:border-zinc-800">
                  <Landmark className="h-4 w-4 text-purple-600" />
                  <span>4. Bank Account Details (Payouts)</span>
                </div>
                <div className="grid grid-cols-2 gap-3 pt-1">
                  <div>
                    <span className="text-zinc-400 block text-[10px] uppercase font-bold">Account Holder</span>
                    <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                      {selectedVendor.vendorProfile?.bankAccountHolderName || 'Not provided'}
                    </span>
                  </div>
                  <div>
                    <span className="text-zinc-400 block text-[10px] uppercase font-bold">Account Number</span>
                    <span className="font-semibold font-mono text-zinc-700 dark:text-zinc-300">
                      {selectedVendor.vendorProfile?.bankAccountNumber || 'Not provided'}
                    </span>
                  </div>
                  <div>
                    <span className="text-zinc-400 block text-[10px] uppercase font-bold">IFSC Code</span>
                    <span className="font-semibold font-mono text-zinc-700 dark:text-zinc-300">
                      {selectedVendor.vendorProfile?.bankIfscCode || 'Not provided'}
                    </span>
                  </div>
                  <div>
                    <span className="text-zinc-400 block text-[10px] uppercase font-bold">Bank Name / Type</span>
                    <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                      {selectedVendor.vendorProfile?.bankName || 'N/A'} ({selectedVendor.vendorProfile?.bankAccountType || 'CURRENT'})
                    </span>
                  </div>
                </div>
              </div>

              {/* Modal Footer with Actions */}
              <DialogFooter className="pt-3 gap-2 flex-wrap">
                <Button
                  variant="outline"
                  onClick={() => setSelectedVendor(null)}
                  className="rounded-xl h-9 text-xs font-semibold"
                >
                  Close
                </Button>

                {(selectedVendor.status === 'PENDING' || selectedVendor.kycStatus === 'PENDING') && (
                  <>
                    <Button
                      variant="outline"
                      onClick={() => {
                        const v = selectedVendor;
                        setSelectedVendor(null);
                        setRejectTarget(v);
                      }}
                      className="rounded-xl h-9 text-xs font-semibold border-rose-200 text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/30 gap-1.5"
                    >
                      <XCircle className="h-3.5 w-3.5" />
                      Reject Request
                    </Button>

                    <Button
                      onClick={() => {
                        const v = selectedVendor;
                        setSelectedVendor(null);
                        setApproveTarget(v);
                      }}
                      className="rounded-xl h-9 text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs gap-1.5"
                    >
                      <CheckCircle className="h-3.5 w-3.5" />
                      Approve Vendor & KYC
                    </Button>
                  </>
                )}
              </DialogFooter>
            </div>
          )}
        </DialogContent>
      </Dialog>

      {/* Edit Vendor Status Modal */}
      <Dialog open={!!editingVendor} onOpenChange={(open) => !open && setEditingVendor(null)}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold">Update Vendor Status</DialogTitle>
          </DialogHeader>

          {editingVendor && (
            <div className="space-y-4 pt-2">
              <div className="p-3 bg-zinc-50 dark:bg-zinc-900 rounded-xl border border-zinc-100 dark:border-zinc-800 text-xs">
                <p className="font-bold text-zinc-900 dark:text-zinc-100">{editingVendor.fullName}</p>
                <p className="text-zinc-400">{editingVendor.email}</p>
              </div>

              <div className="space-y-1.5">
                <Label className="text-xs font-bold">Account Status</Label>
                <Select value={editStatus} onValueChange={(val) => { if (val) setEditStatus(val); }}>
                  <SelectTrigger className="h-9 rounded-xl text-xs">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="ACTIVE">ACTIVE (Authorized & Verified)</SelectItem>
                    <SelectItem value="PENDING">PENDING (Review Required)</SelectItem>
                    <SelectItem value="SUSPENDED">SUSPENDED (Locked)</SelectItem>
                    <SelectItem value="REJECTED">REJECTED (Declined)</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <DialogFooter className="pt-2">
                <Button
                  variant="outline"
                  onClick={() => setEditingVendor(null)}
                  className="rounded-xl h-9 text-xs"
                >
                  Cancel
                </Button>
                <Button
                  onClick={() => {
                    if (editStatus === 'ACTIVE') {
                      approveMutation.mutate(editingVendor.id);
                    } else if (editStatus === 'SUSPENDED') {
                      suspendMutation.mutate(editingVendor.id);
                    } else if (editStatus === 'REJECTED') {
                      rejectMutation.mutate(editingVendor.id);
                    }
                    setEditingVendor(null);
                  }}
                  className="bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl h-9 text-xs font-semibold"
                >
                  Update Status
                </Button>
              </DialogFooter>
            </div>
          )}
        </DialogContent>
      </Dialog>

      {/* Approve Confirmation Dialog */}
      <ConfirmDialog
        open={!!approveTarget}
        onClose={() => setApproveTarget(null)}
        onConfirm={() => approveTarget && approveMutation.mutate(approveTarget.id)}
        title="Approve Vendor Account & KYC"
        description={
          approveTarget ? (
            <span>
              Are you sure you want to approve merchant <strong>&quot;{approveTarget.fullName}&quot;</strong>? Their account and KYC status will be set to <strong>ACTIVE & VERIFIED</strong>, allowing them to list products and sell on ALANGA.
            </span>
          ) : undefined
        }
        confirmText="Approve Vendor"
        variant="primary"
        isLoading={approveMutation.isPending}
      />

      {/* Reject Confirmation Dialog */}
      <ConfirmDialog
        open={!!rejectTarget}
        onClose={() => setRejectTarget(null)}
        onConfirm={() => rejectTarget && rejectMutation.mutate(rejectTarget.id)}
        title="Reject Vendor Application"
        description={
          rejectTarget ? (
            <span>
              Are you sure you want to reject merchant application for <strong>&quot;{rejectTarget.fullName}&quot;</strong>? Their account and KYC will be marked as REJECTED.
            </span>
          ) : undefined
        }
        confirmText="Reject Vendor"
        variant="destructive"
        isLoading={rejectMutation.isPending}
      />

      {/* Suspend Confirmation Dialog */}
      <ConfirmDialog
        open={!!suspendTarget}
        onClose={() => setSuspendTarget(null)}
        onConfirm={() => suspendTarget && suspendMutation.mutate(suspendTarget.id)}
        title="Suspend Vendor Account"
        description={
          suspendTarget ? (
            <span>
              Are you sure you want to suspend <strong>&quot;{suspendTarget.fullName}&quot;</strong>? Their catalog items will become unavailable to customers immediately.
            </span>
          ) : undefined
        }
        confirmText="Suspend Vendor"
        variant="destructive"
        isLoading={suspendMutation.isPending}
      />
    </div>
  );
}

export default function VendorsPage() {
  return (
    <Suspense fallback={<div className="p-8 text-center text-xs text-zinc-500">Loading Vendors...</div>}>
      <VendorsPageContent />
    </Suspense>
  );
}
