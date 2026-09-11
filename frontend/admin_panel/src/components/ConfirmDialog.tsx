'use client';

import React from 'react';
import { AlertTriangle, AlertCircle, Info, Loader2 } from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';

export interface ConfirmDialogProps {
  open: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string;
  description?: string | React.ReactNode;
  confirmText?: string;
  cancelText?: string;
  variant?: 'destructive' | 'primary' | 'warning';
  isLoading?: boolean;
}

export function ConfirmDialog({
  open,
  onClose,
  onConfirm,
  title,
  description,
  confirmText = 'Confirm',
  cancelText = 'Cancel',
  variant = 'destructive',
  isLoading = false,
}: ConfirmDialogProps) {
  const getIcon = () => {
    switch (variant) {
      case 'destructive':
        return (
          <div className="p-2.5 rounded-full bg-rose-100 text-rose-600 dark:bg-rose-900/30 dark:text-rose-400 shrink-0">
            <AlertCircle className="h-6 w-6" />
          </div>
        );
      case 'warning':
        return (
          <div className="p-2.5 rounded-full bg-amber-100 text-amber-600 dark:bg-amber-900/30 dark:text-amber-400 shrink-0">
            <AlertTriangle className="h-6 w-6" />
          </div>
        );
      case 'primary':
      default:
        return (
          <div className="p-2.5 rounded-full bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-400 shrink-0">
            <Info className="h-6 w-6" />
          </div>
        );
    }
  };

  const getConfirmButtonClasses = () => {
    switch (variant) {
      case 'destructive':
        return 'bg-rose-600 hover:bg-rose-700 text-white shadow-sm';
      case 'warning':
        return 'bg-amber-600 hover:bg-amber-700 text-white shadow-sm';
      case 'primary':
      default:
        return 'bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs';
    }
  };

  return (
    <Dialog open={open} onOpenChange={(val) => !val && !isLoading && onClose()}>
      <DialogContent className="sm:max-w-[440px] rounded-2xl p-6">
        <div className="flex items-start gap-4">
          {getIcon()}
          <div className="space-y-1.5 flex-1">
            <DialogHeader className="p-0 text-left">
              <DialogTitle className="text-base font-bold text-zinc-900 dark:text-zinc-50">
                {title}
              </DialogTitle>
            </DialogHeader>
            {description && (
              <DialogDescription className="text-xs text-zinc-500 dark:text-zinc-400 leading-relaxed">
                {description}
              </DialogDescription>
            )}
          </div>
        </div>

        <DialogFooter className="mt-6 flex flex-row justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-850">
          <Button
            type="button"
            variant="outline"
            onClick={onClose}
            disabled={isLoading}
            className="rounded-xl h-9 px-4 text-xs font-semibold border-zinc-200 dark:border-zinc-800"
          >
            {cancelText}
          </Button>
          <Button
            type="button"
            onClick={onConfirm}
            disabled={isLoading}
            className={`rounded-xl h-9 px-4 text-xs font-semibold ${getConfirmButtonClasses()}`}
          >
            {isLoading && <Loader2 className="h-3.5 w-3.5 mr-1.5 animate-spin" />}
            {confirmText}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
