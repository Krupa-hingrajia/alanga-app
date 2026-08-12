import React from 'react';
import { Badge } from '@/components/ui/badge';

interface StatusBadgeProps {
  status: string;
  className?: string;
}

const STATUS_STYLES: Record<string, string> = {
  PENDING:   'bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-400 border-amber-200 dark:border-amber-800',
  ACTIVE:    'bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-400 border-emerald-200 dark:border-emerald-800',
  REJECTED:  'bg-rose-100 text-rose-800 dark:bg-rose-900/30 dark:text-rose-400 border-rose-200 dark:border-rose-800',
  SUSPENDED: 'bg-zinc-100 text-zinc-700 dark:bg-zinc-800/60 dark:text-zinc-400 border-zinc-200 dark:border-zinc-700',
  DRAFT:     'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400 border-blue-200 dark:border-blue-800',
};

export function StatusBadge({ status, className }: StatusBadgeProps) {
  const style = STATUS_STYLES[status] ?? STATUS_STYLES['SUSPENDED'];
  return (
    <Badge
      variant="outline"
      className={`text-xs font-semibold px-2.5 py-0.5 rounded-full border ${style} ${className ?? ''}`}
    >
      {status}
    </Badge>
  );
}
