'use client';

import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  FolderTree,
  Plus,
  Edit,
  Trash2,
  Power,
  Search,
  CheckSquare,
  Square,
  AlertCircle,
} from 'lucide-react';

import {
  getAdminCategories,
  createAdminCategory,
  updateAdminCategory,
  toggleCategoryStatus,
  bulkUpdateCategoryStatus,
  deleteAdminCategory,
  bulkDeleteCategories,
  Category,
} from '@/features/categories/api';
import { StatusBadge } from '@/components/StatusBadge';
import { MarketplacePagination } from '@/components/MarketplacePagination';
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

export default function CategoriesPage() {
  const queryClient = useQueryClient();

  // Filters & State
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');
  const [page, setPage] = useState(1);
  const limit = 10;

  // Selected rows for bulk actions
  const [selectedIds, setSelectedIds] = useState<string[]>([]);

  // Dialog States
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState<Category | null>(null);

  // Form State
  const [formName, setFormName] = useState('');
  const [formDesc, setFormDesc] = useState('');
  const [formImage, setFormImage] = useState('');
  const [formStatus, setFormStatus] = useState<'ACTIVE' | 'INACTIVE'>('ACTIVE');

  // Error Alert State for Delete Constraint Rule
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // Fetch Categories
  const { data: marketplaceData, isLoading } = useQuery({
    queryKey: ['adminCategories', statusFilter, search, page],
    queryFn: () =>
      getAdminCategories({
        status: statusFilter === 'ALL' ? undefined : statusFilter,
        search: search.trim() || undefined,
        page,
        limit,
      }),
  });

  const categories = marketplaceData?.items ?? [];

  // Mutations
  const createMutation = useMutation({
    mutationFn: createAdminCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminCategories'] });
      setIsCreateOpen(false);
      resetForm();
    },
    onError: (err: any) => {
      setErrorMessage(err?.response?.data?.message || 'Failed to create category.');
    },
  });

  const updateMutation = useMutation({
    mutationFn: updateAdminCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminCategories'] });
      setIsEditOpen(false);
      setEditingCategory(null);
      resetForm();
    },
    onError: (err: any) => {
      setErrorMessage(err?.response?.data?.message || 'Failed to update category.');
    },
  });

  const toggleStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) => toggleCategoryStatus(id, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminCategories'] });
    },
  });

  const bulkStatusMutation = useMutation({
    mutationFn: ({ ids, status }: { ids: string[]; status: 'ACTIVE' | 'INACTIVE' }) =>
      bulkUpdateCategoryStatus(ids, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminCategories'] });
      setSelectedIds([]);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: deleteAdminCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminCategories'] });
      setSelectedIds((prev) => prev.filter((id) => id !== editingCategory?.id));
    },
    onError: (err: any) => {
      const msg = err?.response?.data?.message || '';
      if (msg.toLowerCase().includes('sub-categories') || msg.toLowerCase().includes('contains')) {
        setErrorMessage('This Category contains Sub Categories. Remove or reassign them before deleting.');
      } else {
        setErrorMessage(msg || 'Failed to delete category.');
      }
    },
  });

  const bulkDeleteMutation = useMutation({
    mutationFn: bulkDeleteCategories,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminCategories'] });
      setSelectedIds([]);
    },
    onError: (err: any) => {
      const msg = err?.response?.data?.message || '';
      if (msg.toLowerCase().includes('sub-categories') || msg.toLowerCase().includes('contains')) {
        setErrorMessage('This Category contains Sub Categories. Remove or reassign them before deleting.');
      } else {
        setErrorMessage(msg || 'Failed to delete selected categories.');
      }
    },
  });

  const resetForm = () => {
    setFormName('');
    setFormDesc('');
    setFormImage('');
    setFormStatus('ACTIVE');
    setErrorMessage(null);
  };

  const handleOpenCreate = () => {
    resetForm();
    setIsCreateOpen(true);
  };

  const getCategoryStatus = (item: { status?: string; isActive?: boolean }) => {
    if (item.status) return item.status.toUpperCase();
    if (item.isActive === false) return 'INACTIVE';
    return 'ACTIVE';
  };

  const handleOpenEdit = (category: Category) => {
    setEditingCategory(category);
    setFormName(category.name);
    setFormDesc(category.description || '');
    setFormImage(category.image || '');
    setFormStatus(getCategoryStatus(category) === 'INACTIVE' ? 'INACTIVE' : 'ACTIVE');
    setIsEditOpen(true);
  };

  const handleCreateSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formName.trim()) return;
    createMutation.mutate({
      name: formName.trim(),
      description: formDesc.trim() || undefined,
      image: formImage.trim() || undefined,
      status: formStatus,
    });
  };

  const handleEditSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingCategory || !formName.trim()) return;
    updateMutation.mutate({
      id: editingCategory.id,
      data: {
        name: formName.trim(),
        description: formDesc.trim() || undefined,
        image: formImage.trim() || undefined,
        status: formStatus,
      },
    });
  };

  const handleDelete = (category: Category) => {
    if (confirm(`Are you sure you want to delete category "${category.name}"?`)) {
      setErrorMessage(null);
      deleteMutation.mutate(category.id);
    }
  };

  const handleToggleSelectAll = () => {
    if (selectedIds.length === categories.length) {
      setSelectedIds([]);
    } else {
      setSelectedIds(categories.map((c) => c.id));
    }
  };

  const handleToggleSelectRow = (id: string) => {
    if (selectedIds.includes(id)) {
      setSelectedIds(selectedIds.filter((item) => item !== id));
    } else {
      setSelectedIds([...selectedIds, id]);
    }
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
          <div className="p-3 bg-rose-500/10 text-rose-500 rounded-2xl">
            <FolderTree className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Master Categories Management
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              System Master Data. Admin-managed product categories across the marketplace.
            </p>
          </div>
        </div>

        <Button
          onClick={handleOpenCreate}
          className="gap-2 bg-rose-600 hover:bg-rose-700 text-white rounded-xl shadow-sm px-4 py-2 text-xs font-semibold"
        >
          <Plus className="h-4 w-4" />
          Create Category
        </Button>
      </div>

      {/* Error Constraint Alert Banner */}
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

      {/* Filter & Search Toolbar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 bg-white dark:bg-zinc-950 p-4 rounded-2xl border border-zinc-200/60 dark:border-zinc-800">
        <div className="relative w-full sm:w-72">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-zinc-400" />
          <Input
            placeholder="Search category name..."
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

      {/* Bulk Action Bar */}
      {selectedIds.length > 0 && (
        <div className="flex items-center justify-between p-3 px-4 rounded-2xl bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 shadow-lg animate-in fade-in slide-in-from-top-2">
          <span className="text-xs font-semibold">
            {selectedIds.length} Category{selectedIds.length > 1 ? 's' : ''} Selected
          </span>
          <div className="flex items-center gap-2">
            <Button
              size="sm"
              variant="secondary"
              onClick={() => bulkStatusMutation.mutate({ ids: selectedIds, status: 'ACTIVE' })}
              className="h-8 text-xs font-medium rounded-lg"
            >
              Activate Selected
            </Button>
            <Button
              size="sm"
              variant="secondary"
              onClick={() => bulkStatusMutation.mutate({ ids: selectedIds, status: 'INACTIVE' })}
              className="h-8 text-xs font-medium rounded-lg"
            >
              Deactivate Selected
            </Button>
            <Button
              size="sm"
              variant="destructive"
              onClick={() => {
                if (confirm(`Delete ${selectedIds.length} selected categories?`)) {
                  setErrorMessage(null);
                  bulkDeleteMutation.mutate(selectedIds);
                }
              }}
              className="h-8 text-xs font-medium rounded-lg"
            >
              Delete Selected
            </Button>
          </div>
        </div>
      )}

      {/* Table Component */}
      <div className="rounded-2xl border border-zinc-200/60 dark:border-zinc-800 bg-white dark:bg-zinc-950 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-zinc-50 dark:bg-zinc-900/50 text-zinc-500 text-xs font-semibold uppercase tracking-wider border-b border-zinc-200/60 dark:border-zinc-800">
              <tr>
                <th className="p-4 w-10">
                  <button onClick={handleToggleSelectAll} className="flex items-center">
                    {categories.length > 0 && selectedIds.length === categories.length ? (
                      <CheckSquare className="h-4 w-4 text-rose-500" />
                    ) : (
                      <Square className="h-4 w-4 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4">Category</th>
                <th className="p-4">Status</th>
                <th className="p-4">Products Count</th>
                <th className="p-4">Created Date</th>
                <th className="p-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100 dark:divide-zinc-900">
              {isLoading ? (
                Array.from({ length: 5 }).map((_, idx) => (
                  <tr key={idx} className="animate-pulse">
                    <td className="p-4" colSpan={6}>
                      <div className="h-8 bg-zinc-100 dark:bg-zinc-800 rounded-lg" />
                    </td>
                  </tr>
                ))
              ) : categories.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-8 text-center text-zinc-400">
                    No Categories Available
                  </td>
                </tr>
              ) : (
                categories.map((category) => {
                  const isSelected = selectedIds.includes(category.id);
                  const prodCount = category._count?.products ?? category.productsCount ?? 0;
                  const catStatus = getCategoryStatus(category);
                  const isActive = catStatus === 'ACTIVE';

                  return (
                    <tr
                      key={category.id}
                      className={`hover:bg-zinc-50/80 dark:hover:bg-zinc-900/30 transition-colors ${
                        isSelected ? 'bg-rose-500/5 dark:bg-rose-500/10' : ''
                      }`}
                    >
                      <td className="p-4">
                        <button onClick={() => handleToggleSelectRow(category.id)} className="flex items-center">
                          {isSelected ? (
                            <CheckSquare className="h-4 w-4 text-rose-500" />
                          ) : (
                            <Square className="h-4 w-4 text-zinc-300 dark:text-zinc-700" />
                          )}
                        </button>
                      </td>
                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          {category.image ? (
                            <img
                              src={category.image}
                              alt={category.name}
                              className="h-10 w-10 rounded-xl object-cover border border-zinc-200 dark:border-zinc-800"
                            />
                          ) : (
                            <div className="p-2.5 bg-rose-500/10 text-rose-500 rounded-xl">
                              <FolderTree className="h-5 w-5" />
                            </div>
                          )}
                          <div>
                            <p className="font-bold text-zinc-900 dark:text-zinc-100">{category.name}</p>
                            {category.description && (
                              <p className="text-xs text-zinc-400 truncate max-w-xs">{category.description}</p>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="p-4">
                        <StatusBadge status={catStatus} />
                      </td>
                      <td className="p-4 font-semibold text-zinc-700 dark:text-zinc-300">
                        {prodCount}
                      </td>
                      <td className="p-4 text-xs text-zinc-500">
                        {formatDate(category.createdAt)}
                      </td>
                      <td className="p-4 text-right">
                        <div className="flex items-center justify-end gap-2">
                          <Button
                            variant="outline"
                            size="sm"
                            title={isActive ? 'Deactivate Category' : 'Activate Category'}
                            onClick={() =>
                              toggleStatusMutation.mutate({ id: category.id, status: catStatus })
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
                            title="Edit Category"
                            onClick={() => handleOpenEdit(category)}
                            className="h-8 w-8 p-0 rounded-lg text-zinc-600 hover:text-zinc-900"
                          >
                            <Edit className="h-4 w-4" />
                          </Button>

                          <Button
                            variant="outline"
                            size="sm"
                            title="Delete Category"
                            onClick={() => handleDelete(category)}
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

      {/* Create Category Dialog */}
      <Dialog open={isCreateOpen} onOpenChange={setIsCreateOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Create Master Category</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleCreateSubmit} className="space-y-4 pt-2">
            <div className="space-y-1">
              <Label htmlFor="create-name">Category Name *</Label>
              <Input
                id="create-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="e.g. Fashion, Electronics"
                required
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="create-desc">Description</Label>
              <Input
                id="create-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Category description..."
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="create-image">Category Image URL</Label>
              <Input
                id="create-image"
                value={formImage}
                onChange={(e) => setFormImage(e.target.value)}
                placeholder="https://example.com/image.jpg"
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="create-status">Initial Status</Label>
              <Select value={formStatus} onValueChange={(val) => val && setFormStatus(val as 'ACTIVE' | 'INACTIVE')}>
                <SelectTrigger id="create-status" className="h-9">
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
                className="bg-rose-600 hover:bg-rose-700 text-white"
              >
                {createMutation.isPending ? 'Creating...' : 'Create Category'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Edit Category Dialog */}
      <Dialog open={isEditOpen} onOpenChange={setIsEditOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Edit Category</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleEditSubmit} className="space-y-4 pt-2">
            <div className="space-y-1">
              <Label htmlFor="edit-name">Category Name *</Label>
              <Input
                id="edit-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="Category Name"
                required
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="edit-desc">Description</Label>
              <Input
                id="edit-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Description..."
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="edit-image">Category Image URL</Label>
              <Input
                id="edit-image"
                value={formImage}
                onChange={(e) => setFormImage(e.target.value)}
                placeholder="https://example.com/image.jpg"
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="edit-status">Status</Label>
              <Select value={formStatus} onValueChange={(val) => val && setFormStatus(val as 'ACTIVE' | 'INACTIVE')}>
                <SelectTrigger id="edit-status" className="h-9">
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
                className="bg-rose-600 hover:bg-rose-700 text-white"
              >
                {updateMutation.isPending ? 'Saving...' : 'Save Changes'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
