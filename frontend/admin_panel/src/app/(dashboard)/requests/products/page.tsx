'use client';

import React, { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import {
  ShoppingBag,
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
  Store,
  IndianRupee,
  Layers,
} from 'lucide-react';

import {
  getPendingProducts,
  approveProduct,
  rejectProduct,
  Product,
} from '@/features/products/api';
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

export default function ProductApprovalsPage() {
  const queryClient = useQueryClient();

  const [search, setSearch] = useState('');
  const [sortField, setSortField] = useState<'name' | 'sellingPrice' | 'createdAt'>('createdAt');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');

  // Modals & Action Targets
  const [viewingProduct, setViewingProduct] = useState<Product | null>(null);
  const [approveTarget, setApproveTarget] = useState<Product | null>(null);
  const [rejectTarget, setRejectTarget] = useState<Product | null>(null);
  const [rejectReason, setRejectReason] = useState('');

  const { data: pendingProducts, isLoading } = useQuery({
    queryKey: ['pendingProducts'],
    queryFn: getPendingProducts,
  });

  const products = pendingProducts ?? [];

  // Filter & Sort
  const filteredProducts = useMemo(() => {
    return products.filter(
      (p) =>
        p.name.toLowerCase().includes(search.toLowerCase().trim()) ||
        p.sku.toLowerCase().includes(search.toLowerCase().trim())
    );
  }, [products, search]);

  const sortedProducts = useMemo(() => {
    return [...filteredProducts].sort((a, b) => {
      let aVal: any = a[sortField];
      let bVal: any = b[sortField];

      if (sortField === 'sellingPrice') {
        aVal = a.sellingPrice || 0;
        bVal = b.sellingPrice || 0;
        return sortDirection === 'asc' ? aVal - bVal : bVal - aVal;
      }

      if (typeof aVal === 'string') {
        return sortDirection === 'asc'
          ? aVal.localeCompare(bVal || '')
          : (bVal || '').localeCompare(aVal);
      }
      return sortDirection === 'asc' ? (aVal > bVal ? 1 : -1) : aVal < bVal ? 1 : -1;
    });
  }, [filteredProducts, sortField, sortDirection]);

  const handleSort = (field: 'name' | 'sellingPrice' | 'createdAt') => {
    if (sortField === field) {
      setSortDirection((prev) => (prev === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortField(field);
      setSortDirection('asc');
    }
  };

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ['pendingProducts'] });
    queryClient.invalidateQueries({ queryKey: ['adminProducts'] });
    queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
  };

  const approveMutation = useMutation({
    mutationFn: approveProduct,
    onSuccess: () => {
      toast.success('Product approved successfully');
      invalidate();
      setApproveTarget(null);
      if (viewingProduct && viewingProduct.id === approveTarget?.id) {
        setViewingProduct(null);
      }
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Approval failed'),
  });

  const rejectMutation = useMutation({
    mutationFn: ({ id, reason }: { id: string; reason: string }) => rejectProduct({ id, reason }),
    onSuccess: () => {
      toast.success('Product rejected');
      invalidate();
      setRejectTarget(null);
      setRejectReason('');
      if (viewingProduct && viewingProduct.id === rejectTarget?.id) {
        setViewingProduct(null);
      }
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Rejection failed'),
  });

  const formatPrice = (value?: number) => {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 0,
    }).format(value || 0);
  };

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
          <div className="p-3 bg-rose-500/10 text-rose-600 dark:bg-rose-500/20 dark:text-rose-400 rounded-2xl">
            <CheckCircle className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Product Approvals
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              Verify catalog quality, pricing integrity, and standard compliance before publishing.
            </p>
          </div>
        </div>
      </div>

      {/* Filter & Search Toolbar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-3 bg-white dark:bg-zinc-950 p-4 rounded-2xl border border-zinc-200/80 dark:border-zinc-800 shadow-2xs">
        <div className="relative w-full sm:w-80">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-zinc-400" />
          <Input
            placeholder="Search by product name or SKU..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-9 h-9 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs"
          />
        </div>

        <div className="text-xs text-zinc-500 font-medium">
          {sortedProducts.length} pending product{sortedProducts.length !== 1 ? 's' : ''} awaiting review
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
                    <span>Product & SKU</span>
                    {sortField === 'name' ? (
                      sortDirection === 'asc' ? <ArrowUp className="h-3.5 w-3.5 text-emerald-600" /> : <ArrowDown className="h-3.5 w-3.5 text-emerald-600" />
                    ) : (
                      <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4">Category & Brand</th>
                <th className="p-4">
                  <button
                    onClick={() => handleSort('sellingPrice')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Price</span>
                    {sortField === 'sellingPrice' ? (
                      sortDirection === 'asc' ? <ArrowUp className="h-3.5 w-3.5 text-emerald-600" /> : <ArrowDown className="h-3.5 w-3.5 text-emerald-600" />
                    ) : (
                      <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4">Status</th>
                <th className="p-4">
                  <button
                    onClick={() => handleSort('createdAt')}
                    className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
                  >
                    <span>Submitted Date</span>
                    {sortField === 'createdAt' ? (
                      sortDirection === 'asc' ? <ArrowUp className="h-3.5 w-3.5 text-emerald-600" /> : <ArrowDown className="h-3.5 w-3.5 text-emerald-600" />
                    ) : (
                      <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                    )}
                  </button>
                </th>
                <th className="p-4 text-right">Approval Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100 dark:divide-zinc-900">
              {isLoading ? (
                Array.from({ length: 4 }).map((_, idx) => (
                  <tr key={idx} className="animate-pulse">
                    <td className="p-4" colSpan={6}>
                      <div className="h-7 bg-zinc-100 dark:bg-zinc-800 rounded-xl" />
                    </td>
                  </tr>
                ))
              ) : sortedProducts.length === 0 ? (
                <tr>
                  <td colSpan={6} className="p-12 text-center">
                    <div className="flex flex-col items-center justify-center space-y-2">
                      <div className="p-3 bg-emerald-100 dark:bg-emerald-950/40 rounded-full text-emerald-600 dark:text-emerald-400">
                        <CheckCircle className="h-8 w-8" />
                      </div>
                      <p className="text-sm font-semibold text-zinc-800 dark:text-zinc-200">
                        Approval Queue Clear!
                      </p>
                      <p className="text-xs text-zinc-400 max-w-sm">
                        There are currently no products awaiting administrative verification.
                      </p>
                    </div>
                  </td>
                </tr>
              ) : (
                sortedProducts.map((product) => (
                  <tr
                    key={product.id}
                    className="hover:bg-zinc-50/80 dark:hover:bg-zinc-900/40 transition-colors"
                  >
                    <td className="p-4">
                      <div className="flex items-center gap-3">
                        {product.image ? (
                          <img
                            src={product.image}
                            alt={product.name}
                            className="h-10 w-10 rounded-xl object-cover border border-zinc-200 dark:border-zinc-800"
                          />
                        ) : (
                          <div className="p-2.5 bg-emerald-500/10 text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-400 rounded-xl">
                            <ShoppingBag className="h-5 w-5" />
                          </div>
                        )}
                        <div>
                          <p className="font-bold text-zinc-900 dark:text-zinc-100">{product.name}</p>
                          <p className="text-xs text-zinc-400 font-mono">SKU: {product.sku}</p>
                        </div>
                      </div>
                    </td>
                    <td className="p-4 text-xs space-y-0.5">
                      <p className="font-semibold text-zinc-800 dark:text-zinc-200">
                        {product.category?.name || 'General'}
                      </p>
                      <p className="text-zinc-400">
                        Brand: {product.brand?.name || 'Unbranded'}
                      </p>
                    </td>
                    <td className="p-4 text-xs">
                      <p className="font-bold text-emerald-600 dark:text-emerald-400">
                        {formatPrice(product.sellingPrice)}
                      </p>
                      <p className="text-[11px] text-zinc-400 line-through">
                        MRP: {formatPrice(product.mrp)}
                      </p>
                    </td>
                    <td className="p-4">
                      <StatusBadge status="PENDING" />
                    </td>
                    <td className="p-4 text-xs text-zinc-500">
                      {formatDate(product.createdAt)}
                    </td>
                    <td className="p-4 text-right">
                      <div className="flex items-center justify-end gap-1.5">
                        <Button
                          variant="outline"
                          size="sm"
                          title="View Product Details"
                          onClick={() => setViewingProduct(product)}
                          className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                        >
                          <Eye className="h-3.5 w-3.5 text-zinc-500" />
                          View
                        </Button>

                        <Button
                          size="sm"
                          title="Approve Product"
                          onClick={() => setApproveTarget(product)}
                          className="h-8 px-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold gap-1.5"
                        >
                          <CheckCircle className="h-3.5 w-3.5" />
                          Approve
                        </Button>

                        <Button
                          variant="outline"
                          size="sm"
                          title="Reject Product"
                          onClick={() => {
                            setRejectTarget(product);
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

      {/* View Product Details Modal */}
      <Dialog open={!!viewingProduct} onOpenChange={(open) => !open && setViewingProduct(null)}>
        <DialogContent className="sm:max-w-lg rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold flex items-center gap-2">
              <ShoppingBag className="h-5 w-5 text-rose-500" />
              Product Submission Details
            </DialogTitle>
          </DialogHeader>

          {viewingProduct && (
            <div className="space-y-4 pt-2 text-xs">
              <div className="flex items-start gap-4 p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800">
                {viewingProduct.image ? (
                  <img
                    src={viewingProduct.image}
                    alt={viewingProduct.name}
                    className="h-16 w-16 rounded-xl object-cover border border-zinc-200 dark:border-zinc-800 bg-white"
                  />
                ) : (
                  <div className="h-16 w-16 rounded-xl bg-rose-100 dark:bg-rose-950/40 text-rose-600 flex items-center justify-center shrink-0">
                    <ShoppingBag className="h-8 w-8" />
                  </div>
                )}
                <div>
                  <h3 className="text-base font-bold text-zinc-900 dark:text-zinc-50">
                    {viewingProduct.name}
                  </h3>
                  <p className="text-xs text-zinc-400 font-mono mt-0.5">SKU: {viewingProduct.sku}</p>
                  <div className="mt-1 flex items-center gap-2">
                    <StatusBadge status="PENDING" />
                    <span className="text-zinc-400 text-[11px]">
                      Submitted {formatDate(viewingProduct.createdAt)}
                    </span>
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3 p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800">
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Category</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {viewingProduct.category?.name || 'N/A'}
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Sub Category</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {viewingProduct.subCategory?.name || 'N/A'}
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Brand</span>
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {viewingProduct.brand?.name || 'N/A'}
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Selling Price / MRP</span>
                  <span className="font-semibold text-emerald-600">
                    {formatPrice(viewingProduct.sellingPrice)}
                  </span>
                  <span className="text-zinc-400 text-[10px] ml-1">
                    (MRP {formatPrice(viewingProduct.mrp)})
                  </span>
                </div>
              </div>

              {viewingProduct.description && (
                <div className="space-y-1">
                  <span className="text-zinc-400 block text-[10px] uppercase font-bold">Description</span>
                  <p className="text-zinc-600 dark:text-zinc-400 leading-relaxed bg-zinc-50 dark:bg-zinc-900 p-3 rounded-xl border border-zinc-100 dark:border-zinc-800">
                    {viewingProduct.description}
                  </p>
                </div>
              )}

              <DialogFooter className="pt-2">
                <Button
                  variant="outline"
                  onClick={() => setViewingProduct(null)}
                  className="rounded-xl h-9 text-xs font-semibold"
                >
                  Close
                </Button>
                <Button
                  onClick={() => {
                    const p = viewingProduct;
                    setViewingProduct(null);
                    setApproveTarget(p);
                  }}
                  className="rounded-xl h-9 text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white"
                >
                  <CheckCircle className="h-3.5 w-3.5 mr-1.5" />
                  Approve Product
                </Button>
              </DialogFooter>
            </div>
          )}
        </DialogContent>
      </Dialog>

      {/* Reject Product Dialog */}
      <Dialog open={!!rejectTarget} onOpenChange={(open) => !open && setRejectTarget(null)}>
        <DialogContent className="sm:max-w-md rounded-2xl p-6">
          <DialogHeader>
            <DialogTitle className="text-base font-bold text-rose-600">Reject Product</DialogTitle>
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
              Please enter an official reason explaining why this product cannot be published:
            </p>
            <div className="space-y-1.5">
              <Label htmlFor="prod-reject-reason" className="text-xs font-bold">Reason *</Label>
              <Input
                id="prod-reject-reason"
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                placeholder="e.g. Inaccurate specifications, copyright images..."
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
                {rejectMutation.isPending ? 'Rejecting...' : 'Reject Product'}
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
        title="Approve Product"
        description={
          approveTarget ? (
            <span>
              Are you sure you want to approve product <strong>&quot;{approveTarget.name}&quot;</strong>? It will immediately become visible to customers across the marketplace.
            </span>
          ) : undefined
        }
        confirmText="Approve Product"
        variant="primary"
        isLoading={approveMutation.isPending}
      />
    </div>
  );
}
