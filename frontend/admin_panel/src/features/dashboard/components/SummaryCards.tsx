'use client';

import React from 'react';
import Link from 'next/link';
import {
  Users,
  UserCheck,
  FolderTree,
  FolderGit2,
  Tag,
  Clock,
  ShoppingBag,
  CheckCircle,
  ShoppingCart,
  ArrowUpRight,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { DashboardSummary } from '../api';

interface SummaryCardsProps {
  summary: DashboardSummary;
}

export default function SummaryCards({ summary }: SummaryCardsProps) {
  const pendingBrandCount = summary.pendingBrands ?? 0;
  const pendingProductCount = summary.pendingProducts ?? 0;
  const totalSubCatCount = summary.totalSubCategories ?? 0;
  const totalOrdersCount = summary.totalOrders ?? summary.totalCompletedOrders ?? 0;

  const coreCards = [
    {
      title: 'Total Vendors',
      value: summary.totalVendors,
      description: `${summary.activeVendors ?? 0} active, ${summary.pendingVendorApprovals ?? 0} pending`,
      icon: Users,
      href: '/vendors',
      color: 'from-emerald-700 to-emerald-500',
      iconBg: 'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-400',
    },
    {
      title: 'Total Customers',
      value: summary.totalCustomers ?? 0,
      description: 'Registered marketplace buyers',
      icon: UserCheck,
      href: '/customers',
      color: 'from-teal-600 to-emerald-500',
      iconBg: 'bg-teal-50 text-teal-700 dark:bg-teal-950/40 dark:text-teal-400',
    },
    {
      title: 'Total Categories',
      value: summary.totalCategories,
      description: 'Master product categories',
      icon: FolderTree,
      href: '/categories',
      color: 'from-amber-500 to-orange-500',
      iconBg: 'bg-amber-50 text-amber-700 dark:bg-amber-950/40 dark:text-amber-400',
    },
    {
      title: 'Total Sub Categories',
      value: totalSubCatCount,
      description: 'Nested taxonomy classifications',
      icon: FolderGit2,
      href: '/subcategories',
      color: 'from-emerald-600 to-emerald-800',
      iconBg: 'bg-emerald-50 text-emerald-800 dark:bg-emerald-950/40 dark:text-emerald-300',
    },
    {
      title: 'Total Brands',
      value: summary.totalBrands,
      description: 'Catalog marketplace brands',
      icon: Tag,
      href: '/brands',
      color: 'from-orange-500 to-amber-500',
      iconBg: 'bg-orange-50 text-orange-700 dark:bg-orange-950/40 dark:text-orange-400',
    },
    {
      title: 'Pending Brand Requests',
      value: pendingBrandCount,
      description: 'Vendor submissions awaiting review',
      icon: Clock,
      href: '/requests/brands',
      color: 'from-amber-500 to-red-500',
      iconBg: 'bg-amber-50 text-amber-700 dark:bg-amber-950/40 dark:text-amber-400',
      badge: pendingBrandCount > 0 ? 'action-required' : null,
      highlight: pendingBrandCount > 0,
    },
    {
      title: 'Total Products',
      value: summary.totalProducts,
      description: 'Active items in marketplace catalog',
      icon: ShoppingBag,
      href: '/products',
      color: 'from-emerald-500 to-green-600',
      iconBg: 'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-400',
    },
    {
      title: 'Pending Product Approvals',
      value: pendingProductCount,
      description: 'Quality verification queue',
      icon: CheckCircle,
      href: '/requests/products',
      color: 'from-red-500 to-rose-600',
      iconBg: 'bg-red-50 text-red-600 dark:bg-red-950/40 dark:text-red-400',
      badge: pendingProductCount > 0 ? 'action-required' : null,
      highlight: pendingProductCount > 0,
    },
    {
      title: 'Total Orders',
      value: totalOrdersCount,
      description: `${summary.totalCompletedOrders ?? 0} fulfilled / completed`,
      icon: ShoppingCart,
      href: '/orders',
      color: 'from-emerald-700 via-teal-600 to-emerald-500',
      iconBg: 'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-400',
    },
  ];

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h2 className="text-sm font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
          Core Marketplace Metrics
        </h2>
        <span className="text-xs text-zinc-400">Real-time live APIs</span>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {coreCards.map((card, idx) => {
          const Icon = card.icon;
          const hasAction = card.badge === 'action-required';

          return (
            <Link key={idx} href={card.href} className="group block">
              <Card
                className={`relative overflow-hidden border transition-all duration-300 hover:shadow-lg hover:-translate-y-0.5 bg-white dark:bg-zinc-950 ${
                  card.highlight
                    ? 'border-amber-300/80 dark:border-amber-700/60 ring-1 ring-amber-400/20'
                    : 'border-zinc-200/80 dark:border-zinc-800'
                }`}
              >
                {/* Ambient glow accent */}
                <div
                  className={`absolute top-0 right-0 w-24 h-24 bg-gradient-to-br ${card.color} opacity-[0.04] dark:opacity-[0.08] rounded-bl-full pointer-events-none`}
                />

                <CardHeader className="flex flex-row items-center justify-between pb-2 space-y-0">
                  <CardTitle className="text-xs font-bold text-zinc-600 dark:text-zinc-400 uppercase tracking-wider">
                    {card.title}
                  </CardTitle>
                  <div className={`p-2 rounded-xl ${card.iconBg} transition-transform group-hover:scale-110 duration-200`}>
                    <Icon className="h-4 w-4" />
                  </div>
                </CardHeader>

                <CardContent className="pt-0">
                  <div className="flex items-baseline justify-between">
                    <div className="text-3xl font-extrabold tracking-tight text-zinc-900 dark:text-zinc-50">
                      {card.value.toLocaleString()}
                    </div>
                    <ArrowUpRight className="h-4 w-4 text-zinc-400 opacity-0 group-hover:opacity-100 group-hover:text-zinc-700 dark:group-hover:text-zinc-200 transition-all duration-200" />
                  </div>

                  <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-1.5 flex items-center gap-1.5">
                    {hasAction && (
                      <span className="relative flex h-2 w-2">
                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-rose-400 opacity-75"></span>
                        <span className="relative inline-flex rounded-full h-2 w-2 bg-rose-500"></span>
                      </span>
                    )}
                    <span>{card.description}</span>
                  </p>
                </CardContent>
              </Card>
            </Link>
          );
        })}
      </div>
    </div>
  );
}
