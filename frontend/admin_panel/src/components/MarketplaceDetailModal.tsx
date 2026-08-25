'use client';

import React from 'react';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from '@/components/ui/dialog';
import { StatusBadge } from '@/components/StatusBadge';
import { User, Calendar, Mail, Tag, FolderTree, GitBranch, ShoppingBag, ShieldCheck, FileText, CheckCircle2, XCircle } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';

export interface DetailItem {
  id: string;
  name: string;
  description?: string;
  shortDescription?: string;
  image?: string;
  logo?: string;
  sku?: string;
  mrp?: number;
  sellingPrice?: number;
  stock?: number;
  taxPercentage?: number;
  status: string;
  createdAt: string;
  updatedAt: string;
  approvedAt?: string;
  approvedByAdminId?: string;
  rejectedReason?: string;
  category?: { id: string; name: string };
  subCategory?: { id: string; name: string };
  brand?: { id: string; name: string; logo?: string };
  vendorId?: string;
  vendorName?: string;
  vendorEmail?: string;
  vendor?: {
    id: string;
    name: string;
    email: string;
  };
}

interface MarketplaceDetailModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  item: DetailItem | null;
}

export function MarketplaceDetailModal({
  open,
  onOpenChange,
  title,
  item,
}: MarketplaceDetailModalProps) {
  if (!item) return null;

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return 'N/A';
    try {
      return new Date(dateStr).toLocaleString('en-US', {
        dateStyle: 'medium',
        timeStyle: 'short',
      });
    } catch {
      return dateStr;
    }
  };

  const displayVendorName = item.vendorName || item.vendor?.name || 'N/A';
  const displayVendorEmail = item.vendorEmail || item.vendor?.email || 'N/A';
  const displayVendorId = item.vendorId || item.vendor?.id || 'N/A';

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl max-h-[85vh] overflow-y-auto rounded-3xl p-6 border-zinc-200 dark:border-zinc-800">
        <DialogHeader className="pb-4 border-b border-zinc-100 dark:border-zinc-900">
          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              {(item.image || item.logo) ? (
                <img
                  src={item.image || item.logo}
                  alt={item.name}
                  className="h-12 w-12 rounded-xl object-cover border border-zinc-200 dark:border-zinc-800"
                />
              ) : (
                <div className="p-3 bg-rose-500/10 text-rose-500 rounded-2xl">
                  <ShoppingBag className="h-6 w-6" />
                </div>
              )}
              <div>
                <DialogTitle className="text-xl font-bold text-zinc-900 dark:text-zinc-50">
                  {item.name}
                </DialogTitle>
                {item.sku && (
                  <DialogDescription className="text-xs font-mono text-zinc-500 mt-0.5">
                    SKU: {item.sku}
                  </DialogDescription>
                )}
              </div>
            </div>
            <StatusBadge status={item.status} className="text-sm px-3 py-1" />
          </div>
        </DialogHeader>

        <div className="space-y-6 pt-4">
          {/* Prices & Stock (if product) */}
          {(item.mrp !== undefined || item.sellingPrice !== undefined) && (
            <div className="grid grid-cols-3 gap-4 p-4 rounded-2xl bg-zinc-50 dark:bg-zinc-900/60 border border-zinc-100 dark:border-zinc-850">
              <div>
                <p className="text-xs font-medium text-zinc-400">MRP</p>
                <p className="text-lg font-bold text-zinc-500 line-through">₹{item.mrp}</p>
              </div>
              <div>
                <p className="text-xs font-medium text-zinc-400">Selling Price</p>
                <p className="text-xl font-extrabold text-emerald-600 dark:text-emerald-400">
                  ₹{item.sellingPrice}
                </p>
              </div>
              <div>
                <p className="text-xs font-medium text-zinc-400">Available Stock</p>
                <p className="text-lg font-bold text-zinc-800 dark:text-zinc-200">
                  {item.stock ?? 0} units
                </p>
              </div>
            </div>
          )}

          {/* Description */}
          {item.description && (
            <div className="space-y-1.5">
              <div className="flex items-center gap-2 text-xs font-semibold text-zinc-500">
                <FileText className="h-3.5 w-3.5" />
                <span>Description</span>
              </div>
              <p className="text-sm text-zinc-700 dark:text-zinc-300 bg-zinc-50/50 dark:bg-zinc-900/40 p-3.5 rounded-xl border border-zinc-100 dark:border-zinc-850 leading-relaxed">
                {item.description}
              </p>
            </div>
          )}

          {/* Hierarchy Details (Category, SubCategory, Brand) */}
          {(item.category || item.subCategory || item.brand) && (
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              {item.category && (
                <div className="p-3.5 rounded-xl bg-zinc-50 dark:bg-zinc-900/50 border border-zinc-100 dark:border-zinc-850 space-y-1">
                  <div className="flex items-center gap-1.5 text-xs font-medium text-zinc-400">
                    <FolderTree className="h-3.5 w-3.5 text-rose-500" />
                    <span>Category</span>
                  </div>
                  <p className="text-sm font-semibold text-zinc-900 dark:text-zinc-100">
                    {item.category.name}
                  </p>
                </div>
              )}

              {item.subCategory && (
                <div className="p-3.5 rounded-xl bg-zinc-50 dark:bg-zinc-900/50 border border-zinc-100 dark:border-zinc-850 space-y-1">
                  <div className="flex items-center gap-1.5 text-xs font-medium text-zinc-400">
                    <GitBranch className="h-3.5 w-3.5 text-indigo-500" />
                    <span>Sub Category</span>
                  </div>
                  <p className="text-sm font-semibold text-zinc-900 dark:text-zinc-100">
                    {item.subCategory.name}
                  </p>
                </div>
              )}

              {item.brand && (
                <div className="p-3.5 rounded-xl bg-zinc-50 dark:bg-zinc-900/50 border border-zinc-100 dark:border-zinc-850 space-y-1">
                  <div className="flex items-center gap-1.5 text-xs font-medium text-zinc-400">
                    <Tag className="h-3.5 w-3.5 text-amber-500" />
                    <span>Brand</span>
                  </div>
                  <p className="text-sm font-semibold text-zinc-900 dark:text-zinc-100">
                    {item.brand.name}
                  </p>
                </div>
              )}
            </div>
          )}

          {/* Vendor Information Card */}
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-xs font-semibold text-zinc-500">
              <User className="h-3.5 w-3.5 text-rose-500" />
              <span>Vendor Information</span>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 p-3.5 rounded-2xl bg-rose-500/5 border border-rose-500/10">
              <div>
                <p className="text-xs text-zinc-400">Vendor Name</p>
                <p className="text-sm font-bold text-zinc-800 dark:text-zinc-200">
                  {displayVendorName}
                </p>
              </div>
              <div>
                <p className="text-xs text-zinc-400">Vendor Email</p>
                <p className="text-sm font-medium text-zinc-800 dark:text-zinc-200">
                  {displayVendorEmail}
                </p>
              </div>
              <div>
                <p className="text-xs text-zinc-400">Vendor ID</p>
                <p className="text-xs font-mono text-zinc-600 dark:text-zinc-400 truncate">
                  {displayVendorId}
                </p>
              </div>
            </div>
          </div>

          {/* Approval History & Status Details */}
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-xs font-semibold text-zinc-500">
              <ShieldCheck className="h-3.5 w-3.5 text-emerald-500" />
              <span>Approval & Audit History</span>
            </div>
            <div className="p-4 rounded-2xl bg-zinc-50 dark:bg-zinc-900/50 border border-zinc-100 dark:border-zinc-850 space-y-3">
              <div className="grid grid-cols-2 gap-4 text-xs">
                <div>
                  <span className="text-zinc-400">Created Date:</span>{' '}
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {formatDate(item.createdAt)}
                  </span>
                </div>
                <div>
                  <span className="text-zinc-400">Updated Date:</span>{' '}
                  <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                    {formatDate(item.updatedAt)}
                  </span>
                </div>
              </div>

              {item.approvedAt && (
                <div className="flex items-center gap-2 pt-2 border-t border-zinc-200/60 dark:border-zinc-800 text-xs">
                  <CheckCircle2 className="h-4 w-4 text-emerald-500" />
                  <span className="text-zinc-600 dark:text-zinc-400">
                    Approved at{' '}
                    <strong className="text-zinc-900 dark:text-zinc-100">
                      {formatDate(item.approvedAt)}
                    </strong>
                    {item.approvedByAdminId && ` by Admin (${item.approvedByAdminId})`}
                  </span>
                </div>
              )}

              {item.rejectedReason && (
                <div className="flex items-start gap-2 pt-2 border-t border-rose-200 dark:border-rose-900/40 text-xs text-rose-600 dark:text-rose-400">
                  <XCircle className="h-4 w-4 shrink-0 mt-0.5" />
                  <div>
                    <span className="font-semibold">Rejection Reason:</span>{' '}
                    <span>{item.rejectedReason}</span>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
