'use client';

import React, { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { CheckCircle, XCircle, AlertCircle, RefreshCw, Inbox } from 'lucide-react';

import { StatusBadge } from '@/components/StatusBadge';
import { RejectDialog } from '@/components/RejectDialog';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';

interface ApprovalItem {
  id: string;
  name: string;
  description?: string;
  status: string;
  rejectedReason?: string;
  createdAt: string;
  [key: string]: any;
}

interface ApprovalTableProps {
  items: ApprovalItem[];
  isLoading: boolean;
  isError: boolean;
  isFetching: boolean;
  refetch: () => void;
  queryKeys: string[];
  approveFn: (id: string) => Promise<any>;
  rejectFn: (args: { id: string; reason: string }) => Promise<any>;
  entityLabel: string;
  extraFields?: { label: string; key: string }[];
}

export function ApprovalTable({
  items,
  isLoading,
  isError,
  isFetching,
  refetch,
  queryKeys,
  approveFn,
  rejectFn,
  entityLabel,
  extraFields = [],
}: ApprovalTableProps) {
  const queryClient = useQueryClient();
  const [rejectTarget, setRejectTarget] = useState<string | null>(null);

  const approveMutation = useMutation({
    mutationFn: approveFn,
    onSuccess: () => {
      toast.success(`${entityLabel} approved successfully`);
      queryKeys.forEach((k) => queryClient.invalidateQueries({ queryKey: [k] }));
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Approval failed'),
  });

  const rejectMutation = useMutation({
    mutationFn: rejectFn,
    onSuccess: () => {
      toast.success(`${entityLabel} rejected`);
      setRejectTarget(null);
      queryKeys.forEach((k) => queryClient.invalidateQueries({ queryKey: [k] }));
      queryClient.invalidateQueries({ queryKey: ['dashboardSummary'] });
    },
    onError: (e: any) => toast.error(e.response?.data?.message || 'Rejection failed'),
  });

  if (isLoading) {
    return (
      <div className="space-y-3">
        {Array.from({ length: 5 }).map((_, i) => (
          <div key={i} className="h-20 rounded-2xl bg-zinc-200 dark:bg-zinc-800 animate-pulse" />
        ))}
      </div>
    );
  }

  if (isError) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[40vh] border border-dashed border-zinc-200 dark:border-zinc-800 rounded-3xl">
        <AlertCircle className="h-10 w-10 text-rose-500 mb-3" />
        <p className="font-semibold text-zinc-900 dark:text-zinc-50">Failed to load data</p>
        <Button onClick={refetch} className="mt-4 bg-rose-500 hover:bg-rose-600 text-white rounded-xl">
          Retry
        </Button>
      </div>
    );
  }

  if (items.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[40vh] border border-dashed border-zinc-200 dark:border-zinc-800 rounded-3xl gap-3">
        <div className="p-4 bg-emerald-100 dark:bg-emerald-900/30 rounded-2xl">
          <Inbox className="h-8 w-8 text-emerald-600 dark:text-emerald-400" />
        </div>
        <p className="font-semibold text-zinc-700 dark:text-zinc-300">All Clear!</p>
        <p className="text-sm text-zinc-500 dark:text-zinc-400">No pending {entityLabel.toLowerCase()} submissions right now.</p>
      </div>
    );
  }

  return (
    <>
      <div className="flex justify-end mb-3">
        <Button
          variant="outline"
          size="sm"
          onClick={refetch}
          disabled={isFetching}
          className="h-9 px-3 rounded-xl border-zinc-200 dark:border-zinc-800 text-xs"
        >
          <RefreshCw className={`h-3.5 w-3.5 mr-1.5 ${isFetching ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      <div className="space-y-3">
        {items.map((item) => (
          <Card
            key={item.id}
            className="border border-zinc-200/60 dark:border-zinc-800/60 hover:shadow-md transition-all duration-200"
          >
            <CardContent className="p-4">
              <div className="flex items-start justify-between gap-4">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1 flex-wrap">
                    <h3 className="font-semibold text-sm text-zinc-900 dark:text-zinc-50">{item.name}</h3>
                    <StatusBadge status={item.status} />
                  </div>
                  {item.description && (
                    <p className="text-xs text-zinc-500 dark:text-zinc-400 line-clamp-1 mb-2">{item.description}</p>
                  )}
                  <div className="flex flex-wrap gap-x-4 gap-y-1 text-xs text-zinc-400 dark:text-zinc-500">
                    {extraFields.map((f) => item[f.key] && (
                      <span key={f.key}><span className="font-medium text-zinc-500 dark:text-zinc-400">{f.label}:</span> {item[f.key]}</span>
                    ))}
                    <span>Submitted: {new Date(item.createdAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })}</span>
                  </div>
                  {item.rejectedReason && (
                    <div className="mt-2 px-3 py-1.5 rounded-lg bg-rose-50 dark:bg-rose-900/20 border border-rose-100 dark:border-rose-900 text-xs text-rose-700 dark:text-rose-400">
                      <span className="font-semibold">Rejection Reason:</span> {item.rejectedReason}
                    </div>
                  )}
                </div>

                {item.status === 'PENDING' && (
                  <div className="flex gap-2 shrink-0">
                    <Button
                      size="sm"
                      onClick={() => approveMutation.mutate(item.id)}
                      disabled={approveMutation.isPending}
                      className="h-8 px-3 text-xs rounded-lg bg-emerald-500 hover:bg-emerald-600 text-white font-semibold"
                    >
                      <CheckCircle className="h-3.5 w-3.5 mr-1" />
                      Approve
                    </Button>
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => setRejectTarget(item.id)}
                      disabled={rejectMutation.isPending}
                      className="h-8 px-3 text-xs rounded-lg border-rose-200 dark:border-rose-800 text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-900/20 font-semibold"
                    >
                      <XCircle className="h-3.5 w-3.5 mr-1" />
                      Reject
                    </Button>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <RejectDialog
        open={!!rejectTarget}
        onClose={() => setRejectTarget(null)}
        onConfirm={(reason) => rejectTarget && rejectMutation.mutate({ id: rejectTarget, reason })}
        isPending={rejectMutation.isPending}
        title={`Reject ${entityLabel}`}
      />
    </>
  );
}
