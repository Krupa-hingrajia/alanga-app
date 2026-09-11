'use client';

import React, { useState, useMemo } from 'react';
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

export default function VendorsPage() {
  const queryClient = useQueryClient();

  // Filters & Pagination
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [page, setPage] = useState(1);
  const limit = 10;

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

  const { data, isLoading, refetch, isFetching } = useQuery({
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
      toast.success('Vendor approved successfully');
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
              Vendors
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              Marketplace merchant accounts, KYC credentials, and store authorizations.
            </p>
          </div>
        </div>
      </div>

      {/* Filter & Search Toolbar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-3 bg-white dark:bg-zinc-950 p-4 rounded-2xl border border-zinc-200/80 dark:border-zinc-800 shadow-2xs">
        <div className="relative w-full sm:w-80">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-zinc-400" />
          <Input
            placeholder="Search by vendor name, email or phone..."
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
            <SelectTrigger className="w-[150px] h-9 rounded-xl text-xs border-zinc-200 dark:border-zinc-800">
              <SelectValue placeholder="All Status" />
            </SelectTrigger>
            <SelectContent>
              {STATUS_FILTERS.map((st) => (
                <SelectItem key={st} value={st}>
                  {st === 'ALL' ? 'All Status' : st}
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
                    <span>Vendor</span>
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
                sortedVendors.map((vendor) => (
                  <tr
                    key={vendor.id}
                    className="hover:bg-zinc-50/80 dark:hover:bg-zinc-900/40 transition-colors"
                  >
                    <td className="p-4">
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-xl bg-gradient-to-tr from-blue-500 to-indigo-500 flex items-center justify-center text-white font-bold text-sm shadow-2xs shrink-0">
                          {vendor.fullName?.charAt(0) || 'V'}
                        </div>
                        <div>
                          <p className="font-bold text-zinc-900 dark:text-zinc-100">
                            {vendor.fullName}
                          </p>
                          <p className="text-xs text-zinc-400 font-mono">ID: {vendor.id.slice(0, 8)}...</p>
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
                        <Button
                          variant="outline"
                          size="sm"
                          title="View Vendor Profile"
                          onClick={() => setSelectedVendor(vendor)}
                          className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
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
                          className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                        >
                          <Edit className="h-3.5 w-3.5 text-blue-500" />
                          Edit
                        </Button>

                        {vendor.status === 'PENDING' && (
                          <Button
                            size="sm"
                            title="Approve Vendor"
                            onClick={() => setApproveTarget(vendor)}
                            className="h-8 px-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold gap-1.5"
                          >
                            <CheckCircle className="h-3.5 w-3.5" />
                            Approve
                          </Button>
                        )}

                        {vendor.status === 'ACTIVE' && (
                          <Button
                            variant="outline"
                            size="sm"
                            title="Suspend Vendor"
                            onClick={() => setSuspendTarget(vendor)}
                            className="h-8 px-2.5 rounded-xl border-rose-200 dark:border-rose-900/50 text-xs font-semibold text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/30 gap-1.5"
                          >
                            <Trash2 className="h-3.5 w-3.5" />
                            Suspend
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

      {/* View Vendor Modal */}
      <Dialog open={!!selectedVendor} onOpenChange={(open) => !open && setSelectedVendor(null)}>
        <DialogContent className="sm:max-w-lg rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold flex items-center gap-2">
              <Users className="h-5 w-5 text-blue-500" />
              Vendor Profile
            </DialogTitle>
          </DialogHeader>

          {selectedVendor && (
            <div className="space-y-4 pt-2 text-xs">
              <div className="flex items-center gap-4 p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800">
                <div className="h-14 w-14 rounded-2xl bg-gradient-to-tr from-blue-500 to-indigo-500 flex items-center justify-center text-white font-bold text-xl shadow-xs">
                  {selectedVendor.fullName?.charAt(0) || 'V'}
                </div>
                <div>
                  <h3 className="text-base font-bold text-zinc-900 dark:text-zinc-50">
                    {selectedVendor.fullName}
                  </h3>
                  <div className="flex items-center gap-2 mt-1">
                    <StatusBadge status={selectedVendor.status} />
                    <StatusBadge status={selectedVendor.kycStatus || 'NOT_SUBMITTED'} />
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3 p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800">
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Email Address</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
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

              <DialogFooter className="pt-2">
                <Button
                  variant="outline"
                  onClick={() => setSelectedVendor(null)}
                  className="rounded-xl h-9 text-xs font-semibold"
                >
                  Close
                </Button>
                {selectedVendor.status === 'PENDING' && (
                  <Button
                    onClick={() => {
                      const v = selectedVendor;
                      setSelectedVendor(null);
                      setApproveTarget(v);
                    }}
                    className="rounded-xl h-9 text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white"
                  >
                    <CheckCircle className="h-3.5 w-3.5 mr-1.5" />
                    Approve Vendor
                  </Button>
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
                    <SelectItem value="ACTIVE">ACTIVE (Authorized)</SelectItem>
                    <SelectItem value="PENDING">PENDING (Review)</SelectItem>
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
        title="Approve Vendor Account"
        description={
          approveTarget ? (
            <span>
              Are you sure you want to approve merchant <strong>&quot;{approveTarget.fullName}&quot;</strong>? They will be granted full access to list products and sell on ALANGA.
            </span>
          ) : undefined
        }
        confirmText="Approve Vendor"
        variant="primary"
        isLoading={approveMutation.isPending}
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
