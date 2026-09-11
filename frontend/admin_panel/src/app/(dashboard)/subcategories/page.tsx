'use client';

import React, { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  FolderGit2,
  Plus,
  Eye,
  Edit,
  Trash2,
  Power,
  Search,
  CheckSquare,
  Square,
  AlertCircle,
  ArrowUpDown,
  ArrowUp,
  ArrowDown,
  Inbox,
  FolderTree,
} from 'lucide-react';
import { toast } from 'sonner';

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

export default function SubCategoriesPage() {
  const queryClient = useQueryClient();

  // Filters & State
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');
  const [categoryFilter, setCategoryFilter] = useState<string>('ALL');
  const [page, setPage] = useState(1);
  const limit = 10;

  // Sorting
  const [sortField, setSortField] = useState<'name' | 'category' | 'createdAt' | 'prodCount'>('createdAt');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Selected rows for bulk actions
  const [selectedIds, setSelectedIds] = useState<string[]>([]);

  // Dialog States
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [editingSubCategory, setEditingSubCategory] = useState<SubCategory | null>(null);
  const [viewingSubCategory, setViewingSubCategory] = useState<SubCategory | null>(null);

  // Confirm Dialog State
  const [deleteTarget, setDeleteTarget] = useState<SubCategory | null>(null);
  const [isBulkDeleteOpen, setIsBulkDeleteOpen] = useState(false);

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

  // Client-side Sorting
  const sortedSubCategories = useMemo(() => {
    if (!subCategories) return [];
    return [...subCategories].sort((a, b) => {
      let aVal: any = a[sortField as keyof SubCategory];
      let bVal: any = b[sortField as keyof SubCategory];

      if (sortField === 'category') {
        aVal = a.category?.name || '';
        bVal = b.category?.name || '';
      } else if (sortField === 'prodCount') {
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
  }, [subCategories, sortField, sortDirection]);

  const handleSort = (field: 'name' | 'category' | 'createdAt' | 'prodCount') => {
    if (sortField === field) {
      setSortDirection((prev) => (prev === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortField(field);
      setSortDirection('asc');
    }
  };

  // Mutations
  const createMutation = useMutation({
    mutationFn: createAdminSubCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminSubCategories'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setIsCreateOpen(false);
      resetForm();
      toast.success('Subcategory created successfully');
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
      toast.success('Subcategory updated successfully');
    },
    onError: (err: any) => {
      setErrorMessage(err?.response?.data?.message || 'Failed to update sub category.');
    },
  });

  const toggleStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) => toggleSubCategoryStatus(id, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminSubCategories'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      toast.success('Subcategory status updated');
    },
  });

  const bulkStatusMutation = useMutation({
    mutationFn: ({ ids, status }: { ids: string[]; status: 'ACTIVE' | 'INACTIVE' }) =>
      bulkUpdateSubCategoryStatus(ids, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminSubCategories'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setSelectedIds([]);
      toast.success('Selected subcategories updated');
    },
  });

  const deleteMutation = useMutation({
    mutationFn: deleteAdminSubCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminSubCategories'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setSelectedIds((prev) => prev.filter((id) => id !== deleteTarget?.id));
      setDeleteTarget(null);
      toast.success('Subcategory deleted successfully');
    },
    onError: (err: any) => {
      const msg = err?.response?.data?.message || '';
      if (msg.toLowerCase().includes('product')) {
        setErrorMessage('This Sub Category contains Products. Remove or reassign them before deleting.');
      } else {
        setErrorMessage(msg || 'Failed to delete sub category.');
      }
      setDeleteTarget(null);
    },
  });

  const bulkDeleteMutation = useMutation({
    mutationFn: bulkDeleteSubCategories,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminSubCategories'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setSelectedIds([]);
      setIsBulkDeleteOpen(false);
      toast.success('Selected subcategories deleted successfully');
    },
    onError: (err: any) => {
      const msg = err?.response?.data?.message || '';
      if (msg.toLowerCase().includes('product')) {
        setErrorMessage('One or more selected Sub Categories contain Products.');
      } else {
        setErrorMessage(msg || 'Failed to delete selected sub categories.');
      }
      setIsBulkDeleteOpen(false);
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

  const handleOpenEdit = (subCat: SubCategory) => {
    setEditingSubCategory(subCat);
    setFormCategoryId(subCat.categoryId || (subCat as any).category?.id || '');
    setFormName(subCat.name);
    setFormDesc(subCat.description || '');
    setFormImage(subCat.image || '');
    setFormStatus(getSubCategoryStatus(subCat) === 'INACTIVE' ? 'INACTIVE' : 'ACTIVE');
    setIsEditOpen(true);
  };

  const handleCreateSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formName.trim() || !formCategoryId) return;
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
    if (!editingSubCategory || !formName.trim() || !formCategoryId) return;
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

  const handleToggleSelectAll = () => {
    if (selectedIds.length === subCategories.length) {
      setSelectedIds([]);
    } else {
      setSelectedIds(subCategories.map((c) => c.id));
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
      return new Date(dateStr).toLocaleDateString('en-IN', {
        year: 'numeric',
        month: 'short',
        day: '2-digit',
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
          <div className="p-3 bg-purple-500/10 text-purple-600 dark:bg-purple-500/20 dark:text-purple-400 rounded-2xl">
            <FolderGit2 className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Sub Categories
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              Nested category classification and sub-tree navigation.
            </p>
          </div>
        </div>

        <Button
          onClick={handleOpenCreate}
          className="gap-2 bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl shadow-xs px-4 py-2 text-xs font-semibold"
        >
          <Plus className="h-4 w-4" />
          Create Sub Category
        </Button>
      </div>

      {/* Error Constraint Alert Banner */}
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

      {/* Filter & Search Toolbar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-3 bg-white dark:bg-zinc-950 p-4 rounded-2xl border border-zinc-200/80 dark:border-zinc-800 shadow-2xs">
        <div className="relative w-full sm:w-80">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-zinc-400" />
          <Input
            placeholder="Search subcategory name..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
            className="pl-9 h-9 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs"
          />
        </div>

        <div className="flex flex-wrap items-center gap-3 w-full sm:w-auto">
          <Select
            value={categoryFilter}
            onValueChange={(val) => {
              if (val) setCategoryFilter(val);
              setPage(1);
            }}
          >
            <SelectTrigger className="w-[170px] h-9 rounded-xl text-xs border-zinc-200 dark:border-zinc-800">
              <SelectValue placeholder="All Categories" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">All Categories</SelectItem>
              {parentCategories.map((c) => (
                <SelectItem key={c.id} value={c.id}>
                  {c.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          <Select
            value={statusFilter}
            onValueChange={(val) => {
              if (val) setStatusFilter(val);
              setPage(1);
            }}
          >
            <SelectTrigger className="w-[130px] h-9 rounded-xl text-xs border-zinc-200 dark:border-zinc-800">
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
              className="h-8 text-xs font-medium rounded-xl"
            >
              Activate
            </Button>
            <Button
              size="sm"
              variant="secondary"
              onClick={() => bulkStatusMutation.mutate({ ids: selectedIds, status: 'INACTIVE' })}
              className="h-8 text-xs font-medium rounded-xl"
            >
              Deactivate
            </Button>
            <Button
              size="sm"
              variant="destructive"
              onClick={() => setIsBulkDeleteOpen(true)}
              className="h-8 text-xs font-medium rounded-xl"
            >
              Delete
            </Button>
          </div>
        </div>
      )}

      {/* Table */}
      <div className="rounded-2xl border border-zinc-200/80 dark:border-zinc-800 bg-white dark:bg-zinc-950 overflow-hidden shadow-2xs">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-zinc-50/90 dark:bg-zinc-900/90 text-zinc-500 dark:text-zinc-400 text-xs font-bold uppercase tracking-wider border-b border-zinc-200/80 dark:border-zinc-800">
              <tr>
                <th className="p-4 w-10">
                  <button onClick={handleToggleSelectAll} className="flex items-center cursor-pointer">
                    {subCategories.length > 0 && selectedIds.length === subCategories.length ? (
                      <CheckSquare className="h-4 w-4 text-emerald-600" />
                    ) : (
                      <Square className="h-4 w-4 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4">
                  <button
                    onClick={() => handleSort('name')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Sub Category</span>
                    {sortField === 'name' ? (
                      sortDirection === 'asc' ? <ArrowUp className="h-3.5 w-3.5 text-emerald-600" /> : <ArrowDown className="h-3.5 w-3.5 text-emerald-600" />
                    ) : (
                      <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4">
                  <button
                    onClick={() => handleSort('category')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Parent Category</span>
                    {sortField === 'category' ? (
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
              {isLoading ? (
                Array.from({ length: 6 }).map((_, idx) => (
                  <tr key={idx} className="animate-pulse">
                    <td className="p-4" colSpan={7}>
                      <div className="h-7 bg-zinc-100 dark:bg-zinc-800 rounded-xl" />
                    </td>
                  </tr>
                ))
              ) : sortedSubCategories.length === 0 ? (
                <tr>
                  <td colSpan={7} className="p-12 text-center">
                    <div className="flex flex-col items-center justify-center space-y-2">
                      <div className="p-3 bg-zinc-100 dark:bg-zinc-850 rounded-full text-zinc-400">
                        <Inbox className="h-8 w-8" />
                      </div>
                      <p className="text-sm font-semibold text-zinc-800 dark:text-zinc-200">
                        No Sub Categories Found
                      </p>
                      <p className="text-xs text-zinc-400 max-w-sm">
                        Try adjusting your category filter or search keywords.
                      </p>
                    </div>
                  </td>
                </tr>
              ) : (
                sortedSubCategories.map((subCat) => {
                  const isSelected = selectedIds.includes(subCat.id);
                  const prodCount = subCat._count?.products ?? subCat.productsCount ?? 0;
                  const catStatus = getSubCategoryStatus(subCat);
                  const isActive = catStatus === 'ACTIVE';

                  return (
                    <tr
                      key={subCat.id}
                      className={`hover:bg-zinc-50/80 dark:hover:bg-zinc-900/40 transition-colors ${
                        isSelected ? 'bg-emerald-500/5 dark:bg-emerald-500/10' : ''
                      }`}
                    >
                      <td className="p-4">
                        <button
                          onClick={() => handleToggleSelectRow(subCat.id)}
                          className="flex items-center cursor-pointer"
                        >
                          {isSelected ? (
                            <CheckSquare className="h-4 w-4 text-emerald-600" />
                          ) : (
                            <Square className="h-4 w-4 text-zinc-300 dark:text-zinc-700" />
                          )}
                        </button>
                      </td>
                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          {subCat.image ? (
                            <img
                              src={subCat.image}
                              alt={subCat.name}
                              className="h-10 w-10 rounded-xl object-cover border border-zinc-200 dark:border-zinc-800"
                            />
                          ) : (
                            <div className="p-2.5 bg-purple-500/10 text-purple-600 dark:bg-purple-500/20 dark:text-purple-400 rounded-xl">
                              <FolderGit2 className="h-5 w-5" />
                            </div>
                          )}
                          <div>
                            <p className="font-bold text-zinc-900 dark:text-zinc-100">{subCat.name}</p>
                            {subCat.description && (
                              <p className="text-xs text-zinc-400 truncate max-w-xs">{subCat.description}</p>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="p-4">
                        <span className="inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-semibold bg-zinc-100 dark:bg-zinc-850 text-zinc-700 dark:text-zinc-300">
                          {subCat.category?.name || 'Unassigned'}
                        </span>
                      </td>
                      <td className="p-4">
                        <StatusBadge status={catStatus} />
                      </td>
                      <td className="p-4 font-semibold text-zinc-700 dark:text-zinc-300">
                        {prodCount}
                      </td>
                      <td className="p-4 text-xs text-zinc-500">
                        {formatDate(subCat.createdAt)}
                      </td>
                      <td className="p-4 text-right">
                        <div className="flex items-center justify-end gap-1.5">
                          <Button
                            variant="outline"
                            size="sm"
                            title="View Subcategory Details"
                            onClick={() => setViewingSubCategory(subCat)}
                            className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                          >
                            <Eye className="h-3.5 w-3.5 text-zinc-500" />
                            View
                          </Button>

                          <Button
                            variant="outline"
                            size="sm"
                            title={isActive ? 'Deactivate Subcategory' : 'Activate Subcategory'}
                            onClick={() =>
                              toggleStatusMutation.mutate({ id: subCat.id, status: catStatus })
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
                            title="Edit Subcategory"
                            onClick={() => handleOpenEdit(subCat)}
                            className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                          >
                            <Edit className="h-3.5 w-3.5 text-blue-500" />
                            Edit
                          </Button>

                          <Button
                            variant="outline"
                            size="sm"
                            title="Delete Subcategory"
                            onClick={() => setDeleteTarget(subCat)}
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

      {/* View Detail Modal */}
      <Dialog open={!!viewingSubCategory} onOpenChange={(open) => !open && setViewingSubCategory(null)}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold flex items-center gap-2">
              <FolderGit2 className="h-5 w-5 text-purple-500" />
              Sub Category Details
            </DialogTitle>
          </DialogHeader>

          {viewingSubCategory && (
            <div className="space-y-4 pt-2 text-xs">
              {viewingSubCategory.image && (
                <div className="rounded-xl overflow-hidden border border-zinc-200 dark:border-zinc-800 max-h-48 bg-zinc-50 dark:bg-zinc-900 flex items-center justify-center">
                  <img
                    src={viewingSubCategory.image}
                    alt={viewingSubCategory.name}
                    className="object-contain max-h-48 w-full"
                  />
                </div>
              )}

              <div className="grid grid-cols-2 gap-3 p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800">
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Sub Category Name</span>
                  <span className="font-bold text-zinc-900 dark:text-zinc-100 text-sm">
                    {viewingSubCategory.name}
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Parent Category</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {viewingSubCategory.category?.name || 'Unassigned'}
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Status</span>
                  <div className="mt-0.5">
                    <StatusBadge status={getSubCategoryStatus(viewingSubCategory)} />
                  </div>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Products Count</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {viewingSubCategory._count?.products ?? viewingSubCategory.productsCount ?? 0}
                  </span>
                </div>
                <div className="col-span-2">
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Created Date</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {formatDate(viewingSubCategory.createdAt)}
                  </span>
                </div>
              </div>

              {viewingSubCategory.description && (
                <div className="space-y-1">
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Description</span>
                  <p className="text-zinc-600 dark:text-zinc-400 leading-relaxed bg-zinc-50 dark:bg-zinc-900 p-3 rounded-xl border border-zinc-100 dark:border-zinc-800">
                    {viewingSubCategory.description}
                  </p>
                </div>
              )}

              <DialogFooter className="pt-2">
                <Button
                  variant="outline"
                  onClick={() => setViewingSubCategory(null)}
                  className="rounded-xl h-9 text-xs font-semibold"
                >
                  Close
                </Button>
                <Button
                  onClick={() => {
                    const c = viewingSubCategory;
                    setViewingSubCategory(null);
                    handleOpenEdit(c);
                  }}
                  className="rounded-xl h-9 text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs"
                >
                  <Edit className="h-3.5 w-3.5 mr-1.5" />
                  Edit Sub Category
                </Button>
              </DialogFooter>
            </div>
          )}
        </DialogContent>
      </Dialog>

      {/* Create Sub Category Dialog */}
      <Dialog open={isCreateOpen} onOpenChange={setIsCreateOpen}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold">Create Sub Category</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleCreateSubmit} className="space-y-4 pt-2">
            <div className="space-y-1.5">
              <Label htmlFor="create-parent" className="text-xs font-bold">Parent Category *</Label>
              <Select value={formCategoryId} onValueChange={(val) => { if (val) setFormCategoryId(val); }} required>
                <SelectTrigger id="create-parent" className="h-9 rounded-xl text-xs">
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

            <div className="space-y-1.5">
              <Label htmlFor="create-sub-name" className="text-xs font-bold">Sub Category Name *</Label>
              <Input
                id="create-sub-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="e.g. Smart Phones, T-Shirts"
                className="rounded-xl h-9 text-xs"
                required
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="create-sub-desc" className="text-xs font-bold">Description</Label>
              <Input
                id="create-sub-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Sub category description..."
                className="rounded-xl h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="create-sub-image" className="text-xs font-bold">Image URL</Label>
              <Input
                id="create-sub-image"
                value={formImage}
                onChange={(e) => setFormImage(e.target.value)}
                placeholder="https://example.com/sub-image.jpg"
                className="rounded-xl h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="create-sub-status" className="text-xs font-bold">Status</Label>
              <Select value={formStatus} onValueChange={(val) => val && setFormStatus(val as 'ACTIVE' | 'INACTIVE')}>
                <SelectTrigger id="create-sub-status" className="h-9 rounded-xl text-xs">
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
                disabled={createMutation.isPending || !formName.trim() || !formCategoryId}
                className="bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl h-9 text-xs font-semibold"
              >
                {createMutation.isPending ? 'Creating...' : 'Create Sub Category'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Edit Sub Category Dialog */}
      <Dialog open={isEditOpen} onOpenChange={setIsEditOpen}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold">Edit Sub Category</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleEditSubmit} className="space-y-4 pt-2">
            <div className="space-y-1.5">
              <Label htmlFor="edit-parent" className="text-xs font-bold">Parent Category *</Label>
              <Select value={formCategoryId} onValueChange={(val) => { if (val) setFormCategoryId(val); }} required>
                <SelectTrigger id="edit-parent" className="h-9 rounded-xl text-xs">
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

            <div className="space-y-1.5">
              <Label htmlFor="edit-sub-name" className="text-xs font-bold">Sub Category Name *</Label>
              <Input
                id="edit-sub-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="Sub Category Name"
                className="rounded-xl h-9 text-xs"
                required
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="edit-sub-desc" className="text-xs font-bold">Description</Label>
              <Input
                id="edit-sub-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Description..."
                className="rounded-xl h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="edit-sub-image" className="text-xs font-bold">Image URL</Label>
              <Input
                id="edit-sub-image"
                value={formImage}
                onChange={(e) => setFormImage(e.target.value)}
                placeholder="https://example.com/image.jpg"
                className="rounded-xl h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="edit-sub-status" className="text-xs font-bold">Status</Label>
              <Select value={formStatus} onValueChange={(val) => val && setFormStatus(val as 'ACTIVE' | 'INACTIVE')}>
                <SelectTrigger id="edit-sub-status" className="h-9 rounded-xl text-xs">
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
                disabled={updateMutation.isPending || !formName.trim() || !formCategoryId}
                className="bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl h-9 text-xs font-semibold"
              >
                {updateMutation.isPending ? 'Saving...' : 'Save Changes'}
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
        title="Delete Sub Category"
        description={
          deleteTarget ? (
            <span>
              Are you sure you want to delete subcategory <strong>&quot;{deleteTarget.name}&quot;</strong>? This action cannot be undone if products are linked.
            </span>
          ) : undefined
        }
        confirmText="Delete Sub Category"
        variant="destructive"
        isLoading={deleteMutation.isPending}
      />

      {/* Bulk Delete Confirmation Dialog */}
      <ConfirmDialog
        open={isBulkDeleteOpen}
        onClose={() => setIsBulkDeleteOpen(false)}
        onConfirm={() => bulkDeleteMutation.mutate(selectedIds)}
        title="Delete Selected Sub Categories"
        description={`Are you sure you want to delete ${selectedIds.length} selected sub categories?`}
        confirmText="Delete Selected"
        variant="destructive"
        isLoading={bulkDeleteMutation.isPending}
      />
    </div>
  );
}
