'use client';

import React, { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Tag,
  Plus,
  Edit,
  Trash2,
  Power,
  Search,
  CheckCircle2,
  XCircle,
  Eye,
  AlertCircle,
  Clock,
  ArrowUpDown,
  ArrowUp,
  ArrowDown,
  Inbox,
  Globe,
  ExternalLink,
} from 'lucide-react';
import { toast } from 'sonner';

import {
  getAdminBrands,
  getPendingBrands,
  createAdminBrand,
  updateAdminBrand,
  toggleBrandStatus,
  approveBrand,
  rejectBrand,
  deleteAdminBrand,
  Brand,
} from '@/features/brands/api';
import { StatusBadge } from '@/components/StatusBadge';
import { MarketplacePagination } from '@/components/MarketplacePagination';
import { ConfirmDialog } from '@/components/ConfirmDialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
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

export default function BrandsPage() {
  const queryClient = useQueryClient();

  // Active Tab
  const [activeTab, setActiveTab] = useState<'management' | 'requests'>('management');

  // Management Filters
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');
  const [page, setPage] = useState(1);
  const limit = 10;

  // Sorting
  const [sortField, setSortField] = useState<'name' | 'createdAt' | 'prodCount'>('createdAt');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Dialog States
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [editingBrand, setEditingBrand] = useState<Brand | null>(null);

  // Rejection & Detail Modals
  const [rejectModalBrand, setRejectModalBrand] = useState<Brand | null>(null);
  const [rejectReason, setRejectReason] = useState('');
  const [detailModalBrand, setDetailModalBrand] = useState<Brand | null>(null);

  // Confirm Delete Dialog
  const [deleteTarget, setDeleteTarget] = useState<Brand | null>(null);

  // Form State
  const [formName, setFormName] = useState('');
  const [formLogo, setFormLogo] = useState('');
  const [formDesc, setFormDesc] = useState('');
  const [formStatus, setFormStatus] = useState<'ACTIVE' | 'INACTIVE'>('ACTIVE');

  // Error Alert State
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // Fetch Marketplace Brands (Management Tab)
  const { data: marketplaceData, isLoading: isMarketplaceLoading } = useQuery({
    queryKey: ['adminBrands', statusFilter, search, page],
    queryFn: () =>
      getAdminBrands({
        status: statusFilter === 'ALL' ? undefined : statusFilter,
        search: search.trim() || undefined,
        page,
        limit,
      }),
  });

  const brands = marketplaceData?.items ?? [];

  // Fetch Pending Brand Requests (Requests Tab)
  const { data: pendingBrands, isLoading: isPendingLoading } = useQuery({
    queryKey: ['pendingBrands'],
    queryFn: getPendingBrands,
  });

  const getBrandStatus = (item: { status?: string; isActive?: boolean }) => {
    if (item.status) return item.status.toUpperCase();
    if (item.isActive === false) return 'INACTIVE';
    return 'ACTIVE';
  };

  // Client-side Sorting
  const sortedBrands = useMemo(() => {
    if (!brands) return [];
    return [...brands].sort((a, b) => {
      let aVal: any = a[sortField as keyof Brand];
      let bVal: any = b[sortField as keyof Brand];

      if (sortField === 'prodCount') {
        aVal = a._count?.products ?? a.productsCount ?? 0;
        bVal = b._count?.products ?? b.productsCount ?? 0;
      }

      if (typeof aVal === 'string') {
        return sortDirection === 'asc'
          ? aVal.localeCompare(bVal || '')
          : (bVal || '').localeCompare(aVal);
      }
      return sortDirection === 'asc' ? (aVal > bVal ? 1 : -1) : aVal < bVal ? 1 : -1;
    });
  }, [brands, sortField, sortDirection]);

  const handleSort = (field: 'name' | 'createdAt' | 'prodCount') => {
    if (sortField === field) {
      setSortDirection((prev) => (prev === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortField(field);
      setSortDirection('asc');
    }
  };

  // Mutations
  const createMutation = useMutation({
    mutationFn: createAdminBrand,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminBrands'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setIsCreateOpen(false);
      resetForm();
      toast.success('Brand created successfully');
    },
    onError: (err: any) => {
      const msg = err?.response?.data?.message || '';
      if (msg.toLowerCase().includes('already exists') || err?.response?.status === 409) {
        setErrorMessage('Brand with this name already exists.');
      } else {
        setErrorMessage(msg || 'Failed to create brand.');
      }
    },
  });

  const updateMutation = useMutation({
    mutationFn: updateAdminBrand,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminBrands'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setIsEditOpen(false);
      setEditingBrand(null);
      resetForm();
      toast.success('Brand updated successfully');
    },
    onError: (err: any) => {
      setErrorMessage(err?.response?.data?.message || 'Failed to update brand.');
    },
  });

  const toggleStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) => toggleBrandStatus(id, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminBrands'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      toast.success('Brand status updated');
    },
    onError: (err: any) => {
      setErrorMessage(err?.response?.data?.message || 'Failed to toggle status.');
    },
  });

  const approveMutation = useMutation({
    mutationFn: approveBrand,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['pendingBrands'] });
      queryClient.invalidateQueries({ queryKey: ['adminBrands'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      toast.success('Brand request approved');
    },
    onError: (err: any) => {
      setErrorMessage(err?.response?.data?.message || 'Failed to approve brand.');
    },
  });

  const rejectMutation = useMutation({
    mutationFn: ({ id, reason }: { id: string; reason: string }) => rejectBrand({ id, reason }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['pendingBrands'] });
      queryClient.invalidateQueries({ queryKey: ['adminBrands'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setRejectModalBrand(null);
      setRejectReason('');
      toast.success('Brand request rejected');
    },
    onError: (err: any) => {
      setErrorMessage(err?.response?.data?.message || 'Failed to reject brand.');
    },
  });

  const deleteMutation = useMutation({
    mutationFn: deleteAdminBrand,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminBrands'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setDeleteTarget(null);
      toast.success('Brand deleted successfully');
    },
    onError: (err: any) => {
      const msg = err?.response?.data?.message || '';
      if (msg.toLowerCase().includes('product') || msg.toLowerCase().includes('foreign') || err?.response?.status === 409) {
        setErrorMessage('Cannot delete brand because one or more products are attached to it.');
      } else {
        setErrorMessage(msg || 'Failed to delete brand.');
      }
      setDeleteTarget(null);
    },
  });

  const resetForm = () => {
    setFormName('');
    setFormLogo('');
    setFormDesc('');
    setFormStatus('ACTIVE');
    setErrorMessage(null);
  };

  const handleOpenCreate = () => {
    resetForm();
    setIsCreateOpen(true);
  };

  const handleOpenEdit = (brand: Brand) => {
    setEditingBrand(brand);
    setFormName(brand.name);
    setFormLogo(brand.logo || '');
    setFormDesc(brand.description || '');
    setFormStatus(getBrandStatus(brand) === 'INACTIVE' ? 'INACTIVE' : 'ACTIVE');
    setIsEditOpen(true);
  };

  const handleCreateSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formName.trim()) return;
    createMutation.mutate({
      name: formName.trim(),
      logo: formLogo.trim() || undefined,
      description: formDesc.trim() || undefined,
      status: formStatus,
    });
  };

  const handleEditSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingBrand || !formName.trim()) return;
    updateMutation.mutate({
      id: editingBrand.id,
      data: {
        name: formName.trim(),
        logo: formLogo.trim() || undefined,
        description: formDesc.trim() || undefined,
        status: formStatus,
      },
    });
  };

  const handleRejectSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!rejectModalBrand || !rejectReason.trim()) return;
    rejectMutation.mutate({ id: rejectModalBrand.id, reason: rejectReason.trim() });
  };

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return 'N/A';
    try {
      return new Date(dateStr).toLocaleDateString('en-IN', {
        year: 'numeric',
        month: 'short',
        day: '2-digit',
      });
    } catch {
      return dateStr;
    }
  };

  const pendingCount = pendingBrands?.length || 0;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-3 bg-violet-500/10 text-violet-600 dark:bg-violet-500/20 dark:text-violet-400 rounded-2xl">
            <Tag className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Brands
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              Verified marketplace brands and vendor brand onboarding requests.
            </p>
          </div>
        </div>

        <Button
          onClick={handleOpenCreate}
          className="gap-2 bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl shadow-xs px-4 py-2 text-xs font-semibold"
        >
          <Plus className="h-4 w-4" />
          Create Brand
        </Button>
      </div>

      {/* Error Alert Banner */}
      {errorMessage && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 dark:bg-rose-950/20 dark:border-rose-900 flex items-center justify-between animate-in fade-in">
          <div className="flex items-center gap-3 text-rose-700 dark:text-rose-400 text-xs font-medium">
            <AlertCircle className="h-5 w-5 shrink-0" />
            <span>{errorMessage}</span>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setErrorMessage(null)}
            className="text-rose-700 hover:bg-rose-100 dark:hover:bg-rose-900/30 rounded-lg text-xs h-7 px-2"
          >
            Dismiss
          </Button>
        </div>
      )}

      {/* Tabs */}
      <Tabs
        value={activeTab}
        onValueChange={(val) => setActiveTab(val as 'management' | 'requests')}
        className="space-y-6"
      >
        <TabsList className="bg-zinc-100 dark:bg-zinc-900 p-1 rounded-2xl border border-zinc-200/80 dark:border-zinc-800">
          <TabsTrigger
            value="management"
            className="rounded-xl text-xs font-semibold data-[state=active]:bg-white dark:data-[state=active]:bg-zinc-950 data-[state=active]:shadow-xs px-4 py-2"
          >
            Brand Management ({marketplaceData?.total ?? 0})
          </TabsTrigger>
          <TabsTrigger
            value="requests"
            className="rounded-xl text-xs font-semibold data-[state=active]:bg-white dark:data-[state=active]:bg-zinc-950 data-[state=active]:shadow-xs px-4 py-2 flex items-center gap-2"
          >
            <span>Pending Requests</span>
            {pendingCount > 0 && (
              <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-500 text-white">
                {pendingCount}
              </span>
            )}
          </TabsTrigger>
        </TabsList>

        {/* Tab 1: Brand Management */}
        <TabsContent value="management" className="space-y-6 m-0">
          {/* Filters */}
          <div className="flex flex-col sm:flex-row items-center justify-between gap-3 bg-white dark:bg-zinc-950 p-4 rounded-2xl border border-zinc-200/80 dark:border-zinc-800 shadow-2xs">
            <div className="relative w-full sm:w-80">
              <Search className="absolute left-3 top-2.5 h-4 w-4 text-zinc-400" />
              <Input
                placeholder="Search brands..."
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
                <SelectTrigger className="w-[140px] h-9 rounded-xl text-xs border-zinc-200 dark:border-zinc-800">
                  <SelectValue placeholder="All Status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ALL">All Status</SelectItem>
                  <SelectItem value="ACTIVE">Active Only</SelectItem>
                  <SelectItem value="INACTIVE">Inactive Only</SelectItem>
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
                    <th className="p-4">Status</th>
                    <th className="p-4">
                      <button
                        onClick={() => handleSort('prodCount')}
                        className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                      >
                        <span>Products</span>
                        {sortField === 'prodCount' ? (
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
                        <span>Created Date</span>
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
                  {isMarketplaceLoading ? (
                    Array.from({ length: 6 }).map((_, idx) => (
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
                          <div className="p-3 bg-zinc-100 dark:bg-zinc-850 rounded-full text-zinc-400">
                            <Inbox className="h-8 w-8" />
                          </div>
                          <p className="text-sm font-semibold text-zinc-800 dark:text-zinc-200">
                            No Brands Found
                          </p>
                          <p className="text-xs text-zinc-400 max-w-sm">
                            Try adjusting your search criteria or resetting filters.
                          </p>
                        </div>
                      </td>
                    </tr>
                  ) : (
                    sortedBrands.map((brand) => {
                      const prodCount = brand._count?.products ?? brand.productsCount ?? 0;
                      const brandStatus = getBrandStatus(brand);
                      const isActive = brandStatus === 'ACTIVE';

                      return (
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
                          <td className="p-4">
                            <StatusBadge status={brandStatus} />
                          </td>
                          <td className="p-4 font-semibold text-zinc-700 dark:text-zinc-300">
                            {prodCount}
                          </td>
                          <td className="p-4 text-xs text-zinc-500">
                            {formatDate(brand.createdAt)}
                          </td>
                          <td className="p-4 text-right">
                            <div className="flex items-center justify-end gap-1.5">
                              <Button
                                variant="outline"
                                size="sm"
                                title="View Brand Details"
                                onClick={() => setDetailModalBrand(brand)}
                                className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                              >
                                <Eye className="h-3.5 w-3.5 text-zinc-500" />
                                View
                              </Button>

                              <Button
                                variant="outline"
                                size="sm"
                                title={isActive ? 'Deactivate Brand' : 'Activate Brand'}
                                onClick={() =>
                                  toggleStatusMutation.mutate({ id: brand.id, status: brandStatus })
                                }
                                className={`h-8 w-8 p-0 rounded-xl border-zinc-200 dark:border-zinc-800 ${
                                  isActive ? 'text-emerald-600 hover:bg-emerald-50' : 'text-zinc-400 hover:bg-zinc-100'
                                }`}
                              >
                                <Power className="h-3.5 w-3.5" />
                              </Button>

                              <Button
                                variant="outline"
                                size="sm"
                                title="Edit Brand"
                                onClick={() => handleOpenEdit(brand)}
                                className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                              >
                                <Edit className="h-3.5 w-3.5 text-blue-500" />
                                Edit
                              </Button>

                              <Button
                                variant="outline"
                                size="sm"
                                title="Delete Brand"
                                onClick={() => setDeleteTarget(brand)}
                                className="h-8 px-2.5 rounded-xl border-rose-200 dark:border-rose-900/50 text-xs font-semibold text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/30 gap-1.5"
                              >
                                <Trash2 className="h-3.5 w-3.5" />
                                Delete
                              </Button>
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
          {marketplaceData && (
            <MarketplacePagination
              page={marketplaceData.page}
              limit={marketplaceData.limit}
              total={marketplaceData.total}
              totalPages={marketplaceData.totalPages}
              onPageChange={(p) => setPage(p)}
            />
          )}
        </TabsContent>

        {/* Tab 2: Requests */}
        <TabsContent value="requests" className="space-y-4 m-0">
          <div className="rounded-2xl border border-zinc-200/80 dark:border-zinc-800 bg-white dark:bg-zinc-950 overflow-hidden shadow-2xs">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead className="bg-zinc-50/90 dark:bg-zinc-900/90 text-zinc-500 dark:text-zinc-400 text-xs font-bold uppercase tracking-wider border-b border-zinc-200/80 dark:border-zinc-800">
                  <tr>
                    <th className="p-4">Brand Logo & Name</th>
                    <th className="p-4">Submitted By</th>
                    <th className="p-4">Status</th>
                    <th className="p-4">Request Date</th>
                    <th className="p-4 text-right">Approval Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-zinc-100 dark:divide-zinc-900">
                  {isPendingLoading ? (
                    Array.from({ length: 4 }).map((_, idx) => (
                      <tr key={idx} className="animate-pulse">
                        <td className="p-4" colSpan={5}>
                          <div className="h-7 bg-zinc-100 dark:bg-zinc-800 rounded-xl" />
                        </td>
                      </tr>
                    ))
                  ) : !pendingBrands || pendingBrands.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="p-12 text-center">
                        <div className="flex flex-col items-center justify-center space-y-2">
                          <div className="p-3 bg-emerald-100 dark:bg-emerald-950/40 rounded-full text-emerald-600 dark:text-emerald-400">
                            <CheckCircle2 className="h-8 w-8" />
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
                    pendingBrands.map((brand) => (
                      <tr key={brand.id} className="hover:bg-zinc-50/80 dark:hover:bg-zinc-900/40 transition-colors">
                        <td className="p-4">
                          <div className="flex items-center gap-3">
                            {brand.logo ? (
                              <img
                                src={brand.logo}
                                alt={brand.name}
                                className="h-10 w-10 rounded-xl object-contain border border-zinc-200 dark:border-zinc-800 p-1 bg-white"
                              />
                            ) : (
                              <div className="p-2.5 bg-purple-500/10 text-purple-600 dark:bg-purple-500/20 dark:text-purple-400 rounded-xl">
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
                          {brand.createdByVendorId ? 'Vendor Submitted' : 'System'}
                        </td>
                        <td className="p-4">
                          <StatusBadge status="PENDING" />
                        </td>
                        <td className="p-4 text-xs text-zinc-500">
                          {formatDate(brand.createdAt)}
                        </td>
                        <td className="p-4 text-right">
                          <div className="flex items-center justify-end gap-2">
                            <Button
                              variant="outline"
                              size="sm"
                              title="View Details"
                              onClick={() => setDetailModalBrand(brand)}
                              className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1"
                            >
                              <Eye className="h-3.5 w-3.5 text-zinc-500" />
                              View
                            </Button>
                            <Button
                              size="sm"
                              onClick={() => approveMutation.mutate(brand.id)}
                              disabled={approveMutation.isPending}
                              className="h-8 px-3 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold gap-1"
                            >
                              <CheckCircle2 className="h-3.5 w-3.5" />
                              Approve
                            </Button>
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => setRejectModalBrand(brand)}
                              className="h-8 px-3 rounded-xl border-rose-200 text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/30 text-xs font-semibold gap-1"
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
        </TabsContent>
      </Tabs>

      {/* View Brand Detail Modal */}
      <Dialog open={!!detailModalBrand} onOpenChange={(open) => !open && setDetailModalBrand(null)}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold flex items-center gap-2">
              <Tag className="h-5 w-5 text-violet-500" />
              Brand Information
            </DialogTitle>
          </DialogHeader>

          {detailModalBrand && (
            <div className="space-y-4 pt-2 text-xs">
              <div className="flex items-center gap-4 p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800">
                {detailModalBrand.logo ? (
                  <img
                    src={detailModalBrand.logo}
                    alt={detailModalBrand.name}
                    className="h-16 w-16 rounded-xl object-contain border border-zinc-200 dark:border-zinc-800 bg-white p-1"
                  />
                ) : (
                  <div className="h-16 w-16 rounded-xl bg-violet-100 dark:bg-violet-950/40 text-violet-600 flex items-center justify-center">
                    <Tag className="h-8 w-8" />
                  </div>
                )}
                <div>
                  <h3 className="text-base font-bold text-zinc-900 dark:text-zinc-50">
                    {detailModalBrand.name}
                  </h3>
                  <div className="mt-1 flex items-center gap-2">
                    <StatusBadge status={getBrandStatus(detailModalBrand)} />
                    <span className="text-zinc-400 text-[11px]">
                      Added {formatDate(detailModalBrand.createdAt)}
                    </span>
                  </div>
                </div>
              </div>

              {detailModalBrand.description && (
                <div className="space-y-1">
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">About Brand</span>
                  <p className="text-zinc-600 dark:text-zinc-400 leading-relaxed bg-zinc-50 dark:bg-zinc-900 p-3 rounded-xl border border-zinc-100 dark:border-zinc-800">
                    {detailModalBrand.description}
                  </p>
                </div>
              )}

              {detailModalBrand.rejectedReason && (
                <div className="p-3 rounded-xl bg-rose-50 dark:bg-rose-950/30 border border-rose-200 dark:border-rose-900 text-rose-700 dark:text-rose-400">
                  <span className="font-bold block mb-0.5">Rejection Note:</span>
                  <p>{detailModalBrand.rejectedReason}</p>
                </div>
              )}

              <DialogFooter className="pt-2">
                <Button
                  variant="outline"
                  onClick={() => setDetailModalBrand(null)}
                  className="rounded-xl h-9 text-xs font-semibold"
                >
                  Close
                </Button>
                <Button
                  onClick={() => {
                    const b = detailModalBrand;
                    setDetailModalBrand(null);
                    handleOpenEdit(b);
                  }}
                  className="rounded-xl h-9 text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs"
                >
                  <Edit className="h-3.5 w-3.5 mr-1.5" />
                  Edit Brand
                </Button>
              </DialogFooter>
            </div>
          )}
        </DialogContent>
      </Dialog>

      {/* Create Brand Dialog */}
      <Dialog open={isCreateOpen} onOpenChange={setIsCreateOpen}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold">Create Brand</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleCreateSubmit} className="space-y-4 pt-2">
            <div className="space-y-1.5">
              <Label htmlFor="create-brand-name" className="text-xs font-bold">Brand Name *</Label>
              <Input
                id="create-brand-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="e.g. Nike, Apple, Samsung"
                className="rounded-xl h-9 text-xs"
                required
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="create-brand-logo" className="text-xs font-bold">Brand Logo URL</Label>
              <Input
                id="create-brand-logo"
                value={formLogo}
                onChange={(e) => setFormLogo(e.target.value)}
                placeholder="https://example.com/logo.png"
                className="rounded-xl h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="create-brand-desc" className="text-xs font-bold">Description</Label>
              <Input
                id="create-brand-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Brand details or summary..."
                className="rounded-xl h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="create-brand-status" className="text-xs font-bold">Initial Status</Label>
              <Select value={formStatus} onValueChange={(val) => val && setFormStatus(val as 'ACTIVE' | 'INACTIVE')}>
                <SelectTrigger id="create-brand-status" className="h-9 rounded-xl text-xs">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ACTIVE">ACTIVE</SelectItem>
                  <SelectItem value="INACTIVE">INACTIVE</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <DialogFooter className="pt-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsCreateOpen(false)}
                className="rounded-xl h-9 text-xs"
              >
                Cancel
              </Button>
              <Button
                type="submit"
                disabled={createMutation.isPending || !formName.trim()}
                className="bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl h-9 text-xs font-semibold"
              >
                {createMutation.isPending ? 'Creating...' : 'Create Brand'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Edit Brand Dialog */}
      <Dialog open={isEditOpen} onOpenChange={setIsEditOpen}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold">Edit Brand</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleEditSubmit} className="space-y-4 pt-2">
            <div className="space-y-1.5">
              <Label htmlFor="edit-brand-name" className="text-xs font-bold">Brand Name *</Label>
              <Input
                id="edit-brand-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="Brand Name"
                className="rounded-xl h-9 text-xs"
                required
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="edit-brand-logo" className="text-xs font-bold">Logo URL</Label>
              <Input
                id="edit-brand-logo"
                value={formLogo}
                onChange={(e) => setFormLogo(e.target.value)}
                placeholder="https://example.com/logo.png"
                className="rounded-xl h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="edit-brand-desc" className="text-xs font-bold">Description</Label>
              <Input
                id="edit-brand-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Description..."
                className="rounded-xl h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="edit-brand-status" className="text-xs font-bold">Status</Label>
              <Select value={formStatus} onValueChange={(val) => val && setFormStatus(val as 'ACTIVE' | 'INACTIVE')}>
                <SelectTrigger id="edit-brand-status" className="h-9 rounded-xl text-xs">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ACTIVE">ACTIVE</SelectItem>
                  <SelectItem value="INACTIVE">INACTIVE</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <DialogFooter className="pt-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsEditOpen(false)}
                className="rounded-xl h-9 text-xs"
              >
                Cancel
              </Button>
              <Button
                type="submit"
                disabled={updateMutation.isPending || !formName.trim()}
                className="bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl h-9 text-xs font-semibold"
              >
                {updateMutation.isPending ? 'Saving...' : 'Save Changes'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Reject Request Dialog */}
      <Dialog open={!!rejectModalBrand} onOpenChange={(open) => !open && setRejectModalBrand(null)}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold text-rose-600">Reject Brand Request</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleRejectSubmit} className="space-y-4 pt-2">
            <p className="text-xs text-zinc-500">
              Please provide a clear reason explaining why this brand request is being rejected:
            </p>
            <div className="space-y-1.5">
              <Label htmlFor="reject-reason" className="text-xs font-bold">Rejection Reason *</Label>
              <Input
                id="reject-reason"
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                placeholder="e.g. Duplicate brand, trademark violation..."
                className="rounded-xl h-9 text-xs"
                required
              />
            </div>

            <DialogFooter className="pt-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => setRejectModalBrand(null)}
                className="rounded-xl h-9 text-xs"
              >
                Cancel
              </Button>
              <Button
                type="submit"
                disabled={rejectMutation.isPending || !rejectReason.trim()}
                className="bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl h-9 text-xs font-semibold"
              >
                {rejectMutation.isPending ? 'Rejecting...' : 'Confirm Rejection'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <ConfirmDialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={() => deleteTarget && deleteMutation.mutate(deleteTarget.id)}
        title="Delete Brand"
        description={
          deleteTarget ? (
            <span>
              Are you sure you want to delete brand <strong>&quot;{deleteTarget.name}&quot;</strong>? This cannot be undone if products are linked.
            </span>
          ) : undefined
        }
        confirmText="Delete Brand"
        variant="destructive"
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
}
