'use client';

import React, { useState, useEffect } from 'react';
import {
  Search,
  Filter,
  X,
  Calendar,
  RotateCcw,
  SlidersHorizontal,
  ChevronDown,
  ChevronUp,
} from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Label } from '@/components/ui/label';

export interface MarketplaceFilterState {
  search?: string;
  status?: string;
  vendorId?: string;
  categoryId?: string;
  subCategoryId?: string;
  brandId?: string;
  createdFrom?: string;
  createdTo?: string;
  updatedFrom?: string;
  updatedTo?: string;
  sort?: string;
  limit?: number;
  page?: number;
}

interface MarketplaceFilterProps {
  filters: MarketplaceFilterState;
  onFilterChange: (filters: MarketplaceFilterState) => void;
  onReset: () => void;
  showCategory?: boolean;
  showSubCategory?: boolean;
  showBrand?: boolean;
  categories?: { id: string; name: string }[];
  subCategories?: { id: string; name: string }[];
  brands?: { id: string; name: string }[];
  vendors?: { id: string; fullName: string; businessName?: string; email: string }[];
  sortOptions?: { label: string; value: string }[];
}

export function MarketplaceFilter({
  filters,
  onFilterChange,
  onReset,
  showCategory = false,
  showSubCategory = false,
  showBrand = false,
  categories = [],
  subCategories = [],
  brands = [],
  vendors = [],
  sortOptions = [
    { label: 'Newest First', value: 'createdAt_desc' },
    { label: 'Oldest First', value: 'createdAt_asc' },
    { label: 'Name (A-Z)', value: 'name_asc' },
    { label: 'Name (Z-A)', value: 'name_desc' },
    { label: 'Price (Low to High)', value: 'sellingPrice_asc' },
    { label: 'Price (High to Low)', value: 'sellingPrice_desc' },
  ],
}: MarketplaceFilterProps) {
  const [expanded, setExpanded] = useState(false);
  const [searchTerm, setSearchTerm] = useState(filters.search || '');

  useEffect(() => {
    setSearchTerm(filters.search || '');
  }, [filters.search]);

  // Debounced search term update
  useEffect(() => {
    const timer = setTimeout(() => {
      if (searchTerm !== (filters.search || '')) {
        onFilterChange({ ...filters, search: searchTerm });
      }
    }, 400);
    return () => clearTimeout(timer);
  }, [searchTerm]);

  const handleChange = (key: keyof MarketplaceFilterState, value: any) => {
    const cleanValue = value === 'ALL' || value === '' || value === null ? undefined : value;
    onFilterChange({ ...filters, [key]: cleanValue });
  };

  const activeFilterCount = Object.entries(filters).filter(
    ([k, v]) => v !== undefined && v !== '' && v !== 10 && k !== 'sort' && k !== 'page',
  ).length;

  return (
    <div className="bg-white dark:bg-zinc-900 border border-zinc-200/80 dark:border-zinc-800 rounded-2xl p-4 md:p-5 space-y-4 shadow-sm transition-all duration-300">
      {/* Primary Row: Search & Action Buttons */}
      <div className="flex flex-col md:flex-row items-stretch md:items-center gap-3">
        {/* Search Bar */}
        <div className="relative flex-1">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-400" />
          <Input
            placeholder="Search by name, code, or description..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-10 pr-9 h-10 rounded-xl border-zinc-200 dark:border-zinc-800 focus-visible:ring-emerald-500"
          />
          {searchTerm && (
            <button
              onClick={() => {
                setSearchTerm('');
                onFilterChange({ ...filters, search: undefined });
              }}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200"
            >
              <X className="h-4 w-4" />
            </button>
          )}
        </div>

        {/* Quick Selects */}
        <div className="flex items-center gap-2 flex-wrap">
          {/* Status Filter */}
          <Select
            value={filters.status || 'ALL'}
            onValueChange={(val: any) => handleChange('status', val)}
          >
            <SelectTrigger className="w-[140px] h-10 rounded-xl border-zinc-200 dark:border-zinc-800">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">All Statuses</SelectItem>
              <SelectItem value="ACTIVE">Active</SelectItem>
              <SelectItem value="PENDING">Pending</SelectItem>
              <SelectItem value="REJECTED">Rejected</SelectItem>
              <SelectItem value="SUSPENDED">Suspended</SelectItem>
              <SelectItem value="INACTIVE">Inactive</SelectItem>
            </SelectContent>
          </Select>

          {/* Vendor Filter */}
          {vendors.length > 0 && (
            <Select
              value={filters.vendorId || 'ALL'}
              onValueChange={(val: any) => handleChange('vendorId', val)}
            >
              <SelectTrigger className="w-[160px] h-10 rounded-xl border-zinc-200 dark:border-zinc-800">
                <SelectValue placeholder="Filter Vendor" />
              </SelectTrigger>
              <SelectContent className="max-h-60">
                <SelectItem value="ALL">All Vendors</SelectItem>
                {vendors.map((v) => (
                  <SelectItem key={v.id} value={v.id}>
                    {v.businessName || v.fullName || 'Vendor'}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          )}

          {/* Sort Select */}
          <Select
            value={filters.sort || 'createdAt_desc'}
            onValueChange={(val: any) => handleChange('sort', val)}
          >
            <SelectTrigger className="w-[160px] h-10 rounded-xl border-zinc-200 dark:border-zinc-800">
              <SelectValue placeholder="Sort By" />
            </SelectTrigger>
            <SelectContent>
              {sortOptions.map((opt) => (
                <SelectItem key={opt.value} value={opt.value}>
                  {opt.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          {/* Expand Filters Toggle Button */}
          <Button
            variant="outline"
            onClick={() => setExpanded(!expanded)}
            className={`h-10 px-3.5 rounded-xl border-zinc-200 dark:border-zinc-800 gap-2 ${
              expanded ? 'bg-rose-500/10 text-rose-600 dark:text-rose-400 border-rose-200' : ''
            }`}
          >
            <SlidersHorizontal className="h-4 w-4" />
            <span>More</span>
            {activeFilterCount > 0 && (
              <span className="h-5 w-5 rounded-full bg-rose-500 text-white text-xs font-bold flex items-center justify-center">
                {activeFilterCount}
              </span>
            )}
            {expanded ? <ChevronUp className="h-4 w-4 ml-1" /> : <ChevronDown className="h-4 w-4 ml-1" />}
          </Button>

          {/* Clear Filters Button */}
          {activeFilterCount > 0 && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                setSearchTerm('');
                onReset();
              }}
              className="h-10 text-emerald-700 hover:bg-emerald-500/10 hover:text-emerald-800 dark:text-emerald-400 rounded-xl px-3 gap-1.5"
            >
              <RotateCcw className="h-3.5 w-3.5" />
              Reset
            </Button>
          )}
        </div>
      </div>

      {/* Expanded Advanced Filters Row */}
      {expanded && (
        <div className="pt-4 border-t border-zinc-100 dark:border-zinc-850 grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4 animate-in fade-in duration-200">
          {/* Category Filter */}
          {showCategory && (
            <div className="space-y-1.5">
              <Label className="text-xs font-medium text-zinc-500">Category</Label>
              <Select
                value={filters.categoryId || 'ALL'}
                onValueChange={(val: any) => handleChange('categoryId', val)}
              >
                <SelectTrigger className="h-9 text-xs rounded-xl border-zinc-200 dark:border-zinc-800">
                  <SelectValue placeholder="All Categories" />
                </SelectTrigger>
                <SelectContent className="max-h-56">
                  <SelectItem value="ALL">All Categories</SelectItem>
                  {categories.map((c) => (
                    <SelectItem key={c.id} value={c.id}>
                      {c.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          )}

          {/* Sub Category Filter */}
          {showSubCategory && (
            <div className="space-y-1.5">
              <Label className="text-xs font-medium text-zinc-500">Sub Category</Label>
              <Select
                value={filters.subCategoryId || 'ALL'}
                onValueChange={(val: any) => handleChange('subCategoryId', val)}
              >
                <SelectTrigger className="h-9 text-xs rounded-xl border-zinc-200 dark:border-zinc-800">
                  <SelectValue placeholder="All Sub Categories" />
                </SelectTrigger>
                <SelectContent className="max-h-56">
                  <SelectItem value="ALL">All Sub Categories</SelectItem>
                  {subCategories.map((sc) => (
                    <SelectItem key={sc.id} value={sc.id}>
                      {sc.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          )}

          {/* Brand Filter */}
          {showBrand && (
            <div className="space-y-1.5">
              <Label className="text-xs font-medium text-zinc-500">Brand</Label>
              <Select
                value={filters.brandId || 'ALL'}
                onValueChange={(val: any) => handleChange('brandId', val)}
              >
                <SelectTrigger className="h-9 text-xs rounded-xl border-zinc-200 dark:border-zinc-800">
                  <SelectValue placeholder="All Brands" />
                </SelectTrigger>
                <SelectContent className="max-h-56">
                  <SelectItem value="ALL">All Brands</SelectItem>
                  {brands.map((b) => (
                    <SelectItem key={b.id} value={b.id}>
                      {b.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          )}

          {/* Created From Date */}
          <div className="space-y-1.5">
            <Label className="text-xs font-medium text-zinc-500">Created Date (From)</Label>
            <div className="relative">
              <Input
                type="date"
                value={filters.createdFrom || ''}
                onChange={(e) => handleChange('createdFrom', e.target.value)}
                className="h-9 text-xs rounded-xl border-zinc-200 dark:border-zinc-800"
              />
            </div>
          </div>

          {/* Created To Date */}
          <div className="space-y-1.5">
            <Label className="text-xs font-medium text-zinc-500">Created Date (To)</Label>
            <Input
              type="date"
              value={filters.createdTo || ''}
              onChange={(e) => handleChange('createdTo', e.target.value)}
              className="h-9 text-xs rounded-xl border-zinc-200 dark:border-zinc-800"
            />
          </div>

          {/* Page Size Select */}
          <div className="space-y-1.5">
            <Label className="text-xs font-medium text-zinc-500">Items Per Page</Label>
            <Select
              value={String(filters.limit || 10)}
              onValueChange={(val: any) => handleChange('limit', val ? parseInt(val, 10) : 10)}
            >
              <SelectTrigger className="h-9 text-xs rounded-xl border-zinc-200 dark:border-zinc-800">
                <SelectValue placeholder="10 per page" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="10">10 per page</SelectItem>
                <SelectItem value="25">25 per page</SelectItem>
                <SelectItem value="50">50 per page</SelectItem>
                <SelectItem value="100">100 per page</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
      )}
    </div>
  );
}
