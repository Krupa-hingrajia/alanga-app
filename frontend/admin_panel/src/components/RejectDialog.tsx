'use client';

import React, { useState } from 'react';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Loader2, XCircle } from 'lucide-react';

interface RejectDialogProps {
  open: boolean;
  onClose: () => void;
  onConfirm: (reason: string) => void;
  isPending?: boolean;
  title?: string;
  description?: string;
}

export function RejectDialog({
  open,
  onClose,
  onConfirm,
  isPending = false,
  title = 'Reject Submission',
  description = 'Please provide a reason for rejection. This will be communicated to the vendor.',
}: RejectDialogProps) {
  const [reason, setReason] = useState('');

  const handleConfirm = () => {
    if (!reason.trim()) return;
    onConfirm(reason.trim());
  };

  return (
    <Dialog open={open} onOpenChange={(v) => { if (!v) onClose(); }}>
      <DialogContent className="sm:max-w-md border border-zinc-200/60 dark:border-zinc-800/60 bg-white dark:bg-zinc-950">
        <DialogHeader>
          <div className="flex items-center gap-3 mb-1">
            <div className="p-2 bg-rose-100 dark:bg-rose-900/30 rounded-xl">
              <XCircle className="h-5 w-5 text-rose-600 dark:text-rose-400" />
            </div>
            <DialogTitle className="text-zinc-900 dark:text-zinc-50">{title}</DialogTitle>
          </div>
          <DialogDescription className="text-zinc-500 dark:text-zinc-400 pl-[3.25rem]">
            {description}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-2 py-2">
          <Label htmlFor="reject-reason" className="text-sm font-medium text-zinc-700 dark:text-zinc-300">
            Rejection Reason <span className="text-rose-500">*</span>
          </Label>
          <textarea
            id="reject-reason"
            rows={4}
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder="e.g. Category already exists, inappropriate content, incomplete information..."
            className="w-full rounded-xl border border-zinc-200 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-900/50 px-3 py-2 text-sm text-zinc-900 dark:text-zinc-50 placeholder:text-zinc-400 resize-none focus:outline-none focus:ring-2 focus:ring-rose-500/50 focus:border-rose-500 transition-all"
            disabled={isPending}
          />
          {reason.trim() === '' && (
            <p className="text-xs text-zinc-400 dark:text-zinc-500">Rejection reason is required.</p>
          )}
        </div>

        <DialogFooter className="gap-2">
          <Button
            variant="outline"
            onClick={onClose}
            disabled={isPending}
            className="rounded-xl border-zinc-200 dark:border-zinc-800"
          >
            Cancel
          </Button>
          <Button
            onClick={handleConfirm}
            disabled={isPending || !reason.trim()}
            className="rounded-xl bg-rose-500 hover:bg-rose-600 text-white font-semibold"
          >
            {isPending ? (
              <><Loader2 className="mr-2 h-4 w-4 animate-spin" /> Rejecting...</>
            ) : (
              'Confirm Reject'
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
