import React from 'react';
import { Users, FolderTree, Tag, ShoppingBag, Clock } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { DashboardSummary } from '../api';

interface SummaryCardsProps {
  summary: DashboardSummary;
}

export default function SummaryCards({ summary }: SummaryCardsProps) {
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
      description: 'Marketplace Categories',
      icon: FolderTree,
      color: 'from-emerald-500 to-teal-500',
    },
    {
      title: 'Pending Categories',
      value: summary.pendingCategories,
      description: 'Vendor Submissions',
      icon: Clock,
      color: 'from-rose-500 to-pink-500',
      badge: summary.pendingCategories > 0 ? 'action-required' : null,
    },
    {
      title: 'Total Brands',
      value: summary.totalBrands,
      description: 'Approved Brands',
      icon: Tag,
      color: 'from-purple-500 to-violet-500',
    },
    {
      title: 'Pending Brands',
      value: summary.pendingBrands,
      description: 'Awaiting Approvals',
      icon: Clock,
      color: 'from-fuchsia-500 to-purple-500',
      badge: summary.pendingBrands > 0 ? 'action-required' : null,
    },
    {
      title: 'Total Products',
      value: summary.totalProducts,
      description: 'Items in Catalogue',
      icon: ShoppingBag,
      color: 'from-sky-500 to-blue-500',
    },
    {
      title: 'Pending Products',
      value: summary.pendingProducts,
      description: 'Awaiting Quality Check',
      icon: Clock,
      color: 'from-rose-500 to-orange-500',
      badge: summary.pendingProducts > 0 ? 'action-required' : null,
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
