'use client';

import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { Search, RefreshCw, Users, AlertCircle, ChevronLeft, ChevronRight, Store, Phone, Mail, MapPin, Calendar, Building } from 'lucide-react';

import { getVendors, approveVendor, rejectVendor, suspendVendor, Vendor } from '@/features/vendors/api';
import { StatusBadge } from '@/components/StatusBadge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent } from '@/components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';

const STATUS_FILTERS = ['All', 'PENDING', 'ACTIVE', 'REJECTED', 'SUSPENDED'];

export default function VendorsPage() {
  const queryClient = useQueryClient();
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('All');
  const [page, setPage] = useState(1);
  const [selectedVendor, setSelectedVendor] = useState<Vendor | null>(null);

  const { data, isLoading, isError, refetch, isFetching } = useQuery({
    queryKey: ['vendors', search, statusFilter, page],
    queryFn: () =>
      getVendors({
        search: search || undefined,
        status: statusFilter === 'All' ? undefined : statusFilter,
        page,
        limit: 10,
      }),
  });

  const approveMutation = useMutation({
    mutationFn: approveVendor,
    onSuccess: () => {
      toast.success('Vendor approved successfully');
      queryClient.invalidateQueries({ queryKey: ['vendors'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setSelectedVendor(null);
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Approval failed'),
  });

  const rejectMutation = useMutation({
    mutationFn: rejectVendor,
    onSuccess: () => {
      toast.success('Vendor rejected');
      queryClient.invalidateQueries({ queryKey: ['vendors'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setSelectedVendor(null);
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Rejection failed'),
  });

  const suspendMutation = useMutation({
    mutationFn: suspendVendor,
    onSuccess: () => {
      toast.success('Vendor suspended');
      queryClient.invalidateQueries({ queryKey: ['vendors'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setSelectedVendor(null);
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Suspension failed'),
  });

  const formatDate = (d: string) =>
    new Date(d).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">Vendor Management</h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400 mt-1">
            Review, approve, or suspend vendor accounts across the marketplace.
          </p>
        </div>
        <Button
          variant="outline"
          onClick={() => refetch()}
          disabled={isFetching}
          className="self-start sm:self-auto h-10 px-4 rounded-xl border-zinc-200 dark:border-zinc-800"
        >
          <RefreshCw className={`h-4 w-4 mr-2 ${isFetching ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      {/* Filters */}
      <Card className="border border-zinc-200/60 dark:border-zinc-800/60">
        <CardContent className="p-4 flex flex-col sm:flex-row gap-3">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-400" />
            <Input
              placeholder="Search by name, email, or business..."
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(1); }}
              className="pl-9 h-10 rounded-xl bg-zinc-50/50 dark:bg-zinc-900/50 border-zinc-200 dark:border-zinc-800"
            />
          </div>
          <div className="flex flex-wrap gap-2">
            {STATUS_FILTERS.map((s) => (
              <button
                key={s}
                onClick={() => { setStatusFilter(s); setPage(1); }}
                className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-all ${
                  statusFilter === s
                    ? 'bg-rose-500 text-white shadow-sm shadow-rose-500/20'
                    : 'bg-zinc-100 dark:bg-zinc-900 text-zinc-600 dark:text-zinc-400 hover:bg-zinc-200 dark:hover:bg-zinc-800'
                }`}
              >
                {s}
              </button>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Content */}
      {isLoading ? (
        <div className="grid gap-4 md:grid-cols-2">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="h-40 rounded-2xl bg-zinc-200 dark:bg-zinc-800 animate-pulse" />
          ))}
        </div>
      ) : isError ? (
        <div className="flex flex-col items-center justify-center min-h-[40vh] border border-dashed border-zinc-200 dark:border-zinc-800 rounded-3xl">
          <AlertCircle className="h-10 w-10 text-rose-500 mb-3" />
          <p className="font-semibold text-zinc-900 dark:text-zinc-50">Failed to load vendors</p>
          <Button onClick={() => refetch()} className="mt-4 bg-rose-500 hover:bg-rose-600 text-white rounded-xl">
            Retry
          </Button>
        </div>
      ) : data?.items.length === 0 ? (
        <div className="flex flex-col items-center justify-center min-h-[40vh] border border-dashed border-zinc-200 dark:border-zinc-800 rounded-3xl">
          <Users className="h-10 w-10 text-zinc-400 mb-3" />
          <p className="font-semibold text-zinc-700 dark:text-zinc-300">No vendors found</p>
          <p className="text-sm text-zinc-500 dark:text-zinc-400 mt-1">Try changing the filter or search query</p>
        </div>
      ) : (
        <>
          <div className="grid gap-4 md:grid-cols-2">
            {data?.items.map((vendor) => (
              <div
                key={vendor.id}
                className="group p-5 rounded-2xl border border-zinc-200/60 dark:border-zinc-800/60 bg-white dark:bg-zinc-950 hover:shadow-lg hover:-translate-y-0.5 transition-all duration-200 cursor-pointer"
                onClick={() => setSelectedVendor(vendor)}
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-xl bg-gradient-to-tr from-rose-500 to-amber-500 flex items-center justify-center text-white font-bold text-sm shadow">
                      {vendor.fullName.charAt(0)}
                    </div>
                    <div>
                      <p className="font-semibold text-zinc-900 dark:text-zinc-50 text-sm">{vendor.fullName}</p>
                      <p className="text-xs text-zinc-500 dark:text-zinc-400">{vendor.email}</p>
                    </div>
                  </div>
                  <StatusBadge status={vendor.status} />
                </div>

                <div className="grid grid-cols-2 gap-2 text-xs text-zinc-500 dark:text-zinc-400">
                  {vendor.businessName && (
                    <div className="flex items-center gap-1.5">
                      <Store className="h-3.5 w-3.5 shrink-0" />
                      <span className="truncate">{vendor.businessName}</span>
                    </div>
                  )}
                  <div className="flex items-center gap-1.5">
                    <Phone className="h-3.5 w-3.5 shrink-0" />
                    <span>{vendor.countryCode} {vendor.mobileNumber}</span>
                  </div>
                  {vendor.city && (
                    <div className="flex items-center gap-1.5">
                      <MapPin className="h-3.5 w-3.5 shrink-0" />
                      <span>{vendor.city}, {vendor.state}</span>
                    </div>
                  )}
                  <div className="flex items-center gap-1.5">
                    <Calendar className="h-3.5 w-3.5 shrink-0" />
                    <span>{formatDate(vendor.createdAt)}</span>
                  </div>
                </div>

                {vendor.status === 'PENDING' && (
                  <div className="flex gap-2 mt-4 pt-4 border-t border-zinc-100 dark:border-zinc-900">
                    <Button
                      size="sm"
                      onClick={(e) => { e.stopPropagation(); approveMutation.mutate(vendor.id); }}
                      disabled={approveMutation.isPending}
                      className="flex-1 h-8 text-xs rounded-lg bg-emerald-500 hover:bg-emerald-600 text-white font-semibold"
                    >
                      Approve
                    </Button>
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={(e) => { e.stopPropagation(); rejectMutation.mutate(vendor.id); }}
                      disabled={rejectMutation.isPending}
                      className="flex-1 h-8 text-xs rounded-lg border-rose-200 dark:border-rose-800 text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-900/20"
                    >
                      Reject
                    </Button>
                  </div>
                )}
                {vendor.status === 'ACTIVE' && (
                  <div className="flex gap-2 mt-4 pt-4 border-t border-zinc-100 dark:border-zinc-900">
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={(e) => { e.stopPropagation(); suspendMutation.mutate(vendor.id); }}
                      disabled={suspendMutation.isPending}
                      className="flex-1 h-8 text-xs rounded-lg border-zinc-200 dark:border-zinc-800 text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-900"
                    >
                      Suspend
                    </Button>
                  </div>
                )}
              </div>
            ))}
          </div>

          {/* Pagination */}
          {data && data.totalPages > 1 && (
            <div className="flex items-center justify-between pt-2">
              <p className="text-sm text-zinc-500 dark:text-zinc-400">
                Showing {((page - 1) * 10) + 1}–{Math.min(page * 10, data.total)} of {data.total} vendors
              </p>
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                  disabled={page === 1}
                  className="rounded-xl border-zinc-200 dark:border-zinc-800 h-9 w-9 p-0"
                >
                  <ChevronLeft className="h-4 w-4" />
                </Button>
                <span className="flex items-center px-3 text-sm font-medium text-zinc-700 dark:text-zinc-300">
                  {page} / {data.totalPages}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setPage((p) => Math.min(data.totalPages, p + 1))}
                  disabled={page === data.totalPages}
                  className="rounded-xl border-zinc-200 dark:border-zinc-800 h-9 w-9 p-0"
                >
                  <ChevronRight className="h-4 w-4" />
                </Button>
              </div>
            </div>
          )}
        </>
      )}

      {/* Vendor Detail Modal */}
      <Dialog open={!!selectedVendor} onOpenChange={(v) => { if (!v) setSelectedVendor(null); }}>
        <DialogContent className="sm:max-w-lg border border-zinc-200/60 dark:border-zinc-800/60 bg-white dark:bg-zinc-950">
          {selectedVendor && (
            <>
              <DialogHeader>
                <div className="flex items-center gap-4">
                  <div className="h-14 w-14 rounded-2xl bg-gradient-to-tr from-rose-500 to-amber-500 flex items-center justify-center text-white font-bold text-xl shadow-lg">
                    {selectedVendor.fullName.charAt(0)}
                  </div>
                  <div>
                    <DialogTitle className="text-xl font-bold text-zinc-900 dark:text-zinc-50">
                      {selectedVendor.fullName}
                    </DialogTitle>
                    <StatusBadge status={selectedVendor.status} className="mt-1" />
                  </div>
                </div>
              </DialogHeader>

              <div className="space-y-4 py-2">
                <div className="grid grid-cols-2 gap-3">
                  {[
                    { icon: Mail, label: 'Email', value: selectedVendor.email },
                    { icon: Phone, label: 'Mobile', value: `${selectedVendor.countryCode} ${selectedVendor.mobileNumber}` },
                    { icon: Store, label: 'Business Name', value: selectedVendor.businessName },
                    { icon: Building, label: 'Business Type', value: selectedVendor.businessType },
                    { icon: MapPin, label: 'Location', value: selectedVendor.city ? `${selectedVendor.city}, ${selectedVendor.state} ${selectedVendor.pincode}` : null },
                    { icon: Calendar, label: 'Registered', value: formatDate(selectedVendor.createdAt) },
                  ].filter((r) => r.value).map((row, idx) => (
                    <div key={idx} className="p-3 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800">
                      <div className="flex items-center gap-1.5 text-xs text-zinc-500 dark:text-zinc-400 mb-1">
                        <row.icon className="h-3.5 w-3.5" />
                        {row.label}
                      </div>
                      <p className="text-sm font-semibold text-zinc-800 dark:text-zinc-200 truncate">{row.value}</p>
                    </div>
                  ))}
                </div>

                {(selectedVendor.gstNumber || selectedVendor.panNumber) && (
                  <div className="grid grid-cols-2 gap-3">
                    {selectedVendor.gstNumber && (
                      <div className="p-3 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 col-span-1">
                        <p className="text-xs text-zinc-500 dark:text-zinc-400 mb-1">GST Number</p>
                        <p className="text-sm font-mono font-semibold text-zinc-800 dark:text-zinc-200">{selectedVendor.gstNumber}</p>
                      </div>
                    )}
                    {selectedVendor.panNumber && (
                      <div className="p-3 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 col-span-1">
                        <p className="text-xs text-zinc-500 dark:text-zinc-400 mb-1">PAN Number</p>
                        <p className="text-sm font-mono font-semibold text-zinc-800 dark:text-zinc-200">{selectedVendor.panNumber}</p>
                      </div>
                    )}
                  </div>
                )}
              </div>

              <div className="flex gap-3 pt-2 border-t border-zinc-100 dark:border-zinc-900">
                {selectedVendor.status === 'PENDING' && (
                  <>
                    <Button
                      onClick={() => approveMutation.mutate(selectedVendor.id)}
                      disabled={approveMutation.isPending}
                      className="flex-1 bg-emerald-500 hover:bg-emerald-600 text-white rounded-xl font-semibold"
                    >
                      Approve Vendor
                    </Button>
                    <Button
                      variant="outline"
                      onClick={() => rejectMutation.mutate(selectedVendor.id)}
                      disabled={rejectMutation.isPending}
                      className="flex-1 border-rose-200 dark:border-rose-800 text-rose-600 dark:text-rose-400 rounded-xl font-semibold"
                    >
                      Reject
                    </Button>
                  </>
                )}
                {selectedVendor.status === 'ACTIVE' && (
                  <Button
                    variant="outline"
                    onClick={() => suspendMutation.mutate(selectedVendor.id)}
                    disabled={suspendMutation.isPending}
                    className="flex-1 border-zinc-200 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300 rounded-xl font-semibold"
                  >
                    Suspend Account
                  </Button>
                )}
              </div>
            </>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
