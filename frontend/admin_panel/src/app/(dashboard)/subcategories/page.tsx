'use client';

import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  FolderGit2,
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
  getAdminSubCategories,
  createAdminSubCategory,
  updateAdminSubCategory,
  toggleSubCategoryStatus,
  bulkUpdateSubCategoryStatus,
  deleteAdminSubCategory,
  bulkDeleteSubCategories,
  SubCategory,
} from '@/features/subcategories/api';
import { getAdminCategories, Category } from '@/features/categories/api';
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

export default function SubCategoriesPage() {
  const queryClient = useQueryClient();

  // Filters & State
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');
  const [categoryFilter, setCategoryFilter] = useState<string>('ALL');
  const [page, setPage] = useState(1);
  const limit = 10;

  // Selected rows for bulk actions
  const [selectedIds, setSelectedIds] = useState<string[]>([]);

  // Dialog States
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [editingSubCategory, setEditingSubCategory] = useState<SubCategory | null>(null);

  // Form State
  const [formCategoryId, setFormCategoryId] = useState('');
  const [formName, setFormName] = useState('');
  const [formDesc, setFormDesc] = useState('');
  const [formImage, setFormImage] = useState('');
  const [formStatus, setFormStatus] = useState<'ACTIVE' | 'INACTIVE'>('ACTIVE');

  // Error Alert State for Delete Constraint Rule
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // Fetch Parent Categories for dropdown & filter
  const { data: categoriesData } = useQuery({
    queryKey: ['adminCategories', 'dropdown'],
    queryFn: () => getAdminCategories({ limit: 100 }),
  });

  const parentCategories: Category[] = categoriesData?.items ?? [];

  // Fetch Sub Categories
  const { data: marketplaceData, isLoading } = useQuery({
    queryKey: ['adminSubCategories', statusFilter, categoryFilter, search, page],
    queryFn: () =>
      getAdminSubCategories({
        status: statusFilter === 'ALL' ? undefined : statusFilter,
        categoryId: categoryFilter === 'ALL' ? undefined : categoryFilter,
        search: search.trim() || undefined,
        page,
        limit,
      }),
  });

  const subCategories = marketplaceData?.items ?? [];

  // Mutations
  const createMutation = useMutation({
    mutationFn: createAdminSubCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminSubCategories'] });
      setIsCreateOpen(false);
      resetForm();
    },
    onError: (err: any) => {
      setErrorMessage(err?.response?.data?.message || 'Failed to create sub category.');
    },
  });

  const updateMutation = useMutation({
    mutationFn: updateAdminSubCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminSubCategories'] });
      setIsEditOpen(false);
      setEditingSubCategory(null);
      resetForm();
    },
    onError: (err: any) => {
      setErrorMessage(err?.response?.data?.message || 'Failed to update sub category.');
    },
  });

  const toggleStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) => toggleSubCategoryStatus(id, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminSubCategories'] });
    },
  });

  const bulkStatusMutation = useMutation({
    mutationFn: ({ ids, status }: { ids: string[]; status: 'ACTIVE' | 'INACTIVE' }) =>
      bulkUpdateSubCategoryStatus(ids, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminSubCategories'] });
      setSelectedIds([]);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: deleteAdminSubCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminSubCategories'] });
      setSelectedIds((prev) => prev.filter((id) => id !== editingSubCategory?.id));
    },
    onError: (err: any) => {
      const msg = err?.response?.data?.message || '';
      if (msg.toLowerCase().includes('products') || msg.toLowerCase().includes('used')) {
        setErrorMessage('This Sub Category is being used by Products.');
      } else {
        setErrorMessage(msg || 'Failed to delete sub category.');
      }
    },
  });

  const bulkDeleteMutation = useMutation({
    mutationFn: bulkDeleteSubCategories,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminSubCategories'] });
      setSelectedIds([]);
    },
    onError: (err: any) => {
      const msg = err?.response?.data?.message || '';
      if (msg.toLowerCase().includes('products') || msg.toLowerCase().includes('used')) {
        setErrorMessage('This Sub Category is being used by Products.');
      } else {
        setErrorMessage(msg || 'Failed to delete selected sub categories.');
      }
    },
  });

  const resetForm = () => {
    setFormCategoryId('');
    setFormName('');
    setFormDesc('');
    setFormImage('');
    setFormStatus('ACTIVE');
    setErrorMessage(null);
  };

  const handleOpenCreate = () => {
    resetForm();
    if (parentCategories.length > 0) {
      setFormCategoryId(parentCategories[0].id);
    }
    setIsCreateOpen(true);
  };

  const getSubCategoryStatus = (item: { status?: string; isActive?: boolean }) => {
    if (item.status) return item.status.toUpperCase();
    if (item.isActive === false) return 'INACTIVE';
    return 'ACTIVE';
  };

  const handleOpenEdit = (subCategory: SubCategory) => {
    setEditingSubCategory(subCategory);
    setFormCategoryId(subCategory.categoryId || subCategory.category?.id || '');
    setFormName(subCategory.name);
    setFormDesc(subCategory.description || '');
    setFormImage(subCategory.image || '');
    setFormStatus(getSubCategoryStatus(subCategory) === 'INACTIVE' ? 'INACTIVE' : 'ACTIVE');
    setIsEditOpen(true);
  };

  const handleCreateSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formCategoryId || !formName.trim()) return;
    createMutation.mutate({
      categoryId: formCategoryId,
      name: formName.trim(),
      description: formDesc.trim() || undefined,
      image: formImage.trim() || undefined,
      status: formStatus,
    });
  };

  const handleEditSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingSubCategory || !formCategoryId || !formName.trim()) return;
    updateMutation.mutate({
      id: editingSubCategory.id,
      data: {
        categoryId: formCategoryId,
        name: formName.trim(),
        description: formDesc.trim() || undefined,
        image: formImage.trim() || undefined,
        status: formStatus,
      },
    });
  };

  const handleDelete = (subCategory: SubCategory) => {
    if (confirm(`Are you sure you want to delete sub category "${subCategory.name}"?`)) {
      setErrorMessage(null);
      deleteMutation.mutate(subCategory.id);
    }
  };

  const handleToggleSelectAll = () => {
    if (selectedIds.length === subCategories.length) {
      setSelectedIds([]);
    } else {
      setSelectedIds(subCategories.map((sc) => sc.id));
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
          <div className="p-3 bg-purple-500/10 text-purple-500 rounded-2xl">
            <FolderGit2 className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Master Sub Categories Management
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              System Master Data. Admin-managed subcategories linked to Parent Categories.
            </p>
          </div>
        </div>

        <Button
          onClick={handleOpenCreate}
          className="gap-2 bg-purple-600 hover:bg-purple-700 text-white rounded-xl shadow-sm px-4 py-2 text-xs font-semibold"
        >
          <Plus className="h-4 w-4" />
          Create Sub Category
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
            placeholder="Search sub category name..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
            className="pl-9 h-9 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs"
          />
        </div>

        <div className="flex items-center gap-3 w-full sm:w-auto">
          {/* Parent Category Filter */}
          <Select
            value={categoryFilter}
            onValueChange={(val) => {
              if (val) setCategoryFilter(val);
              setPage(1);
            }}
          >
            <SelectTrigger className="w-[180px] h-9 rounded-xl text-xs border-zinc-200 dark:border-zinc-800">
              <SelectValue placeholder="All Parent Categories" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">All Categories</SelectItem>
              {parentCategories.map((cat) => (
                <SelectItem key={cat.id} value={cat.id}>
                  {cat.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          {/* Status Filter */}
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
            {selectedIds.length} Sub Category{selectedIds.length > 1 ? 's' : ''} Selected
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
                if (confirm(`Delete ${selectedIds.length} selected sub categories?`)) {
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
                    {subCategories.length > 0 && selectedIds.length === subCategories.length ? (
                      <CheckSquare className="h-4 w-4 text-purple-500" />
                    ) : (
                      <Square className="h-4 w-4 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4">Category</th>
                <th className="p-4">Sub Category Name</th>
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
                    <td className="p-4" colSpan={7}>
                      <div className="h-8 bg-zinc-100 dark:bg-zinc-800 rounded-lg" />
                    </td>
                  </tr>
                ))
              ) : subCategories.length === 0 ? (
                <tr>
                  <td colSpan={7} className="p-8 text-center text-zinc-400">
                    No Sub Categories Available
                  </td>
                </tr>
              ) : (
                subCategories.map((subCategory) => {
                  const isSelected = selectedIds.includes(subCategory.id);
                  const prodCount = subCategory._count?.products ?? subCategory.productsCount ?? 0;
                  const scStatus = getSubCategoryStatus(subCategory);
                  const isActive = scStatus === 'ACTIVE';
                  const parentName =
                    subCategory.category?.name ||
                    parentCategories.find((c) => c.id === subCategory.categoryId)?.name ||
                    'N/A';

                  return (
                    <tr
                      key={subCategory.id}
                      className={`hover:bg-zinc-50/80 dark:hover:bg-zinc-900/30 transition-colors ${
                        isSelected ? 'bg-purple-500/5 dark:bg-purple-500/10' : ''
                      }`}
                    >
                      <td className="p-4">
                        <button onClick={() => handleToggleSelectRow(subCategory.id)} className="flex items-center">
                          {isSelected ? (
                            <CheckSquare className="h-4 w-4 text-purple-500" />
                          ) : (
                            <Square className="h-4 w-4 text-zinc-300 dark:text-zinc-700" />
                          )}
                        </button>
                      </td>
                      <td className="p-4 font-semibold text-rose-600 dark:text-rose-400 text-xs">
                        {parentName}
                      </td>
                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          {subCategory.image ? (
                            <img
                              src={subCategory.image}
                              alt={subCategory.name}
                              className="h-9 w-9 rounded-xl object-cover border border-zinc-200 dark:border-zinc-800"
                            />
                          ) : (
                            <div className="p-2 bg-purple-500/10 text-purple-500 rounded-xl">
                              <FolderGit2 className="h-4 w-4" />
                            </div>
                          )}
                          <div>
                            <p className="font-bold text-zinc-900 dark:text-zinc-100">{subCategory.name}</p>
                            {subCategory.description && (
                              <p className="text-xs text-zinc-400 truncate max-w-xs">{subCategory.description}</p>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="p-4">
                        <StatusBadge status={scStatus} />
                      </td>
                      <td className="p-4 font-semibold text-zinc-700 dark:text-zinc-300">
                        {prodCount}
                      </td>
                      <td className="p-4 text-xs text-zinc-500">
                        {formatDate(subCategory.createdAt)}
                      </td>
                      <td className="p-4 text-right">
                        <div className="flex items-center justify-end gap-2">
                          <Button
                            variant="outline"
                            size="sm"
                            title={isActive ? 'Deactivate Sub Category' : 'Activate Sub Category'}
                            onClick={() =>
                              toggleStatusMutation.mutate({ id: subCategory.id, status: scStatus })
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
                            title="Edit Sub Category"
                            onClick={() => handleOpenEdit(subCategory)}
                            className="h-8 w-8 p-0 rounded-lg text-zinc-600 hover:text-zinc-900"
                          >
                            <Edit className="h-4 w-4" />
                          </Button>

                          <Button
                            variant="outline"
                            size="sm"
                            title="Delete Sub Category"
                            onClick={() => handleDelete(subCategory)}
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

      {/* Create Sub Category Dialog */}
      <Dialog open={isCreateOpen} onOpenChange={setIsCreateOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Create Master Sub Category</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleCreateSubmit} className="space-y-4 pt-2">
            <div className="space-y-1">
              <Label htmlFor="create-parent">Parent Category *</Label>
              <Select value={formCategoryId} onValueChange={(val) => val && setFormCategoryId(val)} required>
                <SelectTrigger id="create-parent" className="h-9">
                  <SelectValue placeholder="Select Parent Category" />
                </SelectTrigger>
                <SelectContent>
                  {parentCategories.map((cat) => (
                    <SelectItem key={cat.id} value={cat.id}>
                      {cat.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-1">
              <Label htmlFor="create-sub-name">Sub Category Name *</Label>
              <Input
                id="create-sub-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="e.g. Women's Clothing, Mobiles"
                required
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="create-sub-desc">Description</Label>
              <Input
                id="create-sub-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Sub Category description..."
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="create-sub-status">Initial Status</Label>
              <Select value={formStatus} onValueChange={(val) => val && setFormStatus(val as 'ACTIVE' | 'INACTIVE')}>
                <SelectTrigger id="create-sub-status" className="h-9">
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
                disabled={createMutation.isPending || !formName.trim() || !formCategoryId}
                className="bg-purple-600 hover:bg-purple-700 text-white"
              >
                {createMutation.isPending ? 'Creating...' : 'Create Sub Category'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Edit Sub Category Dialog */}
      <Dialog open={isEditOpen} onOpenChange={setIsEditOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Edit Sub Category</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleEditSubmit} className="space-y-4 pt-2">
            <div className="space-y-1">
              <Label htmlFor="edit-parent">Parent Category *</Label>
              <Select value={formCategoryId} onValueChange={(val) => val && setFormCategoryId(val)} required>
                <SelectTrigger id="edit-parent" className="h-9">
                  <SelectValue placeholder="Select Parent Category" />
                </SelectTrigger>
                <SelectContent>
                  {parentCategories.map((cat) => (
                    <SelectItem key={cat.id} value={cat.id}>
                      {cat.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-1">
              <Label htmlFor="edit-sub-name">Sub Category Name *</Label>
              <Input
                id="edit-sub-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="Sub Category Name"
                required
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="edit-sub-desc">Description</Label>
              <Input
                id="edit-sub-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Description..."
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="edit-sub-status">Status</Label>
              <Select value={formStatus} onValueChange={(val) => val && setFormStatus(val as 'ACTIVE' | 'INACTIVE')}>
                <SelectTrigger id="edit-sub-status" className="h-9">
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
                disabled={updateMutation.isPending || !formName.trim() || !formCategoryId}
                className="bg-purple-600 hover:bg-purple-700 text-white"
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
