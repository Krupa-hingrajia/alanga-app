'use client';

import React from 'react';
import { ArrowUpDown, ArrowUp, ArrowDown, Eye, Inbox } from 'lucide-react';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '@/components/StatusBadge';

export interface TableColumn<T> {
  key: string;
  header: string;
  sortable?: boolean;
  render?: (item: T) => React.ReactNode;
}

interface MarketplaceTableProps<T> {
  columns: TableColumn<T>[];
  data: T[];
  isLoading?: boolean;
  sortField?: string;
  sortDirection?: 'asc' | 'desc';
  onSort?: (field: string) => void;
  onViewDetails?: (item: T) => void;
  emptyMessage?: string;
}

export function MarketplaceTable<T extends { id: string; status?: string }>({
  columns,
  data,
  isLoading = false,
  sortField,
  sortDirection,
  onSort,
  onViewDetails,
  emptyMessage = 'No records found matching your filters.',
}: MarketplaceTableProps<T>) {
  const handleSortClick = (columnKey: string) => {
    if (onSort) {
      onSort(columnKey);
    }
  };

  return (
    <div className="relative rounded-2xl border border-zinc-200/80 dark:border-zinc-800 bg-white dark:bg-zinc-900 shadow-sm overflow-hidden transition-all duration-300">
      <div className="overflow-x-auto max-h-[650px] relative">
        <Table className="w-full text-left border-collapse">
          {/* Sticky Table Header */}
          <TableHeader className="bg-zinc-50/90 dark:bg-zinc-950/90 backdrop-blur-md sticky top-0 z-10 border-b border-zinc-200/80 dark:border-zinc-800">
            <TableRow className="hover:bg-transparent">
              {columns.map((col) => {
                const isSorted = sortField === col.key;
                return (
                  <TableHead
                    key={col.key}
                    className="h-11 px-4 text-xs font-bold text-zinc-600 dark:text-zinc-300 uppercase tracking-wider select-none whitespace-nowrap"
                  >
                    {col.sortable ? (
                      <button
                        onClick={() => handleSortClick(col.key)}
                        className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-50 transition-colors"
                      >
                        <span>{col.header}</span>
                        {isSorted ? (
                          sortDirection === 'asc' ? (
                            <ArrowUp className="h-3.5 w-3.5 text-rose-500" />
                          ) : (
                            <ArrowDown className="h-3.5 w-3.5 text-rose-500" />
                          )
                        ) : (
                          <ArrowUpDown className="h-3.5 w-3.5 text-zinc-400" />
                        )}
                      </button>
                    ) : (
                      <span>{col.header}</span>
                    )}
                  </TableHead>
                );
              })}
              {onViewDetails && (
                <TableHead className="h-11 px-4 text-xs font-bold text-zinc-600 dark:text-zinc-300 uppercase tracking-wider text-right whitespace-nowrap">
                  Actions
                </TableHead>
              )}
            </TableRow>
          </TableHeader>

          {/* Table Body */}
          <TableBody>
            {isLoading ? (
              // Loading Skeleton Rows
              Array.from({ length: 6 }).map((_, rIdx) => (
                <TableRow key={rIdx} className="animate-pulse border-b border-zinc-100 dark:border-zinc-850">
                  {columns.map((col, cIdx) => (
                    <TableCell key={cIdx} className="px-4 py-4">
                      <div className="h-4 bg-zinc-200/70 dark:bg-zinc-800 rounded-lg w-3/4" />
                    </TableCell>
                  ))}
                  {onViewDetails && (
                    <TableCell className="px-4 py-4 text-right">
                      <div className="h-8 w-16 bg-zinc-200/70 dark:bg-zinc-800 rounded-xl inline-block" />
                    </TableCell>
                  )}
                </TableRow>
              ))
            ) : data.length === 0 ? (
              // Empty State
              <TableRow>
                <TableCell
                  colSpan={columns.length + (onViewDetails ? 1 : 0)}
                  className="h-64 text-center py-12"
                >
                  <div className="flex flex-col items-center justify-center space-y-3">
                    <div className="p-4 bg-zinc-100 dark:bg-zinc-800/50 rounded-full text-zinc-400">
                      <Inbox className="h-8 w-8" />
                    </div>
                    <p className="text-sm font-semibold text-zinc-700 dark:text-zinc-300">
                      {emptyMessage}
                    </p>
                    <p className="text-xs text-zinc-400 max-w-sm">
                      Try adjusting your search criteria or resetting filters to find matching marketplace data.
                    </p>
                  </div>
                </TableCell>
              </TableRow>
            ) : (
              // Data Rows
              data.map((item) => (
                <TableRow
                  key={item.id}
                  className="hover:bg-zinc-50/80 dark:hover:bg-zinc-850/50 transition-colors border-b border-zinc-100 dark:border-zinc-850/60"
                >
                  {columns.map((col) => (
                    <TableCell key={col.key} className="px-4 py-3.5 text-sm text-zinc-700 dark:text-zinc-300 whitespace-nowrap">
                      {col.render ? col.render(item) : (item as any)[col.key] ?? 'N/A'}
                    </TableCell>
                  ))}
                  {onViewDetails && (
                    <TableCell className="px-4 py-3.5 text-right whitespace-nowrap">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => onViewDetails(item)}
                        className="h-8 px-3 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-rose-500 hover:bg-rose-500/10 hover:text-rose-600 gap-1.5 shadow-2xs"
                      >
                        <Eye className="h-3.5 w-3.5" />
                        View
                      </Button>
                    </TableCell>
                  )}
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
