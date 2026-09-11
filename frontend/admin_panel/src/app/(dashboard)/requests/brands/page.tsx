'use client';

import React, { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
  Clock,
  Search,
  Eye,
  CheckCircle,
  XCircle,
  Tag,
  ArrowUpDown,
  ArrowUp,
  ArrowDown,
  Inbox,
  Calendar,
  Building,
} from 'lucide-react';

import {
  getPendingBrands,
  approveBrand,
  rejectBrand,
  Brand,
} from '@/features/brands/api';
import { StatusBadge } from '@/components/StatusBadge';
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

export default function BrandRequestsPage() {
  const queryClient = useQueryClient();

  const [search, setSearch] = useState('');
  const [sortField, setSortField] = useState<'name' | 'createdAt'>('createdAt');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Modals & Action Targets
  const [viewingBrand, setViewingBrand] = useState<Brand | null>(null);
  const [approveTarget, setApproveTarget] = useState<Brand | null>(null);
  const [rejectTarget, setRejectTarget] = useState<Brand | null>(null);
  const [rejectReason, setRejectReason] = useState('');

  const { data: pendingBrands, isLoading } = useQuery({
    queryKey: ['pendingBrands'],
    queryFn: getPendingBrands,
  });

  const brands = pendingBrands ?? [];

  // Filter & Sort
  const filteredBrands = useMemo(() => {
    return brands.filter((b) =>
      b.name.toLowerCase().includes(search.toLowerCase().trim())
    );
  }, [brands, search]);

  const sortedBrands = useMemo(() => {
    return [...filteredBrands].sort((a, b) => {
      const aVal = a[sortField] || '';
      const bVal = b[sortField] || '';
      if (sortDirection === 'asc') {
        return aVal.localeCompare(bVal);
      }
      return bVal.localeCompare(aVal);
    });
  }, [filteredBrands, sortField, sortDirection]);

  const handleSort = (field: 'name' | 'createdAt') => {
    if (sortField === field) {
      setSortDirection((prev) => (prev === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortField(field);
      setSortDirection('asc');
    }
  };

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ['pendingBrands'] });
    queryClient.invalidateQueries({ queryKey: ['adminBrands'] });
    queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
  };

  const approveMutation = useMutation({
    mutationFn: approveBrand,
    onSuccess: () => {
      toast.success('Brand request approved');
      invalidate();
      setApproveTarget(null);
      if (viewingBrand && viewingBrand.id === approveTarget?.id) {
        setViewingBrand(null);
      }
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Approval failed'),
  });

  const rejectMutation = useMutation({
    mutationFn: ({ id, reason }: { id: string; reason: string }) => rejectBrand({ id, reason }),
    onSuccess: () => {
      toast.success('Brand request rejected');
      invalidate();
      setRejectTarget(null);
      setRejectReason('');
      if (viewingBrand && viewingBrand.id === rejectTarget?.id) {
        setViewingBrand(null);
      }
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Rejection failed'),
  });

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
          <div className="p-3 bg-amber-500/10 text-amber-600 dark:bg-amber-500/20 dark:text-amber-400 rounded-2xl">
            <Clock className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Brand Requests
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              Review, verify, and approve vendor-submitted brand registrations.
            </p>
          </div>
        </div>
      </div>

      {/* Filter & Search Toolbar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-3 bg-white dark:bg-zinc-950 p-4 rounded-2xl border border-zinc-200/80 dark:border-zinc-800 shadow-2xs">
        <div className="relative w-full sm:w-80">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-zinc-400" />
          <Input
            placeholder="Search brand requests..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-9 h-9 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs"
          />
        </div>

        <div className="text-xs text-zinc-500 font-medium">
          {sortedBrands.length} pending submission{sortedBrands.length !== 1 ? 's' : ''}
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
                    onClick={() => handleSort('name')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Brand Name</span>
                    {sortField === 'name' ? (
                      sortDirection === 'asc' ? <ArrowUp className="h-3.5 w-3.5 text-emerald-600" /> : <ArrowDown className="h-3.5 w-3.5 text-emerald-600" />
                    ) : (
                      <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4">Submission Source</th>
                <th className="p-4">Status</th>
                <th className="p-4">
                  <button
                    onClick={() => handleSort('createdAt')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Request Date</span>
                    {sortField === 'createdAt' ? (
                      sortDirection === 'asc' ? <ArrowUp className="h-3.5 w-3.5 text-emerald-600" /> : <ArrowDown className="h-3.5 w-3.5 text-emerald-600" />
                    ) : (
                      <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4 text-right">Verification Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100 dark:divide-zinc-900">
              {isLoading ? (
                Array.from({ length: 4 }).map((_, idx) => (
                  <tr key={idx} className="animate-pulse">
                    <td className="p-4" colSpan={5}>
                      <div className="h-7 bg-zinc-100 dark:bg-zinc-800 rounded-xl" />
                    </td>
                  </tr>
                ))
              ) : sortedBrands.length === 0 ? (
                <tr>
                  <td colSpan={5} className="p-12 text-center">
                    <div className="flex flex-col items-center justify-center space-y-2">
                      <div className="p-3 bg-emerald-100 dark:bg-emerald-950/40 rounded-full text-emerald-600 dark:text-emerald-400">
                        <CheckCircle className="h-8 w-8" />
                      </div>
                      <p className="text-sm font-semibold text-zinc-800 dark:text-zinc-200">
                        All Caught Up!
                      </p>
                      <p className="text-xs text-zinc-400 max-w-sm">
                        There are currently no pending vendor brand requests.
                      </p>
                    </div>
                  </td>
                </tr>
              ) : (
                sortedBrands.map((brand) => (
                  <tr
                    key={brand.id}
                    className="hover:bg-zinc-50/80 dark:hover:bg-zinc-900/40 transition-colors"
                  >
                    <td className="p-4">
                      <div className="flex items-center gap-3">
                        {brand.logo ? (
                          <img
                            src={brand.logo}
                            alt={brand.name}
                            className="h-10 w-10 rounded-xl object-contain border border-zinc-200 dark:border-zinc-800 p-1 bg-white"
                          />
                        ) : (
                          <div className="p-2.5 bg-violet-500/10 text-violet-600 dark:bg-violet-500/20 dark:text-violet-400 rounded-xl">
                            <Tag className="h-5 w-5" />
                          </div>
                        )}
                        <div>
                          <p className="font-bold text-zinc-900 dark:text-zinc-100">{brand.name}</p>
                          {brand.description && (
                            <p className="text-xs text-zinc-400 truncate max-w-xs">{brand.description}</p>
                          )}
                        </div>
                      </div>
                    </td>
                    <td className="p-4 text-xs font-semibold text-zinc-700 dark:text-zinc-300">
                      {brand.createdByVendorId ? 'Vendor Submitted' : 'Admin'}
                    </td>
                    <td className="p-4">
                      <StatusBadge status="PENDING" />
                    </td>
                    <td className="p-4 text-xs text-zinc-500">
                      {formatDate(brand.createdAt)}
                    </td>
                    <td className="p-4 text-right">
                      <div className="flex items-center justify-end gap-1.5">
                        <Button
                          variant="outline"
                          size="sm"
                          title="View Request Details"
                          onClick={() => setViewingBrand(brand)}
                          className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                        >
                          <Eye className="h-3.5 w-3.5 text-zinc-500" />
                          View
                        </Button>

                        <Button
                          size="sm"
                          title="Approve Brand"
                          onClick={() => setApproveTarget(brand)}
                          className="h-8 px-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold gap-1.5"
                        >
                          <CheckCircle className="h-3.5 w-3.5" />
                          Approve
                        </Button>

                        <Button
                          variant="outline"
                          size="sm"
                          title="Reject Brand"
                          onClick={() => {
                            setRejectTarget(brand);
                            setRejectReason('');
                          }}
                          className="h-8 px-2.5 rounded-xl border-rose-200 dark:border-rose-900/50 text-xs font-semibold text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/30 gap-1.5"
                        >
                          <XCircle className="h-3.5 w-3.5" />
                          Reject
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* View Brand Request Modal */}
      <Dialog open={!!viewingBrand} onOpenChange={(open) => !open && setViewingBrand(null)}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold flex items-center gap-2">
              <Tag className="h-5 w-5 text-violet-500" />
              Brand Request Details
            </DialogTitle>
          </DialogHeader>

          {viewingBrand && (
            <div className="space-y-4 pt-2 text-xs">
              <div className="flex items-center gap-4 p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800">
                {viewingBrand.logo ? (
                  <img
                    src={viewingBrand.logo}
                    alt={viewingBrand.name}
                    className="h-16 w-16 rounded-xl object-contain border border-zinc-200 dark:border-zinc-800 bg-white p-1"
                  />
                ) : (
                  <div className="h-16 w-16 rounded-xl bg-violet-100 dark:bg-violet-950/40 text-violet-600 flex items-center justify-center">
                    <Tag className="h-8 w-8" />
                  </div>
                )}
                <div>
                  <h3 className="text-base font-bold text-zinc-900 dark:text-zinc-50">
                    {viewingBrand.name}
                  </h3>
                  <div className="mt-1 flex items-center gap-2">
                    <StatusBadge status="PENDING" />
                    <span className="text-zinc-400 text-[11px]">
                      Submitted {formatDate(viewingBrand.createdAt)}
                    </span>
                  </div>
                </div>
              </div>

              {viewingBrand.description && (
                <div className="space-y-1">
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Brand Description</span>
                  <p className="text-zinc-600 dark:text-zinc-400 leading-relaxed bg-zinc-50 dark:bg-zinc-900 p-3 rounded-xl border border-zinc-100 dark:border-zinc-800">
                    {viewingBrand.description}
                  </p>
                </div>
              )}

              <DialogFooter className="pt-2">
                <Button
                  variant="outline"
                  onClick={() => setViewingBrand(null)}
                  className="rounded-xl h-9 text-xs font-semibold"
                >
                  Close
                </Button>
                <Button
                  onClick={() => {
                    const b = viewingBrand;
                    setViewingBrand(null);
                    setApproveTarget(b);
                  }}
                  className="rounded-xl h-9 text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white"
                >
                  <CheckCircle className="h-3.5 w-3.5 mr-1.5" />
                  Approve Request
                </Button>
              </DialogFooter>
            </div>
          )}
        </DialogContent>
      </Dialog>

      {/* Reject Request Dialog */}
      <Dialog open={!!rejectTarget} onOpenChange={(open) => !open && setRejectTarget(null)}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold text-rose-600">Reject Brand Request</DialogTitle>
          </DialogHeader>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              if (rejectTarget && rejectReason.trim()) {
                rejectMutation.mutate({ id: rejectTarget.id, reason: rejectReason.trim() });
              }
            }}
            className="space-y-4 pt-2"
          >
            <p className="text-xs text-zinc-500">
              Please enter an official reason explaining why this brand registration is rejected:
            </p>
            <div className="space-y-1.5">
              <Label htmlFor="req-reject-reason" className="text-xs font-bold">Reason *</Label>
              <Input
                id="req-reject-reason"
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                placeholder="e.g. Duplicate trademark, unverified brand assets..."
                className="rounded-xl h-9 text-xs"
                required
              />
            </div>

            <DialogFooter className="pt-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => setRejectTarget(null)}
                className="rounded-xl h-9 text-xs"
              >
                Cancel
              </Button>
              <Button
                type="submit"
                disabled={rejectMutation.isPending || !rejectReason.trim()}
                className="bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl h-9 text-xs font-semibold"
              >
                {rejectMutation.isPending ? 'Rejecting...' : 'Reject Request'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Approve Confirmation Dialog */}
      <ConfirmDialog
        open={!!approveTarget}
        onClose={() => setApproveTarget(null)}
        onConfirm={() => approveTarget && approveMutation.mutate(approveTarget.id)}
        title="Approve Brand Request"
        description={
          approveTarget ? (
            <span>
              Are you sure you want to approve brand <strong>&quot;{approveTarget.name}&quot;</strong>? It will become active and selectable by vendors across the marketplace.
            </span>
          ) : undefined
        }
        confirmText="Approve Brand"
        variant="primary"
        isLoading={approveMutation.isPending}
      />
    </div>
  );
}
