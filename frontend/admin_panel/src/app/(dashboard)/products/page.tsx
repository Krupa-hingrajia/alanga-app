'use client';

import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { ShoppingBag, CheckCircle, XCircle, PauseCircle, AlertCircle, RefreshCw, Inbox, IndianRupee, Tag } from 'lucide-react';

import { getPendingProducts, approveProduct, rejectProduct, suspendProduct, Product } from '@/features/products/api';
import { StatusBadge } from '@/components/StatusBadge';
import { RejectDialog } from '@/components/RejectDialog';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';

export default function ProductsPage() {
  const queryClient = useQueryClient();
  const [rejectTarget, setRejectTarget] = useState<string | null>(null);

  const { data, isLoading, isError, refetch, isFetching } = useQuery({
    queryKey: ['pendingProducts'],
    queryFn: getPendingProducts,
  });

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ['pendingProducts'] });
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

  const formatPrice = (n: number) =>
    new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(n);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-sky-100 dark:bg-sky-900/30 rounded-xl">
            <ShoppingBag className="h-5 w-5 text-sky-600 dark:text-sky-400" />
          </div>
          <div>
            <h1 className="text-3xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">Products Approval</h1>
            <p className="text-sm text-zinc-500 dark:text-zinc-400 mt-0.5">
              Review product listings submitted by vendors before they go live.
            </p>
          </div>
        </div>
        <Button
          variant="outline"
          size="sm"
          onClick={() => refetch()}
          disabled={isFetching}
          className="self-start sm:self-auto h-9 px-3 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs"
        >
          <RefreshCw className={`h-3.5 w-3.5 mr-1.5 ${isFetching ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      <div className="flex items-center gap-2 px-4 py-3 rounded-2xl bg-amber-50 dark:bg-amber-900/20 border border-amber-100 dark:border-amber-900">
        <div className="h-2 w-2 rounded-full bg-amber-500 animate-pulse" />
        <p className="text-sm text-amber-800 dark:text-amber-400 font-medium">
          {isLoading ? '...' : `${data?.length ?? 0} pending product${data?.length !== 1 ? 's' : ''} awaiting quality review`}
        </p>
      </div>

      {/* Content */}
      {isLoading ? (
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
      ) : data?.length === 0 ? (
        <div className="flex flex-col items-center justify-center min-h-[40vh] border border-dashed border-zinc-200 dark:border-zinc-800 rounded-3xl gap-3">
          <div className="p-4 bg-emerald-100 dark:bg-emerald-900/30 rounded-2xl">
            <Inbox className="h-8 w-8 text-emerald-600 dark:text-emerald-400" />
          </div>
          <p className="font-semibold text-zinc-700 dark:text-zinc-300">Queue is empty!</p>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">No pending product submissions right now.</p>
        </div>
      ) : (
        <div className="space-y-4">
          {data?.map((product: Product) => (
            <Card key={product.id} className="border border-zinc-200/60 dark:border-zinc-800/60 hover:shadow-md transition-all duration-200">
              <CardContent className="p-5">
                <div className="flex flex-col sm:flex-row sm:items-start gap-4">
                  {/* Product Info */}
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
                        <IndianRupee className="h-3.5 w-3.5 text-zinc-400" />
                        <span>MRP: <span className="font-semibold text-zinc-700 dark:text-zinc-200">{formatPrice(product.mrp)}</span></span>
                      </div>
                      <div className="flex items-center gap-1 px-3 py-1.5 rounded-xl bg-emerald-50 dark:bg-emerald-900/20 border border-emerald-100 dark:border-emerald-900 text-xs">
                        <IndianRupee className="h-3.5 w-3.5 text-emerald-500" />
                        <span>Selling: <span className="font-semibold text-emerald-700 dark:text-emerald-400">{formatPrice(product.sellingPrice)}</span></span>
                      </div>
                    </div>

                    {product.rejectedReason && (
                      <div className="mt-3 px-3 py-2 rounded-xl bg-rose-50 dark:bg-rose-900/20 border border-rose-100 dark:border-rose-900 text-xs text-rose-700 dark:text-rose-400">
                        <span className="font-semibold">Rejection Reason:</span> {product.rejectedReason}
                      </div>
                    )}
                  </div>

                  {/* Actions */}
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

      <RejectDialog
        open={!!rejectTarget}
        onClose={() => setRejectTarget(null)}
        onConfirm={(reason) => rejectTarget && rejectMutation.mutate({ id: rejectTarget, reason })}
        isPending={rejectMutation.isPending}
        title="Reject Product"
        description="Please provide a reason for rejection. This will be communicated to the vendor."
      />
    </div>
  );
}
