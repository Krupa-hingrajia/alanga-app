'use client';

import React from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface MarketplacePaginationProps {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  onPageChange: (page: number) => void;
}

export function MarketplacePagination({
  page,
  limit,
  total,
  totalPages,
  onPageChange,
}: MarketplacePaginationProps) {
  if (total === 0) return null;

  const start = (page - 1) * limit + 1;
  const end = Math.min(page * limit, total);

  return (
    <div className="flex flex-col sm:flex-row items-center justify-between gap-4 py-3 px-4 bg-white dark:bg-zinc-900 border border-zinc-200/80 dark:border-zinc-800 rounded-2xl shadow-sm">
      <div className="text-xs text-zinc-500 dark:text-zinc-400">
        Showing <span className="font-semibold text-zinc-900 dark:text-zinc-100">{start}</span> to{' '}
        <span className="font-semibold text-zinc-900 dark:text-zinc-100">{end}</span> of{' '}
        <span className="font-semibold text-zinc-900 dark:text-zinc-100">{total}</span> items
      </div>

      <div className="flex items-center gap-1.5">
        <Button
          variant="outline"
          size="sm"
          disabled={page <= 1}
          onClick={() => onPageChange(page - 1)}
          className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-medium gap-1"
        >
          <ChevronLeft className="h-4 w-4" />
          <span>Previous</span>
        </Button>

        {Array.from({ length: Math.min(totalPages, 5) }, (_, idx) => {
          let pNum = page;
          if (totalPages <= 5) {
            pNum = idx + 1;
          } else if (page <= 3) {
            pNum = idx + 1;
          } else if (page >= totalPages - 2) {
            pNum = totalPages - 4 + idx;
          } else {
            pNum = page - 2 + idx;
          }

          return (
            <Button
              key={pNum}
              variant={page === pNum ? 'default' : 'outline'}
              size="sm"
              onClick={() => onPageChange(pNum)}
              className={`h-8 w-8 p-0 rounded-xl text-xs font-semibold ${
                page === pNum
                  ? 'bg-emerald-600 text-white hover:bg-emerald-700 shadow-xs'
                  : 'border-zinc-200 dark:border-zinc-800'
              }`}
            >
              {pNum}
            </Button>
          );
        })}

        <Button
          variant="outline"
          size="sm"
          disabled={page >= totalPages}
          onClick={() => onPageChange(page + 1)}
          className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-medium gap-1"
        >
          <span>Next</span>
          <ChevronRight className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}
