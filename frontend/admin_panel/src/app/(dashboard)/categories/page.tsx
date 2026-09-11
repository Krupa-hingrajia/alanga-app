'use client';

import React, { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  FolderTree,
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
  Calendar,
  Layers,
  Inbox,
  Sparkles,
} from 'lucide-react';
import { toast } from 'sonner';

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

export default function CategoriesPage() {
  const queryClient = useQueryClient();

  // Filters & Pagination
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');
  const [page, setPage] = useState(1);
  const limit = 10;

  // Sorting
  const [sortField, setSortField] = useState<'name' | 'createdAt' | 'prodCount'>('createdAt');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Selected rows for bulk actions
  const [selectedIds, setSelectedIds] = useState<string[]>([]);

  // Dialog States
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState<Category | null>(null);
  const [viewingCategory, setViewingCategory] = useState<Category | null>(null);

  // Confirm Dialog State
  const [deleteTarget, setDeleteTarget] = useState<Category | null>(null);
  const [isBulkDeleteOpen, setIsBulkDeleteOpen] = useState(false);

  // Form State
  const [formName, setFormName] = useState('');
  const [formDesc, setFormDesc] = useState('');
  const [formImage, setFormImage] = useState('');
  const [formStatus, setFormStatus] = useState<'ACTIVE' | 'INACTIVE'>('ACTIVE');

  // Error Alert State for Delete Constraint Rule
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // Fetch Categories
  const { data: marketplaceData, isLoading, refetch, isFetching } = useQuery({
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

  // Client-side Sorting helper
  const sortedCategories = useMemo(() => {
    if (!categories) return [];
    return [...categories].sort((a, b) => {
      let aVal: any = a[sortField as keyof Category];
      let bVal: any = b[sortField as keyof Category];

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
  }, [categories, sortField, sortDirection]);

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
    mutationFn: createAdminCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminCategories'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setIsCreateOpen(false);
      resetForm();
      toast.success('Category created successfully');
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
      toast.success('Category updated successfully');
    },
    onError: (err: any) => {
      setErrorMessage(err?.response?.data?.message || 'Failed to update category.');
    },
  });

  const toggleStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) => toggleCategoryStatus(id, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminCategories'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      toast.success('Category status updated');
    },
  });

  const bulkStatusMutation = useMutation({
    mutationFn: ({ ids, status }: { ids: string[]; status: 'ACTIVE' | 'INACTIVE' }) =>
      bulkUpdateCategoryStatus(ids, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminCategories'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setSelectedIds([]);
      toast.success('Selected categories updated');
    },
  });

  const deleteMutation = useMutation({
    mutationFn: deleteAdminCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminCategories'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setSelectedIds((prev) => prev.filter((id) => id !== deleteTarget?.id));
      setDeleteTarget(null);
      toast.success('Category deleted successfully');
    },
    onError: (err: any) => {
      const msg = err?.response?.data?.message || '';
      if (msg.toLowerCase().includes('sub-categories') || msg.toLowerCase().includes('contains')) {
        setErrorMessage('This Category contains Sub Categories. Remove or reassign them before deleting.');
      } else {
        setErrorMessage(msg || 'Failed to delete category.');
      }
      setDeleteTarget(null);
    },
  });

  const bulkDeleteMutation = useMutation({
    mutationFn: bulkDeleteCategories,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['adminCategories'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
      setSelectedIds([]);
      setIsBulkDeleteOpen(false);
      toast.success('Selected categories deleted successfully');
    },
    onError: (err: any) => {
      const msg = err?.response?.data?.message || '';
      if (msg.toLowerCase().includes('sub-categories') || msg.toLowerCase().includes('contains')) {
        setErrorMessage('One or more selected categories contain Sub Categories. Remove them first.');
      } else {
        setErrorMessage(msg || 'Failed to delete selected categories.');
      }
      setIsBulkDeleteOpen(false);
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
          <div className="p-3 bg-emerald-500/10 text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-400 rounded-2xl">
            <FolderTree className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Categories
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              Master catalog taxonomies and marketplace hierarchy.
            </p>
          </div>
        </div>

        <Button
          onClick={handleOpenCreate}
          className="gap-2 bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl shadow-xs px-4 py-2 text-xs font-semibold"
        >
          <Plus className="h-4 w-4" />
          Create Category
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
            placeholder="Search categories by name..."
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

      {/* Table Component */}
      <div className="rounded-2xl border border-zinc-200/80 dark:border-zinc-800 bg-white dark:bg-zinc-950 overflow-hidden shadow-2xs">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-zinc-50/90 dark:bg-zinc-900/90 text-zinc-500 dark:text-zinc-400 text-xs font-bold uppercase tracking-wider border-b border-zinc-200/80 dark:border-zinc-800">
              <tr>
                <th className="p-4 w-10">
                  <button onClick={handleToggleSelectAll} className="flex items-center cursor-pointer">
                    {categories.length > 0 && selectedIds.length === categories.length ? (
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
                    <span>Category</span>
                    {sortField === 'name' ? (
                      sortDirection === 'asc' ? (
                        <ArrowUp className="h-3.5 w-3.5 text-rose-500" />
                      ) : (
                        <ArrowDown className="h-3.5 w-3.5 text-rose-500" />
                      )
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
                      sortDirection === 'asc' ? (
                        <ArrowUp className="h-3.5 w-3.5 text-rose-500" />
                      ) : (
                        <ArrowDown className="h-3.5 w-3.5 text-rose-500" />
                      )
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
                      sortDirection === 'asc' ? (
                        <ArrowUp className="h-3.5 w-3.5 text-rose-500" />
                      ) : (
                        <ArrowDown className="h-3.5 w-3.5 text-rose-500" />
                      )
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
              ) : sortedCategories.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-12 text-center">
                    <div className="flex flex-col items-center justify-center space-y-2">
                      <div className="p-3 bg-zinc-100 dark:bg-zinc-850 rounded-full text-zinc-400">
                        <Inbox className="h-8 w-8" />
                      </div>
                      <p className="text-sm font-semibold text-zinc-800 dark:text-zinc-200">
                        No Categories Found
                      </p>
                      <p className="text-xs text-zinc-400 max-w-sm">
                        No categories match your search or filters. Create a new category or reset your criteria.
                      </p>
                    </div>
                  </td>
                </tr>
              ) : (
                sortedCategories.map((category) => {
                  const isSelected = selectedIds.includes(category.id);
                  const prodCount = category._count?.products ?? category.productsCount ?? 0;
                  const catStatus = getCategoryStatus(category);
                  const isActive = catStatus === 'ACTIVE';

                  return (
                    <tr
                      key={category.id}
                      className={`hover:bg-zinc-50/80 dark:hover:bg-zinc-900/40 transition-colors ${
                        isSelected ? 'bg-emerald-500/5 dark:bg-emerald-500/10' : ''
                      }`}
                    >
                      <td className="p-4">
                        <button
                          onClick={() => handleToggleSelectRow(category.id)}
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
                          {category.image ? (
                            <img
                              src={category.image}
                              alt={category.name}
                              className="h-10 w-10 rounded-xl object-cover border border-zinc-200 dark:border-zinc-800"
                            />
                          ) : (
                            <div className="p-2.5 bg-emerald-500/10 text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-400 rounded-xl">
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
                        <div className="flex items-center justify-end gap-1.5">
                          <Button
                            variant="outline"
                            size="sm"
                            title="View Category Details"
                            onClick={() => setViewingCategory(category)}
                            className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                          >
                            <Eye className="h-3.5 w-3.5 text-zinc-500" />
                            View
                          </Button>

                          <Button
                            variant="outline"
                            size="sm"
                            title={isActive ? 'Deactivate Category' : 'Activate Category'}
                            onClick={() =>
                              toggleStatusMutation.mutate({ id: category.id, status: catStatus })
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
                            title="Edit Category"
                            onClick={() => handleOpenEdit(category)}
                            className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                          >
                            <Edit className="h-3.5 w-3.5 text-blue-500" />
                            Edit
                          </Button>

                          <Button
                            variant="outline"
                            size="sm"
                            title="Delete Category"
                            onClick={() => setDeleteTarget(category)}
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
      <Dialog open={!!viewingCategory} onOpenChange={(open) => !open && setViewingCategory(null)}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold flex items-center gap-2">
              <FolderTree className="h-5 w-5 text-rose-500" />
              Category Details
            </DialogTitle>
          </DialogHeader>

          {viewingCategory && (
            <div className="space-y-4 pt-2 text-xs">
              {viewingCategory.image && (
                <div className="rounded-xl overflow-hidden border border-zinc-200 dark:border-zinc-800 max-h-48 bg-zinc-50 dark:bg-zinc-900 flex items-center justify-center">
                  <img
                    src={viewingCategory.image}
                    alt={viewingCategory.name}
                    className="object-contain max-h-48 w-full"
                  />
                </div>
              )}

              <div className="grid grid-cols-2 gap-3 p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800">
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Category Name</span>
                  <span className="font-bold text-zinc-900 dark:text-zinc-100 text-sm">
                    {viewingCategory.name}
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Status</span>
                  <div className="mt-0.5">
                    <StatusBadge status={getCategoryStatus(viewingCategory)} />
                  </div>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Products Count</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {viewingCategory._count?.products ?? viewingCategory.productsCount ?? 0}
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Created Date</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {formatDate(viewingCategory.createdAt)}
                  </span>
                </div>
              </div>

              {viewingCategory.description && (
                <div className="space-y-1">
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Description</span>
                  <p className="text-zinc-600 dark:text-zinc-400 leading-relaxed bg-zinc-50 dark:bg-zinc-900 p-3 rounded-xl border border-zinc-100 dark:border-zinc-800">
                    {viewingCategory.description}
                  </p>
                </div>
              )}

              <DialogFooter className="pt-2">
                <Button
                  variant="outline"
                  onClick={() => setViewingCategory(null)}
                  className="rounded-xl h-9 text-xs font-semibold"
                >
                  Close
                </Button>
                <Button
                  onClick={() => {
                    const c = viewingCategory;
                    setViewingCategory(null);
                    handleOpenEdit(c);
                  }}
                  className="rounded-xl h-9 text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs"
                >
                  <Edit className="h-3.5 w-3.5 mr-1.5" />
                  Edit Category
                </Button>
              </DialogFooter>
            </div>
          )}
        </DialogContent>
      </Dialog>

      {/* Create Category Dialog */}
      <Dialog open={isCreateOpen} onOpenChange={setIsCreateOpen}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold">Create Category</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleCreateSubmit} className="space-y-4 pt-2">
            <div className="space-y-1.5">
              <Label htmlFor="create-name" className="text-xs font-bold">Category Name *</Label>
              <Input
                id="create-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="e.g. Fashion, Electronics"
                className="rounded-xl h-9 text-xs"
                required
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="create-desc" className="text-xs font-bold">Description</Label>
              <Input
                id="create-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Category description..."
                className="rounded-xl h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="create-image" className="text-xs font-bold">Category Image URL</Label>
              <Input
                id="create-image"
                value={formImage}
                onChange={(e) => setFormImage(e.target.value)}
                placeholder="https://example.com/image.jpg"
                className="rounded-xl h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="create-status" className="text-xs font-bold">Initial Status</Label>
              <Select value={formStatus} onValueChange={(val) => val && setFormStatus(val as 'ACTIVE' | 'INACTIVE')}>
                <SelectTrigger id="create-status" className="h-9 rounded-xl text-xs">
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
                {createMutation.isPending ? 'Creating...' : 'Create Category'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Edit Category Dialog */}
      <Dialog open={isEditOpen} onOpenChange={setIsEditOpen}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold">Edit Category</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleEditSubmit} className="space-y-4 pt-2">
            <div className="space-y-1.5">
              <Label htmlFor="edit-name" className="text-xs font-bold">Category Name *</Label>
              <Input
                id="edit-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="Category Name"
                className="rounded-xl h-9 text-xs"
                required
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="edit-desc" className="text-xs font-bold">Description</Label>
              <Input
                id="edit-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Description..."
                className="rounded-xl h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="edit-image" className="text-xs font-bold">Category Image URL</Label>
              <Input
                id="edit-image"
                value={formImage}
                onChange={(e) => setFormImage(e.target.value)}
                placeholder="https://example.com/image.jpg"
                className="rounded-xl h-9 text-xs"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="edit-status" className="text-xs font-bold">Status</Label>
              <Select value={formStatus} onValueChange={(val) => val && setFormStatus(val as 'ACTIVE' | 'INACTIVE')}>
                <SelectTrigger id="edit-status" className="h-9 rounded-xl text-xs">
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

      {/* Delete Confirmation Dialog */}
      <ConfirmDialog
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={() => deleteTarget && deleteMutation.mutate(deleteTarget.id)}
        title="Delete Category"
        description={
          deleteTarget ? (
            <span>
              Are you sure you want to delete category <strong>&quot;{deleteTarget.name}&quot;</strong>? This action cannot be undone if it contains subcategories.
            </span>
          ) : undefined
        }
        confirmText="Delete Category"
        variant="destructive"
        isLoading={deleteMutation.isPending}
      />

      {/* Bulk Delete Confirmation Dialog */}
      <ConfirmDialog
        open={isBulkDeleteOpen}
        onClose={() => setIsBulkDeleteOpen(false)}
        onConfirm={() => bulkDeleteMutation.mutate(selectedIds)}
        title="Delete Selected Categories"
        description={`Are you sure you want to delete ${selectedIds.length} selected categories? This will permanently remove them.`}
        confirmText="Delete Selected"
        variant="destructive"
        isLoading={bulkDeleteMutation.isPending}
      />
    </div>
  );
}
