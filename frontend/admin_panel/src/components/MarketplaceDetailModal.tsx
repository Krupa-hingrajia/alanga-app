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
import { User, Calendar, Mail, Tag, FolderTree, GitBranch, ShoppingBag, ShieldCheck, FileText, CheckCircle2, XCircle, Grid, DollarSign, Layers } from 'lucide-react';
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
  images?: Array<{
    id: string;
    imageUrl: string;
    isPrimary: boolean;
    displayOrder: number;
    productVariantId?: string | null;
  }>;
  variants?: Array<{
    id: string;
    sku: string;
    variantName: string;
    price: number;
    stock: number;
    status: string;
    color?: string;
    size?: string;
    storage?: string;
    attributes?: Record<string, string>;
    images?: Array<{
      id: string;
      imageUrl: string;
      isPrimary: boolean;
      displayOrder: number;
    }>;
  }>;
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

  // Group images into product common images (not linked to variants)
  const commonImages = item.images?.filter(img => !img.productVariantId || img.productVariantId.trim() === '') || [];

  // Get main display image for the header (look for primary in images, or fallback to first image, or item.image/logo)
  const getHeaderImage = () => {
    if (item.image && item.image.trim() !== '') return item.image;
    if (item.images && item.images.length > 0) {
      const primary = item.images.find(img => img.isPrimary);
      if (primary) return primary.imageUrl;
      return item.images[0].imageUrl;
    }
    if (item.logo && item.logo.trim() !== '') return item.logo;
    return null;
  };
  const headerImg = getHeaderImage();

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-[95vw] md:max-w-[90vw] w-[95vw] md:w-[90vw] h-[90vh] max-h-[90vh] overflow-y-auto rounded-3xl p-6 md:p-8 border-zinc-200 dark:border-zinc-800">
        <DialogHeader className="pb-4 border-b border-zinc-100 dark:border-zinc-900">
          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              {headerImg ? (
                <img
                  src={headerImg}
                  alt={item.name}
                  className="h-12 w-12 rounded-xl object-cover border border-zinc-200 dark:border-zinc-800 bg-white"
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

        {/* 2-Column Grid Layout */}
        <div className="grid grid-cols-1 md:grid-cols-12 gap-8 pt-4">
          
          {/* Left Column (65% width) - Gallery, Description & Variants */}
          <div className="md:col-span-8 space-y-6">
            
            {/* Common Image Gallery */}
            {commonImages.length > 0 && (
              <div className="space-y-2">
                <div className="flex items-center gap-2 text-xs font-semibold text-zinc-500">
                  <ShoppingBag className="h-3.5 w-3.5 text-rose-500" />
                  <span>Common Product Images ({commonImages.length})</span>
                </div>
                <div className="grid grid-cols-4 sm:grid-cols-5 md:grid-cols-6 gap-3 bg-zinc-50/50 dark:bg-zinc-900/40 p-4 rounded-2xl border border-zinc-100 dark:border-zinc-850">
                  {commonImages.map((img) => (
                    <div key={img.id} className="relative aspect-square rounded-xl overflow-hidden border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-950 group">
                      <img
                        src={img.imageUrl}
                        alt="Product common"
                        className="w-full h-full object-cover transition-transform group-hover:scale-105"
                      />
                      {img.isPrimary && (
                        <span className="absolute top-1 left-1 text-[8px] font-bold px-1.5 py-0.5 bg-emerald-500 text-white rounded-full uppercase tracking-wider">
                          Primary
                        </span>
                      )}
                    </div>
                  ))}
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

            {/* Variants Details Section */}
            {item.variants && item.variants.length > 0 && (
              <div className="space-y-3">
                <div className="flex items-center gap-2 text-xs font-semibold text-zinc-500">
                  <Layers className="h-3.5 w-3.5 text-indigo-500" />
                  <span>Product Variants ({item.variants.length})</span>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {item.variants.map((v) => {
                    const varImages = v.images || [];
                    const allAttributes = {
                      ...(v.color ? { Color: v.color } : {}),
                      ...(v.size ? { Size: v.size } : {}),
                      ...(v.storage ? { Storage: v.storage } : {}),
                      ...(v.attributes || {}),
                    };

                    return (
                      <Card key={v.id} className="border border-zinc-200 dark:border-zinc-800 shadow-sm rounded-2xl overflow-hidden bg-white dark:bg-zinc-950">
                        <CardContent className="p-4 space-y-3.5">
                          <div className="flex items-start justify-between gap-4">
                            <div>
                              <h4 className="text-sm font-bold text-zinc-800 dark:text-zinc-100">
                                {v.variantName}
                              </h4>
                              <p className="text-[10px] font-mono text-zinc-400 mt-0.5">
                                SKU: {v.sku}
                              </p>
                            </div>
                            <StatusBadge status={v.status} className="text-[10px] px-2 py-0.5" />
                          </div>

                          <div className="grid grid-cols-2 gap-2 bg-zinc-50 dark:bg-zinc-900/60 p-3 rounded-xl text-xs border border-zinc-100 dark:border-zinc-850">
                            <div>
                              <span className="text-zinc-400 font-medium">Price:</span>{' '}
                              <strong className="text-emerald-600 dark:text-emerald-400 font-semibold">₹{v.price}</strong>
                            </div>
                            <div>
                              <span className="text-zinc-400 font-medium">Stock:</span>{' '}
                              <strong className="text-zinc-800 dark:text-zinc-200 font-semibold">{v.stock} units</strong>
                            </div>
                          </div>

                          {Object.keys(allAttributes).length > 0 && (
                            <div className="space-y-1">
                              <p className="text-[10px] font-semibold text-zinc-450 uppercase tracking-wider">Attributes</p>
                              <div className="flex flex-wrap gap-1.5">
                                {Object.entries(allAttributes).map(([key, value]) => (
                                  <span key={key} className="px-2 py-0.5 bg-zinc-100 dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300 rounded-md text-[10px] font-medium border border-zinc-200 dark:border-zinc-800">
                                    {key}: <strong className="font-semibold text-zinc-900 dark:text-zinc-100">{value}</strong>
                                  </span>
                                ))}
                              </div>
                            </div>
                          )}

                          {varImages.length > 0 && (
                            <div className="space-y-1.5">
                              <p className="text-[10px] font-semibold text-zinc-450 uppercase tracking-wider">Variant Images ({varImages.length})</p>
                              <div className="flex gap-2 flex-wrap">
                                {varImages.map((img) => (
                                  <div key={img.id} className="relative h-12 w-12 rounded-lg overflow-hidden border border-zinc-200 dark:border-zinc-800 bg-zinc-100 dark:bg-zinc-900 group">
                                    <img
                                      src={img.imageUrl}
                                      alt="variant gallery"
                                      className="w-full h-full object-cover transition-transform group-hover:scale-110"
                                    />
                                    {img.isPrimary && (
                                      <span className="absolute top-0.5 right-0.5 h-2 w-2 bg-emerald-500 rounded-full border border-white" />
                                    )}
                                  </div>
                                ))}
                              </div>
                            </div>
                          )}
                        </CardContent>
                      </Card>
                    );
                  })}
                </div>
              </div>
            )}

          </div>

          {/* Right Column (35% width) - Stats, Brand/Category, Vendor & Audit */}
          <div className="md:col-span-4 space-y-6">
            
            {/* Prices & Stock (if product) */}
            {(item.mrp !== undefined || item.sellingPrice !== undefined) && (
              <div className="grid grid-cols-2 gap-4 p-4 rounded-2xl bg-zinc-50 dark:bg-zinc-900/60 border border-zinc-100 dark:border-zinc-850">
                <div>
                  <p className="text-xs font-medium text-zinc-400">MRP</p>
                  <p className="text-base font-bold text-zinc-400 line-through">₹{item.mrp}</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-zinc-400">Selling Price</p>
                  <p className="text-lg font-extrabold text-emerald-600 dark:text-emerald-400">
                    ₹{item.sellingPrice}
                  </p>
                </div>
                <div className="col-span-2 pt-2 border-t border-zinc-150 dark:border-zinc-800">
                  <p className="text-xs font-medium text-zinc-400">Available Stock</p>
                  <p className="text-base font-bold text-zinc-800 dark:text-zinc-200">
                    {item.stock ?? 0} units
                  </p>
                </div>
              </div>
            )}

            {/* Hierarchy Details (Category, SubCategory, Brand) */}
            {(item.category || item.subCategory || item.brand) && (
              <div className="space-y-3 p-4 rounded-2xl bg-zinc-50 dark:bg-zinc-900/50 border border-zinc-100 dark:border-zinc-850">
                <div className="flex items-center gap-2 text-xs font-semibold text-zinc-500">
                  <Grid className="h-3.5 w-3.5 text-indigo-500" />
                  <span>Product Classifications</span>
                </div>
                <div className="space-y-2.5 pt-1">
                  {item.category && (
                    <div className="flex justify-between items-center text-xs">
                      <span className="text-zinc-400 font-medium">Category:</span>
                      <span className="font-semibold text-zinc-800 dark:text-zinc-200">
                        {item.category.name}
                      </span>
                    </div>
                  )}
                  {item.subCategory && (
                    <div className="flex justify-between items-center text-xs">
                      <span className="text-zinc-400 font-medium">Sub Category:</span>
                      <span className="font-semibold text-zinc-800 dark:text-zinc-200">
                        {item.subCategory.name}
                      </span>
                    </div>
                  )}
                  {item.brand && (
                    <div className="flex justify-between items-center text-xs">
                      <span className="text-zinc-400 font-medium">Brand:</span>
                      <span className="font-semibold text-zinc-800 dark:text-zinc-200">
                        {item.brand.name}
                      </span>
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* Vendor Information Card */}
            <div className="space-y-2">
              <div className="flex items-center gap-2 text-xs font-semibold text-zinc-500">
                <User className="h-3.5 w-3.5 text-rose-500" />
                <span>Vendor Information</span>
              </div>
              <div className="p-4 rounded-2xl bg-rose-500/5 border border-rose-500/10 space-y-2.5">
                <div className="text-xs">
                  <p className="text-zinc-400">Vendor Name</p>
                  <p className="text-sm font-bold text-zinc-800 dark:text-zinc-200">
                    {displayVendorName}
                  </p>
                </div>
                <div className="text-xs">
                  <p className="text-zinc-400">Vendor Email</p>
                  <p className="text-sm font-medium text-zinc-800 dark:text-zinc-200 break-all">
                    {displayVendorEmail}
                  </p>
                </div>
                <div className="text-[10px]">
                  <p className="text-zinc-400">Vendor ID</p>
                  <p className="font-mono text-zinc-600 dark:text-zinc-400 truncate">
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
                <div className="space-y-2 text-xs">
                  <div className="flex justify-between">
                    <span className="text-zinc-400">Created:</span>{' '}
                    <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                      {formatDate(item.createdAt)}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-zinc-400">Last Updated:</span>{' '}
                    <span className="font-semibold text-zinc-700 dark:text-zinc-300">
                      {formatDate(item.updatedAt)}
                    </span>
                  </div>
                </div>

                {item.approvedAt && (
                  <div className="flex items-start gap-2 pt-2 border-t border-zinc-200/60 dark:border-zinc-800 text-xs">
                    <CheckCircle2 className="h-4 w-4 text-emerald-500 shrink-0 mt-0.5" />
                    <span className="text-zinc-600 dark:text-zinc-400 leading-normal">
                      Approved on{' '}
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

        </div>
      </DialogContent>
    </Dialog>
  );
}
