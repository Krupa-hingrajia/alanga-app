'use client';

import React, { useState } from 'react';
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
  Store,
  Clock,
} from 'lucide-react';

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

  // Dialog States
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [editingBrand, setEditingBrand] = useState<Brand | null>(null);

  // Rejection & Detail Modals
  const [rejectModalBrand, setRejectModalBrand] = useState<Brand | null>(null);
  const [rejectReason, setRejectReason] = useState('');
  const [detailModalBrand, setDetailModalBrand] = useState<Brand | null>(null);

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

  // Mutations
  const createMutation = useMutation({
    mutationFn: createAdminBrand,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminBrands'] });
      setIsCreateOpen(false);
      resetForm();
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
      setIsEditOpen(false);
      setEditingBrand(null);
      resetForm();
    },
    onError: (err: any) => {
      const msg = err?.response?.data?.message || '';
      if (msg.toLowerCase().includes('already exists') || err?.response?.status === 409) {
        setErrorMessage('Brand with this name already exists.');
      } else {
        setErrorMessage(msg || 'Failed to update brand.');
      }
    },
  });

  const toggleStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) => toggleBrandStatus(id, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminBrands'] });
    },
  });

  const approveMutation = useMutation({
    mutationFn: approveBrand,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['pendingBrands'] });
      queryClient.invalidateQueries({ queryKey: ['adminBrands'] });
    },
  });

  const rejectMutation = useMutation({
    mutationFn: ({ id, reason }: { id: string; reason: string }) => rejectBrand({ id, reason }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['pendingBrands'] });
      queryClient.invalidateQueries({ queryKey: ['adminBrands'] });
      setRejectModalBrand(null);
      setRejectReason('');
    },
  });

  const deleteMutation = useMutation({
    mutationFn: deleteAdminBrand,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminBrands'] });
    },
    onError: (err: any) => {
      const msg = err?.response?.data?.message || '';
      if (msg.toLowerCase().includes('used') || msg.toLowerCase().includes('products')) {
        setErrorMessage('This Brand is being used by Products.');
      } else {
        setErrorMessage(msg || 'Failed to delete brand.');
      }
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

  const handleDelete = (brand: Brand) => {
    if (confirm(`Are you sure you want to delete brand "${brand.name}"?`)) {
      setErrorMessage(null);
      deleteMutation.mutate(brand.id);
    }
  };

  const handleRejectSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!rejectModalBrand || !rejectReason.trim()) return;
    rejectMutation.mutate({ id: rejectModalBrand.id, reason: rejectReason.trim() });
  };

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return 'N/A';
    try {
      return new Date(dateStr).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
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
          <div className="p-3 bg-purple-500/10 text-purple-500 rounded-2xl">
            <Tag className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Master Brand Management
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              Manage marketplace brands and review vendor brand registration requests.
            </p>
          </div>
        </div>

        <Button
          onClick={handleOpenCreate}
          className="gap-2 bg-purple-600 hover:bg-purple-700 text-white rounded-xl shadow-sm px-4 py-2 text-xs font-semibold"
        >
          <Plus className="h-4 w-4" />
          Create Brand
        </Button>
      </div>

      {/* Error Alert Banner */}
      {errorMessage && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 dark:bg-rose-950/20 dark:border-rose-900 flex items-center justify-between">
          <div className="flex items-center gap-3 text-rose-700 dark:text-rose-400 text-sm font-medium">
            <AlertCircle className="h-5 w-5 shrink-0" />
            <span>{errorMessage}</span>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setErrorMessage(null)}
            className="text-rose-700 hover:bg-rose-100 rounded-lg text-xs"
          >
            Dismiss
          </Button>
        </div>
      )}

      {/* Navigation Tabs */}
      <Tabs
        value={activeTab}
        onValueChange={(val) => setActiveTab(val as 'management' | 'requests')}
        className="w-full"
      >
        <TabsList className="bg-zinc-100 dark:bg-zinc-900 p-1 rounded-2xl border border-zinc-200/60 dark:border-zinc-800">
          <TabsTrigger
            value="management"
            className="rounded-xl px-4 py-2 text-xs font-bold gap-2 data-[state=active]:bg-white dark:data-[state=active]:bg-zinc-800 data-[state=active]:shadow-sm"
          >
            <Store className="h-4 w-4 text-purple-500" />
            <span>Brand Management</span>
            {marketplaceData?.total !== undefined && (
              <span className="ml-1 px-2 py-0.5 rounded-full bg-purple-500/10 text-purple-500 text-xs font-extrabold">
                {marketplaceData.total}
              </span>
            )}
          </TabsTrigger>

          <TabsTrigger
            value="requests"
            className="rounded-xl px-4 py-2 text-xs font-bold gap-2 data-[state=active]:bg-white dark:data-[state=active]:bg-zinc-800 data-[state=active]:shadow-sm"
          >
            <Clock className="h-4 w-4 text-amber-500" />
            <span>Brand Requests</span>
            {pendingBrands?.length !== undefined && pendingBrands.length > 0 && (
              <span className="ml-1 px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-600 dark:text-amber-400 text-xs font-extrabold animate-pulse">
                {pendingBrands.length}
              </span>
            )}
          </TabsTrigger>
        </TabsList>

        {/* SECTION 1: BRAND MANAGEMENT TAB */}
        <TabsContent value="management" className="space-y-4 pt-4">
          {/* Search & Filter Toolbar */}
          <div className="flex flex-col sm:flex-row items-center justify-between gap-4 bg-white dark:bg-zinc-950 p-4 rounded-2xl border border-zinc-200/60 dark:border-zinc-800">
            <div className="relative w-full sm:w-72">
              <Search className="absolute left-3 top-2.5 h-4 w-4 text-zinc-400" />
              <Input
                placeholder="Search brand by name..."
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

          {/* Table Component */}
          <div className="rounded-2xl border border-zinc-200/60 dark:border-zinc-800 bg-white dark:bg-zinc-950 overflow-hidden shadow-sm">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead className="bg-zinc-50 dark:bg-zinc-900/50 text-zinc-500 text-xs font-semibold uppercase tracking-wider border-b border-zinc-200/60 dark:border-zinc-800">
                  <tr>
                    <th className="p-4">Brand Logo & Name</th>
                    <th className="p-4">Status</th>
                    <th className="p-4">Products Count</th>
                    <th className="p-4">Created Date</th>
                    <th className="p-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-zinc-100 dark:divide-zinc-900">
                  {isMarketplaceLoading ? (
                    Array.from({ length: 5 }).map((_, idx) => (
                      <tr key={idx} className="animate-pulse">
                        <td className="p-4" colSpan={5}>
                          <div className="h-8 bg-zinc-100 dark:bg-zinc-800 rounded-lg" />
                        </td>
                      </tr>
                    ))
                  ) : brands.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="p-8 text-center text-zinc-400">
                        No Brands Available
                      </td>
                    </tr>
                  ) : (
                    brands.map((brand) => {
                      const prodCount = brand._count?.products ?? brand.productsCount ?? 0;
                      const brandStatus = getBrandStatus(brand);
                      const isActive = brandStatus === 'ACTIVE';

                      return (
                        <tr
                          key={brand.id}
                          className="hover:bg-zinc-50/80 dark:hover:bg-zinc-900/30 transition-colors"
                        >
                          <td className="p-4">
                            <div className="flex items-center gap-3">
                              {brand.logo ? (
                                <img
                                  src={brand.logo}
                                  alt={brand.name}
                                  className="h-10 w-10 rounded-xl object-contain border border-zinc-200 dark:border-zinc-800 p-1"
                                />
                              ) : (
                                <div className="p-2.5 bg-purple-500/10 text-purple-500 rounded-xl">
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
                            <div className="flex items-center justify-end gap-2">
                              <Button
                                variant="outline"
                                size="sm"
                                title={isActive ? 'Deactivate Brand' : 'Activate Brand'}
                                onClick={() =>
                                  toggleStatusMutation.mutate({ id: brand.id, status: brandStatus })
                                }
                                className={`h-8 w-8 p-0 rounded-lg ${
                                  isActive ? 'text-emerald-600 border-emerald-200' : 'text-zinc-400'
                                }`}
                              >
                                <Power className="h-4 w-4" />
                              </Button>

                              <Button
                                variant="outline"
                                size="sm"
                                title="Edit Brand"
                                onClick={() => handleOpenEdit(brand)}
                                className="h-8 w-8 p-0 rounded-lg text-zinc-600 hover:text-zinc-900"
                              >
                                <Edit className="h-4 w-4" />
                              </Button>

                              <Button
                                variant="outline"
                                size="sm"
                                title="Delete Brand"
                                onClick={() => handleDelete(brand)}
                                className="h-8 w-8 p-0 rounded-lg text-rose-600 hover:text-rose-700 hover:bg-rose-50 border-rose-200"
                              >
                                <Trash2 className="h-4 w-4" />
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

        {/* SECTION 2: BRAND REQUESTS TAB */}
        <TabsContent value="requests" className="space-y-4 pt-4">
          <div className="flex items-center gap-2 px-4 py-3 rounded-2xl bg-amber-50 dark:bg-amber-900/20 border border-amber-100 dark:border-amber-900">
            <div className="h-2 w-2 rounded-full bg-amber-500 animate-pulse" />
            <p className="text-sm text-amber-800 dark:text-amber-400 font-medium">
              {isPendingLoading
                ? 'Loading pending brand requests...'
                : `${pendingBrands?.length ?? 0} pending brand request${pendingBrands?.length !== 1 ? 's' : ''} awaiting review`}
            </p>
          </div>

          <div className="rounded-2xl border border-zinc-200/60 dark:border-zinc-800 bg-white dark:bg-zinc-950 overflow-hidden shadow-sm">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead className="bg-zinc-50 dark:bg-zinc-900/50 text-zinc-500 text-xs font-semibold uppercase tracking-wider border-b border-zinc-200/60 dark:border-zinc-800">
                  <tr>
                    <th className="p-4">Brand Logo</th>
                    <th className="p-4">Brand Name</th>
                    <th className="p-4">Vendor Name</th>
                    <th className="p-4">Requested Date</th>
                    <th className="p-4">Description</th>
                    <th className="p-4">Status</th>
                    <th className="p-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-zinc-100 dark:divide-zinc-900">
                  {isPendingLoading ? (
                    Array.from({ length: 3 }).map((_, idx) => (
                      <tr key={idx} className="animate-pulse">
                        <td className="p-4" colSpan={7}>
                          <div className="h-8 bg-zinc-100 dark:bg-zinc-800 rounded-lg" />
                        </td>
                      </tr>
                    ))
                  ) : !pendingBrands || pendingBrands.length === 0 ? (
                    <tr>
                      <td colSpan={7} className="p-8 text-center text-zinc-400">
                        No Pending Brand Requests
                      </td>
                    </tr>
                  ) : (
                    pendingBrands.map((brand) => (
                      <tr key={brand.id} className="hover:bg-zinc-50/80 dark:hover:bg-zinc-900/30 transition-colors">
                        <td className="p-4">
                          {brand.logo ? (
                            <img
                              src={brand.logo}
                              alt={brand.name}
                              className="h-10 w-10 rounded-xl object-contain border border-zinc-200 dark:border-zinc-800 p-1"
                            />
                          ) : (
                            <div className="p-2.5 bg-amber-500/10 text-amber-500 rounded-xl w-10 h-10 flex items-center justify-center">
                              <Tag className="h-5 w-5" />
                            </div>
                          )}
                        </td>
                        <td className="p-4 font-bold text-zinc-900 dark:text-zinc-100">
                          {brand.name}
                        </td>
                        <td className="p-4 text-xs font-semibold text-zinc-700 dark:text-zinc-300">
                          {brand.vendorName || brand.vendor?.name || brand.vendorEmail || 'Vendor'}
                        </td>
                        <td className="p-4 text-xs text-zinc-500">
                          {formatDate(brand.createdAt)}
                        </td>
                        <td className="p-4 text-xs text-zinc-500 max-w-xs truncate">
                          {brand.description || 'No description provided'}
                        </td>
                        <td className="p-4">
                          <StatusBadge status="PENDING" />
                        </td>
                        <td className="p-4 text-right">
                          <div className="flex items-center justify-end gap-2">
                            <Button
                              size="sm"
                              variant="outline"
                              onClick={() => setDetailModalBrand(brand)}
                              className="h-8 text-xs gap-1.5 rounded-lg border-zinc-200 dark:border-zinc-800"
                            >
                              <Eye className="h-3.5 w-3.5" />
                              View Details
                            </Button>

                            <Button
                              size="sm"
                              disabled={approveMutation.isPending}
                              onClick={() => approveMutation.mutate(brand.id)}
                              className="h-8 text-xs gap-1 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-medium"
                            >
                              <CheckCircle2 className="h-3.5 w-3.5" />
                              Approve
                            </Button>

                            <Button
                              size="sm"
                              variant="outline"
                              onClick={() => {
                                setRejectModalBrand(brand);
                                setRejectReason('');
                              }}
                              className="h-8 text-xs gap-1 text-rose-600 border-rose-200 hover:bg-rose-50 rounded-lg font-medium"
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

      {/* Create Brand Dialog */}
      <Dialog open={isCreateOpen} onOpenChange={setIsCreateOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Create Master Brand</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleCreateSubmit} className="space-y-4 pt-2">
            <div className="space-y-1">
              <Label htmlFor="create-brand-name">Brand Name *</Label>
              <Input
                id="create-brand-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="e.g. Nike, Adidas, Apple"
                required
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="create-brand-logo">Brand Logo URL</Label>
              <Input
                id="create-brand-logo"
                value={formLogo}
                onChange={(e) => setFormLogo(e.target.value)}
                placeholder="https://example.com/logo.png"
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="create-brand-desc">Description</Label>
              <Input
                id="create-brand-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Brand description..."
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="create-brand-status">Initial Status</Label>
              <Select value={formStatus} onValueChange={(val) => val && setFormStatus(val as 'ACTIVE' | 'INACTIVE')}>
                <SelectTrigger id="create-brand-status" className="h-9">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ACTIVE">ACTIVE</SelectItem>
                  <SelectItem value="INACTIVE">INACTIVE</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <DialogFooter className="pt-2">
              <Button type="button" variant="outline" onClick={() => setIsCreateOpen(false)}>
                Cancel
              </Button>

              <Button
                type="submit"
                disabled={createMutation.isPending || !formName.trim()}
                className="bg-purple-600 hover:bg-purple-700 text-white"
              >
                {createMutation.isPending ? 'Creating...' : 'Create Brand'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Edit Brand Dialog */}
      <Dialog open={isEditOpen} onOpenChange={setIsEditOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Edit Brand</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleEditSubmit} className="space-y-4 pt-2">
            <div className="space-y-1">
              <Label htmlFor="edit-brand-name">Brand Name *</Label>
              <Input
                id="edit-brand-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="Brand Name"
                required
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="edit-brand-logo">Brand Logo URL</Label>
              <Input
                id="edit-brand-logo"
                value={formLogo}
                onChange={(e) => setFormLogo(e.target.value)}
                placeholder="https://example.com/logo.png"
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="edit-brand-desc">Description</Label>
              <Input
                id="edit-brand-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Description..."
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="edit-brand-status">Status</Label>
              <Select value={formStatus} onValueChange={(val) => val && setFormStatus(val as 'ACTIVE' | 'INACTIVE')}>
                <SelectTrigger id="edit-brand-status" className="h-9">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ACTIVE">ACTIVE</SelectItem>
                  <SelectItem value="INACTIVE">INACTIVE</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <DialogFooter className="pt-2">
              <Button type="button" variant="outline" onClick={() => setIsEditOpen(false)}>
                Cancel
              </Button>

              <Button
                type="submit"
                disabled={updateMutation.isPending || !formName.trim()}
                className="bg-purple-600 hover:bg-purple-700 text-white"
              >
                {updateMutation.isPending ? 'Saving...' : 'Save Changes'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Reject Reason Dialog */}
      <Dialog open={!!rejectModalBrand} onOpenChange={(open) => !open && setRejectModalBrand(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Reject Brand Request</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleRejectSubmit} className="space-y-4 pt-2">
            <p className="text-xs text-zinc-500">
              You are rejecting the brand request for <strong>{rejectModalBrand?.name}</strong>. Please provide a reason for the vendor.
            </p>
            <div className="space-y-1">
              <Label htmlFor="reject-reason">Rejection Reason *</Label>
              <Input
                id="reject-reason"
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                placeholder="e.g. Invalid logo, trademark infringement, duplicate brand"
                required
              />
            </div>

            <DialogFooter className="pt-2">
              <Button type="button" variant="outline" onClick={() => setRejectModalBrand(null)}>
                Cancel
              </Button>
              <Button
                type="submit"
                disabled={rejectMutation.isPending || !rejectReason.trim()}
                className="bg-rose-600 hover:bg-rose-700 text-white"
              >
                {rejectMutation.isPending ? 'Rejecting...' : 'Confirm Rejection'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* View Brand Details Modal */}
      <Dialog open={!!detailModalBrand} onOpenChange={(open) => !open && setDetailModalBrand(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Brand Details</DialogTitle>
          </DialogHeader>
          {detailModalBrand && (
            <div className="space-y-4 pt-2 text-sm">
              <div className="flex items-center gap-4 p-4 bg-zinc-50 dark:bg-zinc-900/50 rounded-2xl border border-zinc-100 dark:border-zinc-800">
                {detailModalBrand.logo ? (
                  <img
                    src={detailModalBrand.logo}
                    alt={detailModalBrand.name}
                    className="h-16 w-16 rounded-xl object-contain border border-zinc-200 dark:border-zinc-800 bg-white p-1"
                  />
                ) : (
                  <div className="p-3 bg-purple-500/10 text-purple-500 rounded-xl">
                    <Tag className="h-8 w-8" />
                  </div>
                )}
                <div>
                  <h3 className="font-bold text-lg text-zinc-900 dark:text-zinc-50">{detailModalBrand.name}</h3>
                  <div className="mt-1">
                    <StatusBadge status={detailModalBrand.status} />
                  </div>
                </div>
              </div>

              <div className="space-y-2 text-xs">
                <div>
                  <span className="font-semibold text-zinc-500">Requested By Vendor:</span>{' '}
                  <span className="text-zinc-900 dark:text-zinc-100 font-medium">
                    {detailModalBrand.vendorName || detailModalBrand.vendor?.name || detailModalBrand.vendorEmail || 'System Admin'}
                  </span>
                </div>

                <div>
                  <span className="font-semibold text-zinc-500">Request Date:</span>{' '}
                  <span className="text-zinc-900 dark:text-zinc-100">
                    {formatDate(detailModalBrand.createdAt)}
                  </span>
                </div>

                {detailModalBrand.description && (
                  <div>
                    <span className="font-semibold text-zinc-500">Description:</span>
                    <p className="text-zinc-700 dark:text-zinc-300 mt-1 p-3 bg-zinc-50 dark:bg-zinc-900 rounded-xl border border-zinc-100 dark:border-zinc-800 leading-relaxed">
                      {detailModalBrand.description}
                    </p>
                  </div>
                )}

                {detailModalBrand.rejectedReason && (
                  <div>
                    <span className="font-semibold text-rose-500">Rejection Reason:</span>
                    <p className="text-rose-700 dark:text-rose-400 mt-1 p-3 bg-rose-50 dark:bg-rose-950/20 rounded-xl border border-rose-200 dark:border-rose-900 leading-relaxed">
                      {detailModalBrand.rejectedReason}
                    </p>
                  </div>
                )}
              </div>

              <DialogFooter className="pt-2">
                <Button variant="outline" onClick={() => setDetailModalBrand(null)}>
                  Close
                </Button>
              </DialogFooter>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
