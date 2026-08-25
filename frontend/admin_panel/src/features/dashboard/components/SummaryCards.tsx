import React from 'react';
import { Users, FolderTree, FolderGit2, Tag, ShoppingBag, Clock, CheckCircle2, XCircle } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { DashboardSummary } from '../api';

interface SummaryCardsProps {
  summary: DashboardSummary;
}

export default function SummaryCards({ summary }: SummaryCardsProps) {
  const activeCatCount = summary.activeCategories ?? summary.totalCategories;
  const inactiveCatCount = summary.inactiveCategories ?? 0;
  const totalSubCatCount = summary.totalSubCategories ?? 0;
  const activeSubCatCount = summary.activeSubCategories ?? totalSubCatCount;
  const inactiveSubCatCount = summary.inactiveSubCategories ?? 0;

  const activeBrandCount = summary.activeBrands ?? summary.totalBrands;
  const inactiveBrandCount = summary.inactiveBrands ?? 0;
  const pendingBrandCount = summary.pendingBrands ?? 0;

  const cards = [
    {
      title: 'Total Vendors',
      value: summary.totalVendors,
      description: `${summary.activeVendors} Active Vendors`,
      icon: Users,
      color: 'from-blue-500 to-indigo-500',
    },
    {
      title: 'Pending Vendors',
      value: summary.pendingVendorApprovals,
      description: 'Awaiting Verification',
      icon: Clock,
      color: 'from-amber-500 to-orange-500',
      badge: summary.pendingVendorApprovals > 0 ? 'action-required' : null,
    },
    {
      title: 'Total Categories',
      value: summary.totalCategories,
      description: `${activeCatCount} Active / ${inactiveCatCount} Inactive`,
      icon: FolderTree,
      color: 'from-emerald-500 to-teal-500',
    },
    {
      title: 'Active Categories',
      value: activeCatCount,
      description: 'Visible to Vendors',
      icon: CheckCircle2,
      color: 'from-green-500 to-emerald-600',
    },
    {
      title: 'Inactive Categories',
      value: inactiveCatCount,
      description: 'Disabled Taxonomy',
      icon: XCircle,
      color: 'from-zinc-400 to-zinc-600',
    },
    {
      title: 'Total Sub Categories',
      value: totalSubCatCount,
      description: `${activeSubCatCount} Active / ${inactiveSubCatCount} Inactive`,
      icon: FolderGit2,
      color: 'from-purple-500 to-indigo-500',
    },
    {
      title: 'Active Sub Categories',
      value: activeSubCatCount,
      description: 'Selectable Sub Categories',
      icon: CheckCircle2,
      color: 'from-teal-500 to-cyan-600',
    },
    {
      title: 'Inactive Sub Categories',
      value: inactiveSubCatCount,
      description: 'Disabled Sub Categories',
      icon: XCircle,
      color: 'from-zinc-400 to-zinc-600',
    },
    {
      title: 'Total Brands',
      value: summary.totalBrands,
      description: `${activeBrandCount} Active / ${inactiveBrandCount} Inactive`,
      icon: Tag,
      color: 'from-purple-500 to-violet-500',
    },
    {
      title: 'Active Brands',
      value: activeBrandCount,
      description: 'Available to Vendors',
      icon: CheckCircle2,
      color: 'from-purple-600 to-indigo-600',
    },
    {
      title: 'Inactive Brands',
      value: inactiveBrandCount,
      description: 'Hidden Marketplace Brands',
      icon: XCircle,
      color: 'from-zinc-400 to-zinc-600',
    },
    {
      title: 'Pending Brand Requests',
      value: pendingBrandCount,
      description: 'Vendor Submissions',
      icon: Clock,
      color: 'from-amber-500 to-orange-500',
      badge: pendingBrandCount > 0 ? 'action-required' : null,
    },
    {
      title: 'Total Products',
      value: summary.totalProducts,
      description: 'Items in Catalogue',
      icon: ShoppingBag,
      color: 'from-sky-500 to-blue-500',
    },
  ];

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      {cards.map((card, idx) => {
        const Icon = card.icon;
        const hasAction = card.badge === 'action-required';
        return (
          <Card
            key={idx}
            className={`relative overflow-hidden border border-zinc-200/60 dark:border-zinc-800/60 hover:shadow-xl hover:-translate-y-0.5 transition-all duration-300 ${
              hasAction ? 'ring-1 ring-rose-500/20 dark:ring-rose-500/30' : ''
            }`}
          >
            {/* Ambient Background Glow */}
            <div className={`absolute top-0 right-0 w-24 h-24 bg-gradient-to-br ${card.color} opacity-[0.03] dark:opacity-[0.06] rounded-bl-full`} />

            <CardHeader className="flex flex-row items-center justify-between pb-2 space-y-0">
              <CardTitle className="text-sm font-semibold text-zinc-500 dark:text-zinc-400">
                {card.title}
              </CardTitle>
              <div className={`p-2 rounded-xl bg-zinc-100 dark:bg-zinc-900 text-zinc-700 dark:text-zinc-300`}>
                <Icon className="h-4 w-4" />
              </div>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
                {card.value}
              </div>
              <p className="text-xs text-zinc-400 dark:text-zinc-500 mt-1">
                {card.description}
              </p>
              {hasAction && (
                <span className="absolute top-2 right-12 flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-rose-400 opacity-75"></span>
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-rose-500"></span>
                </span>
              )}
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
}
