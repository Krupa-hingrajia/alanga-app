'use client';

import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { ShoppingBag, CheckCircle, Store, XCircle, PauseCircle, AlertCircle, RefreshCw, Inbox, Tag } from 'lucide-react';

import {
  getPendingProducts,
  approveProduct,
  rejectProduct,
  suspendProduct,
  Product,
} from '@/features/products/api';
import { useAdminProducts } from '@/features/products/hooks/useAdminProducts';
import { useAdminCategories } from '@/features/categories/hooks/useAdminCategories';
import { useAdminSubCategories } from '@/features/subcategories/hooks/useAdminSubCategories';
import { useAdminBrands } from '@/features/brands/hooks/useAdminBrands';
import { getVendors } from '@/features/vendors/api';
import { ApprovalTable } from '@/components/ApprovalTable';
import { MarketplaceFilter, MarketplaceFilterState } from '@/components/MarketplaceFilter';
import { MarketplaceTable, TableColumn } from '@/components/MarketplaceTable';
import { MarketplacePagination } from '@/components/MarketplacePagination';
import { MarketplaceDetailModal } from '@/components/MarketplaceDetailModal';
import { StatusBadge } from '@/components/StatusBadge';
import { RejectDialog } from '@/components/RejectDialog';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';

export default function ProductsPage() {
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState<'marketplace' | 'pending'>('marketplace');
  const [rejectTarget, setRejectTarget] = useState<string | null>(null);

  const [filterState, setFilterState] = useState<MarketplaceFilterState>({
    page: 1,
    limit: 10,
    sort: 'createdAt_desc',
  });

  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const [detailModalOpen, setDetailModalOpen] = useState(false);

  // Fetch Dropdown options for Filters
  const { data: vendorsData } = useQuery({
    queryKey: ['vendorsList'],
    queryFn: () => getVendors({ limit: 100 }),
  });

  const { data: categoriesData } = useAdminCategories({ limit: 100 });
  const { data: subCategoriesData } = useAdminSubCategories({ limit: 100 });
  const { data: brandsData } = useAdminBrands({ limit: 100 });

  // Fetch Marketplace Products (All Data with filters, sorting, pagination)
  const { data: marketplaceData, isLoading: isMarketplaceLoading } = useAdminProducts({
    status: filterState.status,
    vendorId: filterState.vendorId,
    categoryId: filterState.categoryId,
    subCategoryId: filterState.subCategoryId,
    brandId: filterState.brandId,
    search: filterState.search,
    sort: filterState.sort,
    page: filterState.page,
    limit: filterState.limit,
  });

  // Fetch Pending Products for Approval Tab
  const { data: pendingData, isLoading: isPendingLoading, isError, refetch, isFetching } = useQuery({
    queryKey: ['pendingProducts'],
    queryFn: getPendingProducts,
  });

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ['pendingProducts'] });
    queryClient.invalidateQueries({ queryKey: ['adminProducts'] });
    queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
  };

  const approveMutation = useMutation({
    mutationFn: approveProduct,
    onSuccess: () => { toast.success('Product approved'); invalidate(); },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Approval failed'),
  });

  const rejectMutation = useMutation({
    mutationFn: rejectProduct,
    onSuccess: () => { toast.success('Product rejected'); setRejectTarget(null); invalidate(); },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Rejection failed'),
  });

  const suspendMutation = useMutation({
    mutationFn: suspendProduct,
    onSuccess: () => { toast.success('Product suspended'); invalidate(); },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Suspension failed'),
  });

  const handleFilterChange = (newFilters: MarketplaceFilterState) => {
    setFilterState((prev) => ({
      ...prev,
      ...newFilters,
      page: newFilters.page ?? 1,
    }));
  };

  const handleResetFilters = () => {
    setFilterState({
      page: 1,
      limit: 10,
      sort: 'createdAt_desc',
    });
  };

  const handleSort = (field: string) => {
    const currentSort = filterState.sort || 'createdAt_desc';
    const [currentField, currentDir] = currentSort.split('_');
    let nextDir = 'asc';
    if (currentField === field && currentDir === 'asc') {
      nextDir = 'desc';
    }
    setFilterState((prev) => ({
      ...prev,
      sort: `${field}_${nextDir}`,
    }));
  };

  const formatPrice = (n?: number) => {
    if (n === undefined || n === null) return 'N/A';
    return new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(n);
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

  // Columns for Products Table
  const productColumns: TableColumn<Product>[] = [
    {
      key: 'name',
      header: 'Product Name',
      sortable: true,
      render: (item) => (
        <div className="flex items-center gap-3">
          {item.image ? (
            <img
              src={item.image}
              alt={item.name}
              className="h-10 w-10 rounded-lg object-cover border border-zinc-200 dark:border-zinc-800"
            />
          ) : (
            <div className="p-2.5 bg-rose-500/10 text-rose-500 rounded-lg">
              <ShoppingBag className="h-5 w-5" />
            </div>
          )}
          <div>
            <p className="font-semibold text-zinc-900 dark:text-zinc-100">{item.name}</p>
            <p className="text-xs font-mono text-zinc-400">SKU: {item.sku}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'category',
      header: 'Category',
      sortable: false,
      render: (item) => (
        <span className="text-xs font-medium text-zinc-700 dark:text-zinc-300">
          {item.category?.name || 'N/A'}
        </span>
      ),
    },
    {
      key: 'subCategory',
      header: 'Sub Category',
      sortable: false,
      render: (item) => (
        <span className="text-xs font-medium text-zinc-700 dark:text-zinc-300">
          {item.subCategory?.name || 'N/A'}
        </span>
      ),
    },
    {
      key: 'brand',
      header: 'Brand',
      sortable: false,
      render: (item) => (
        <span className="text-xs font-medium text-zinc-700 dark:text-zinc-300">
          {item.brand?.name || 'N/A'}
        </span>
      ),
    },
    {
      key: 'vendorName',
      header: 'Vendor Name',
      sortable: true,
      render: (item) => (
        <span className="font-medium text-zinc-800 dark:text-zinc-200">
          {item.vendorName || item.vendor?.name || 'System Admin'}
        </span>
      ),
    },
    {
      key: 'mrp',
      header: 'MRP',
      sortable: true,
      render: (item) => (
        <span className="text-xs text-zinc-400 line-through">
          {formatPrice(item.mrp)}
        </span>
      ),
    },
    {
      key: 'sellingPrice',
      header: 'Selling Price',
      sortable: true,
      render: (item) => (
        <span className="font-bold text-emerald-600 dark:text-emerald-400">
          {formatPrice(item.sellingPrice)}
        </span>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      sortable: true,
      render: (item) => <StatusBadge status={item.status} />,
    },
    {
      key: 'createdAt',
      header: 'Created Date',
      sortable: true,
      render: (item) => <span className="text-xs text-zinc-500">{formatDate(item.createdAt)}</span>,
    },
    {
      key: 'updatedAt',
      header: 'Updated Date',
      sortable: true,
      render: (item) => <span className="text-xs text-zinc-500">{formatDate(item.updatedAt)}</span>,
    },
  ];

  const currentSortParts = (filterState.sort || 'createdAt_desc').split('_');

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-3 bg-rose-500/10 text-rose-500 rounded-2xl">
            <ShoppingBag className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Products Management
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              Browse and manage marketplace products, filter category/brand/vendor-wise, and process approvals.
            </p>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <Tabs
        value={activeTab}
        onValueChange={(v) => setActiveTab(v as 'marketplace' | 'pending')}
        className="w-full"
      >
        <TabsList className="bg-zinc-100 dark:bg-zinc-900 p-1 rounded-2xl border border-zinc-200/60 dark:border-zinc-800">
          <TabsTrigger
            value="marketplace"
            className="rounded-xl px-4 py-2 text-xs font-bold gap-2 data-[state=active]:bg-white dark:data-[state=active]:bg-zinc-800 data-[state=active]:shadow-sm"
          >
            <Store className="h-4 w-4 text-rose-500" />
            <span>Marketplace Products</span>
            {marketplaceData?.total !== undefined && (
              <span className="ml-1 px-2 py-0.5 rounded-full bg-rose-500/10 text-rose-500 text-xs font-extrabold">
                {marketplaceData.total}
              </span>
            )}
          </TabsTrigger>
          <TabsTrigger
            value="pending"
            className="rounded-xl px-4 py-2 text-xs font-bold gap-2 data-[state=active]:bg-white dark:data-[state=active]:bg-zinc-800 data-[state=active]:shadow-sm"
          >
            <CheckCircle className="h-4 w-4 text-amber-500" />
            <span>Pending Approvals</span>
            {pendingData?.length !== undefined && pendingData.length > 0 && (
              <span className="ml-1 px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-600 dark:text-amber-400 text-xs font-extrabold">
                {pendingData.length}
              </span>
            )}
          </TabsTrigger>
        </TabsList>

        {/* Tab 1: Marketplace Products (All Records with Filters, Sorting, Pagination) */}
        <TabsContent value="marketplace" className="space-y-4 pt-4">
          <MarketplaceFilter
            filters={filterState}
            onFilterChange={handleFilterChange}
            onReset={handleResetFilters}
            showCategory={true}
            showSubCategory={true}
            showBrand={true}
            categories={categoriesData?.items ?? []}
            subCategories={subCategoriesData?.items ?? []}
            brands={brandsData?.items ?? []}
            vendors={vendorsData?.items ?? []}
          />

          <MarketplaceTable
            columns={productColumns}
            data={marketplaceData?.items ?? []}
            isLoading={isMarketplaceLoading}
            sortField={currentSortParts[0]}
            sortDirection={currentSortParts[1] as 'asc' | 'desc'}
            onSort={handleSort}
            onViewDetails={(item) => {
              setSelectedProduct(item);
              setDetailModalOpen(true);
            }}
            emptyMessage="No products found matching your filters."
          />

          {marketplaceData && (
            <MarketplacePagination
              page={marketplaceData.page}
              limit={marketplaceData.limit}
              total={marketplaceData.total}
              totalPages={marketplaceData.totalPages}
              onPageChange={(page) => handleFilterChange({ ...filterState, page })}
            />
          )}
        </TabsContent>

        {/* Tab 2: Pending Approvals (Approval Workflow Unchanged) */}
        <TabsContent value="pending" className="space-y-4 pt-4">
          <div className="flex items-center gap-2 px-4 py-3 rounded-2xl bg-amber-50 dark:bg-amber-900/20 border border-amber-100 dark:border-amber-900">
            <div className="h-2 w-2 rounded-full bg-amber-500 animate-pulse" />
            <p className="text-sm text-amber-800 dark:text-amber-400 font-medium">
              {isPendingLoading
                ? '...'
                : `${pendingData?.length ?? 0} pending product${pendingData?.length !== 1 ? 's' : ''} awaiting review`}
            </p>
          </div>

          {isPendingLoading ? (
            <div className="space-y-3">
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="h-28 rounded-2xl bg-zinc-200 dark:bg-zinc-800 animate-pulse" />
              ))}
            </div>
          ) : isError ? (
            <div className="flex flex-col items-center justify-center min-h-[40vh] border border-dashed border-zinc-200 dark:border-zinc-800 rounded-3xl">
              <AlertCircle className="h-10 w-10 text-rose-500 mb-3" />
              <p className="font-semibold text-zinc-900 dark:text-zinc-50">Failed to load products</p>
              <Button onClick={() => refetch()} className="mt-4 bg-rose-500 hover:bg-rose-600 text-white rounded-xl">Retry</Button>
            </div>
          ) : pendingData?.length === 0 ? (
            <div className="flex flex-col items-center justify-center min-h-[40vh] border border-dashed border-zinc-200 dark:border-zinc-800 rounded-3xl gap-3">
              <div className="p-4 bg-emerald-100 dark:bg-emerald-900/30 rounded-2xl">
                <Inbox className="h-8 w-8 text-emerald-600 dark:text-emerald-400" />
              </div>
              <p className="font-semibold text-zinc-700 dark:text-zinc-300">Queue is empty!</p>
              <p className="text-sm text-zinc-500 dark:text-zinc-400">No pending product submissions right now.</p>
            </div>
          ) : (
            <div className="space-y-4">
              {pendingData?.map((product: Product) => (
                <Card key={product.id} className="border border-zinc-200/60 dark:border-zinc-800/60 hover:shadow-md transition-all duration-200">
                  <CardContent className="p-5">
                    <div className="flex flex-col sm:flex-row sm:items-start gap-4">
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start gap-3 mb-3">
                          <div className="p-2.5 bg-zinc-100 dark:bg-zinc-900 rounded-xl shrink-0">
                            <ShoppingBag className="h-5 w-5 text-zinc-500 dark:text-zinc-400" />
                          </div>
                          <div>
                            <div className="flex items-center gap-2 flex-wrap mb-1">
                              <h3 className="font-semibold text-sm text-zinc-900 dark:text-zinc-50">{product.name}</h3>
                              <StatusBadge status={product.status} />
                            </div>
                            {product.description && (
                              <p className="text-xs text-zinc-500 dark:text-zinc-400 line-clamp-2">{product.description}</p>
                            )}
                          </div>
                        </div>

                        <div className="flex flex-wrap gap-3">
                          <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 text-xs">
                            <Tag className="h-3.5 w-3.5 text-zinc-400" />
                            <span className="font-mono font-medium text-zinc-600 dark:text-zinc-300">{product.sku}</span>
                          </div>
                          <div className="flex items-center gap-1 px-3 py-1.5 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 text-xs">
                            <span>MRP: <span className="font-semibold text-zinc-700 dark:text-zinc-200">{formatPrice(product.mrp)}</span></span>
                          </div>
                          <div className="flex items-center gap-1 px-3 py-1.5 rounded-xl bg-emerald-50 dark:bg-emerald-900/20 border border-emerald-100 dark:border-emerald-900 text-xs">
                            <span>Selling: <span className="font-semibold text-emerald-700 dark:text-emerald-400">{formatPrice(product.sellingPrice)}</span></span>
                          </div>
                        </div>

                        {product.rejectedReason && (
                          <div className="mt-3 px-3 py-2 rounded-xl bg-rose-50 dark:bg-rose-900/20 border border-rose-100 dark:border-rose-900 text-xs text-rose-700 dark:text-rose-400">
                            <span className="font-semibold">Rejection Reason:</span> {product.rejectedReason}
                          </div>
                        )}
                      </div>

                      <div className="flex sm:flex-col gap-2 shrink-0">
                        {product.status === 'PENDING' && (
                          <>
                            <Button
                              size="sm"
                              onClick={() => approveMutation.mutate(product.id)}
                              disabled={approveMutation.isPending}
                              className="h-9 px-4 text-xs rounded-xl bg-emerald-500 hover:bg-emerald-600 text-white font-semibold"
                            >
                              <CheckCircle className="h-3.5 w-3.5 mr-1.5" />
                              Approve
                            </Button>
                            <Button
                              size="sm"
                              variant="outline"
                              onClick={() => setRejectTarget(product.id)}
                              disabled={rejectMutation.isPending}
                              className="h-9 px-4 text-xs rounded-xl border-rose-200 dark:border-rose-800 text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-900/20 font-semibold"
                            >
                              <XCircle className="h-3.5 w-3.5 mr-1.5" />
                              Reject
                            </Button>
                          </>
                        )}
                        {product.status === 'ACTIVE' && (
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() => suspendMutation.mutate(product.id)}
                            disabled={suspendMutation.isPending}
                            className="h-9 px-4 text-xs rounded-xl border-zinc-200 dark:border-zinc-800 text-zinc-600 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-900 font-semibold"
                          >
                            <PauseCircle className="h-3.5 w-3.5 mr-1.5" />
                            Suspend
                          </Button>
                        )}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </TabsContent>
      </Tabs>

      <RejectDialog
        open={!!rejectTarget}
        onClose={() => setRejectTarget(null)}
        onConfirm={(reason) => rejectTarget && rejectMutation.mutate({ id: rejectTarget, reason })}
        isPending={rejectMutation.isPending}
        title="Reject Product"
        description="Please provide a reason for rejection. This will be communicated to the vendor."
      />

      {/* View Details Modal */}
      <MarketplaceDetailModal
        open={detailModalOpen}
        onOpenChange={setDetailModalOpen}
        title="Product Details"
        item={selectedProduct}
      />
    </div>
  );
}
