'use client';

import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { Tag } from 'lucide-react';

import { getPendingBrands, approveBrand, rejectBrand } from '@/features/brands/api';
import { ApprovalTable } from '@/components/ApprovalTable';

export default function BrandsPage() {
  const { data, isLoading, isError, refetch, isFetching } = useQuery({
    queryKey: ['pendingBrands'],
    queryFn: getPendingBrands,
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <div className="p-2.5 bg-purple-100 dark:bg-purple-900/30 rounded-xl">
          <Tag className="h-5 w-5 text-purple-600 dark:text-purple-400" />
        </div>
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">Brands Approval</h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400 mt-0.5">
            Review and approve pending brand submissions from vendors.
          </p>
        </div>
      </div>

      <div className="flex items-center gap-2 px-4 py-3 rounded-2xl bg-amber-50 dark:bg-amber-900/20 border border-amber-100 dark:border-amber-900">
        <div className="h-2 w-2 rounded-full bg-amber-500 animate-pulse" />
        <p className="text-sm text-amber-800 dark:text-amber-400 font-medium">
          {isLoading ? '...' : `${data?.length ?? 0} pending brand submission${data?.length !== 1 ? 's' : ''} awaiting your review`}
        </p>
      </div>

      <ApprovalTable
        items={data ?? []}
        isLoading={isLoading}
        isError={isError}
        isFetching={isFetching}
        refetch={refetch}
        queryKeys={['pendingBrands']}
        approveFn={approveBrand}
        rejectFn={rejectBrand}
        entityLabel="Brand"
      />
    </div>
  );
}
