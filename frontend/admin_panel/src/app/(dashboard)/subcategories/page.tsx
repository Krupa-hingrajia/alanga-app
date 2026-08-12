'use client';

import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { GitBranch } from 'lucide-react';

import { getPendingSubCategories, approveSubCategory, rejectSubCategory } from '@/features/subcategories/api';
import { ApprovalTable } from '@/components/ApprovalTable';

export default function SubCategoriesPage() {
  const { data, isLoading, isError, refetch, isFetching } = useQuery({
    queryKey: ['pendingSubCategories'],
    queryFn: getPendingSubCategories,
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <div className="p-2.5 bg-sky-100 dark:bg-sky-900/30 rounded-xl">
          <GitBranch className="h-5 w-5 text-sky-600 dark:text-sky-400" />
        </div>
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">Subcategories Approval</h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400 mt-0.5">
            Review and approve pending subcategory submissions from vendors.
          </p>
        </div>
      </div>

      <div className="flex items-center gap-2 px-4 py-3 rounded-2xl bg-amber-50 dark:bg-amber-900/20 border border-amber-100 dark:border-amber-900">
        <div className="h-2 w-2 rounded-full bg-amber-500 animate-pulse" />
        <p className="text-sm text-amber-800 dark:text-amber-400 font-medium">
          {isLoading ? '...' : `${data?.length ?? 0} pending subcategory submission${data?.length !== 1 ? 's' : ''} awaiting your review`}
        </p>
      </div>

      <ApprovalTable
        items={data ?? []}
        isLoading={isLoading}
        isError={isError}
        isFetching={isFetching}
        refetch={refetch}
        queryKeys={['pendingSubCategories']}
        approveFn={approveSubCategory}
        rejectFn={rejectSubCategory}
        entityLabel="Subcategory"
        extraFields={[{ label: 'Category', key: 'categoryId' }]}
      />
    </div>
  );
}
