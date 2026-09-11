'use client';

import React from 'react';
import { ArrowUpDown, ArrowUp, ArrowDown, Eye, Edit, Trash2, Inbox } from 'lucide-react';
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
  className?: string;
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
  onEdit?: (item: T) => void;
  onDelete?: (item: T) => void;
  renderActions?: (item: T) => React.ReactNode;
  actionsHeader?: string;
  emptyMessage?: string;
  emptySubMessage?: string;
}

export function MarketplaceTable<T extends { id: string; status?: string }>({
  columns,
  data,
  isLoading = false,
  sortField,
  sortDirection,
  onSort,
  onViewDetails,
  onEdit,
  onDelete,
  renderActions,
  actionsHeader = 'Actions',
  emptyMessage = 'No records found matching your filters.',
  emptySubMessage = 'Try adjusting your search criteria or resetting filters.',
}: MarketplaceTableProps<T>) {
  const hasActions = Boolean(onViewDetails || onEdit || onDelete || renderActions);

  const handleSortClick = (columnKey: string) => {
    if (onSort) {
      onSort(columnKey);
    }
  };

  return (
    <div className="relative rounded-2xl border border-zinc-200/80 dark:border-zinc-800 bg-white dark:bg-zinc-950 shadow-sm overflow-hidden transition-all duration-300">
      <div className="overflow-x-auto max-h-[700px] relative">
        <Table className="w-full text-left border-collapse">
          {/* Sticky Table Header */}
          <TableHeader className="bg-zinc-50/90 dark:bg-zinc-900/90 backdrop-blur-md sticky top-0 z-10 border-b border-zinc-200/80 dark:border-zinc-800">
            <TableRow className="hover:bg-transparent">
              {columns.map((col) => {
                const isSorted = sortField === col.key;
                return (
                  <TableHead
                    key={col.key}
                    className={`h-11 px-4 text-xs font-bold text-zinc-600 dark:text-zinc-300 uppercase tracking-wider select-none whitespace-nowrap ${col.className || ''}`}
                  >
                    {col.sortable ? (
                      <button
                        onClick={() => handleSortClick(col.key)}
                        className="flex items-center gap-1.5 hover:text-zinc-900 dark:hover:text-zinc-50 transition-colors cursor-pointer"
                      >
                        <span>{col.header}</span>
                        {isSorted ? (
                          sortDirection === 'asc' ? (
                            <ArrowUp className="h-3.5 w-3.5 text-emerald-600 dark:text-emerald-400" />
                          ) : (
                            <ArrowDown className="h-3.5 w-3.5 text-emerald-600 dark:text-emerald-400" />
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
              {hasActions && (
                <TableHead className="h-11 px-4 text-xs font-bold text-zinc-600 dark:text-zinc-300 uppercase tracking-wider text-right whitespace-nowrap">
                  {actionsHeader}
                </TableHead>
              )}
            </TableRow>
          </TableHeader>

          {/* Table Body */}
          <TableBody>
            {isLoading ? (
              // Loading Skeleton Rows
              Array.from({ length: 6 }).map((_, rIdx) => (
                <TableRow key={rIdx} className="animate-pulse border-b border-zinc-100 dark:border-zinc-900">
                  {columns.map((col, cIdx) => (
                    <TableCell key={cIdx} className="px-4 py-4">
                      <div className="h-4 bg-zinc-200/70 dark:bg-zinc-800 rounded-lg w-3/4" />
                    </TableCell>
                  ))}
                  {hasActions && (
                    <TableCell className="px-4 py-4 text-right">
                      <div className="h-8 w-20 bg-zinc-200/70 dark:bg-zinc-800 rounded-xl inline-block" />
                    </TableCell>
                  )}
                </TableRow>
              ))
            ) : data.length === 0 ? (
              // Empty State
              <TableRow>
                <TableCell
                  colSpan={columns.length + (hasActions ? 1 : 0)}
                  className="h-64 text-center py-12"
                >
                  <div className="flex flex-col items-center justify-center space-y-3">
                    <div className="p-4 bg-zinc-100 dark:bg-zinc-850 rounded-full text-zinc-400 dark:text-zinc-500">
                      <Inbox className="h-8 w-8" />
                    </div>
                    <p className="text-sm font-semibold text-zinc-800 dark:text-zinc-200">
                      {emptyMessage}
                    </p>
                    <p className="text-xs text-zinc-400 max-w-sm">
                      {emptySubMessage}
                    </p>
                  </div>
                </TableCell>
              </TableRow>
            ) : (
              // Data Rows
              data.map((item) => (
                <TableRow
                  key={item.id}
                  className="hover:bg-zinc-50/80 dark:hover:bg-zinc-900/50 transition-colors border-b border-zinc-100 dark:border-zinc-900"
                >
                  {columns.map((col) => (
                    <TableCell key={col.key} className={`px-4 py-3.5 text-sm text-zinc-700 dark:text-zinc-300 whitespace-nowrap ${col.className || ''}`}>
                      {col.render ? col.render(item) : (item as any)[col.key] ?? 'N/A'}
                    </TableCell>
                  ))}
                  {hasActions && (
                    <TableCell className="px-4 py-3.5 text-right whitespace-nowrap">
                      {renderActions ? (
                        renderActions(item)
                      ) : (
                        <div className="flex items-center justify-end gap-1.5">
                          {onViewDetails && (
                            <Button
                              variant="outline"
                              size="sm"
                              title="View Details"
                              onClick={() => onViewDetails(item)}
                              className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                            >
                              <Eye className="h-3.5 w-3.5 text-zinc-500" />
                              View
                            </Button>
                          )}
                          {onEdit && (
                            <Button
                              variant="outline"
                              size="sm"
                              title="Edit Record"
                              onClick={() => onEdit(item)}
                              className="h-8 px-2.5 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs font-semibold text-zinc-700 dark:text-zinc-300 hover:bg-zinc-100 dark:hover:bg-zinc-800 gap-1.5"
                            >
                              <Edit className="h-3.5 w-3.5 text-blue-500" />
                              Edit
                            </Button>
                          )}
                          {onDelete && (
                            <Button
                              variant="outline"
                              size="sm"
                              title="Delete Record"
                              onClick={() => onDelete(item)}
                              className="h-8 px-2.5 rounded-xl border-rose-200 dark:border-rose-900/50 text-xs font-semibold text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/30 gap-1.5"
                            >
                              <Trash2 className="h-3.5 w-3.5" />
                              Delete
                            </Button>
                          )}
                        </div>
                      )}
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

