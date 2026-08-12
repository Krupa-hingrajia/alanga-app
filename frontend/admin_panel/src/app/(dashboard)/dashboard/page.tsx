'use client';

import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { IndianRupee, ShieldCheck, ShoppingCart, RefreshCw, AlertCircle } from 'lucide-react';

import { getDashboardSummary } from '@/features/dashboard/api';
import SummaryCards from '@/features/dashboard/components/SummaryCards';
import PendingApprovals from '@/features/dashboard/components/PendingApprovals';
import { Button } from '@/components/ui/button';

export default function DashboardPage() {
  const {
    data: summary,
    isLoading,
    isError,
    error,
    refetch,
    isFetching,
  } = useQuery({
    queryKey: ['dashboardSummary'],
    queryFn: getDashboardSummary,
  });

  if (isLoading) {
    return (
      <div className="space-y-8 animate-pulse">
        <div className="flex justify-between items-center">
          <div className="space-y-2">
            <div className="h-8 w-48 bg-zinc-200 dark:bg-zinc-800 rounded-lg" />
            <div className="h-4 w-64 bg-zinc-200 dark:bg-zinc-800 rounded-lg" />
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 8 }).map((_, idx) => (
            <div key={idx} className="h-28 bg-zinc-200 dark:bg-zinc-800 rounded-2xl" />
          ))}
        </div>

        <div className="grid gap-6 md:grid-cols-2">
          <div className="h-96 bg-zinc-200 dark:bg-zinc-800 rounded-2xl" />
          <div className="h-96 bg-zinc-200 dark:bg-zinc-800 rounded-2xl" />
        </div>
      </div>
    );
  }

  if (isError) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] p-8 border border-dashed border-zinc-200 dark:border-zinc-800 rounded-3xl bg-white dark:bg-zinc-950">
        <AlertCircle className="h-12 w-12 text-rose-500 mb-4 animate-bounce" />
        <h3 className="text-lg font-bold text-zinc-900 dark:text-zinc-50">Unable to load Dashboard</h3>
        <p className="text-sm text-zinc-500 dark:text-zinc-400 mt-2 text-center max-w-md">
          {error?.message || 'A network error occurred while contacting the server.'}
        </p>
        <Button onClick={() => refetch()} className="mt-6 h-10 px-6 font-semibold bg-rose-500 hover:bg-rose-600 text-white rounded-xl">
          Try Again
        </Button>
      </div>
    );
  }

  const formatRevenue = (value: number) => {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 0,
    }).format(value);
  };

  return (
    <div className="space-y-8">
      {/* Header Banner */}
      <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold text-zinc-900 dark:text-zinc-50 tracking-tight flex items-center gap-2">
            System Overview
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Realtime marketplace status, onboarding approvals, and category controls.
          </p>
        </div>
        <Button
          variant="outline"
          onClick={() => refetch()}
          disabled={isFetching}
          className="self-start sm:self-auto h-10 px-4 rounded-xl font-medium border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-950"
        >
          <RefreshCw className={`h-4 w-4 mr-2 ${isFetching ? 'animate-spin' : ''}`} />
          {isFetching ? 'Refreshing...' : 'Refresh Stats'}
        </Button>
      </div>

      {/* Hero Financial Banner */}
      <div className="grid gap-6 md:grid-cols-2">
        <div className="relative overflow-hidden p-6 rounded-3xl border border-zinc-200/60 dark:border-zinc-800/60 bg-gradient-to-br from-rose-500/10 to-amber-500/10 dark:from-rose-500/5 dark:to-amber-500/5 flex items-center justify-between">
          <div className="space-y-2">
            <span className="text-xs font-bold uppercase tracking-wider text-rose-500 dark:text-rose-400">
              Approved Orders Revenue
            </span>
            <h2 className="text-4xl font-extrabold tracking-tight text-zinc-900 dark:text-zinc-50">
              {formatRevenue(summary?.totalCompletedOrdersRevenue || 0)}
            </h2>
            <p className="text-xs text-zinc-500 dark:text-zinc-400">
              Aggregated from completed marketplace sales
            </p>
          </div>
          <div className="p-4 bg-gradient-to-tr from-rose-500 to-amber-500 rounded-2xl text-white shadow-lg shadow-rose-500/10">
            <IndianRupee className="h-8 w-8" />
          </div>
        </div>

        <div className="relative overflow-hidden p-6 rounded-3xl border border-zinc-200/60 dark:border-zinc-800/60 bg-gradient-to-br from-blue-500/10 to-indigo-500/10 dark:from-blue-500/5 dark:to-indigo-500/5 flex items-center justify-between">
          <div className="space-y-2">
            <span className="text-xs font-bold uppercase tracking-wider text-blue-500 dark:text-blue-400">
              Completed Orders Volume
            </span>
            <h2 className="text-4xl font-extrabold tracking-tight text-zinc-900 dark:text-zinc-50">
              {summary?.totalCompletedOrders || 0}
            </h2>
            <p className="text-xs text-zinc-500 dark:text-zinc-400">
              Processed and dispatched customer orders
            </p>
          </div>
          <div className="p-4 bg-gradient-to-tr from-blue-500 to-indigo-500 rounded-2xl text-white shadow-lg shadow-blue-500/10">
            <ShoppingCart className="h-8 w-8" />
          </div>
        </div>
      </div>

      {/* Summary Cards Grid */}
      {summary && <SummaryCards summary={summary} />}

      {/* Breakdowns & Approvals Queue */}
      <div className="grid gap-6 md:grid-cols-2">
        {summary && <PendingApprovals summary={summary} />}
        
        {/* Placeholder for Quick-Guide/Tips */}
        <div className="p-6 rounded-3xl border border-zinc-200/60 dark:border-zinc-800/60 bg-white dark:bg-zinc-950 flex flex-col justify-center space-y-4">
          <div className="p-3 bg-rose-500/10 dark:bg-rose-500/20 text-rose-500 dark:text-rose-400 rounded-2xl self-start">
            <ShieldCheck className="h-6 w-6" />
          </div>
          <h3 className="font-bold text-lg text-zinc-900 dark:text-zinc-50">Administrator Security Guard</h3>
          <p className="text-sm text-zinc-500 dark:text-zinc-400 leading-relaxed">
            As an administrator, you hold absolute authority over categories, subcategories, brands, and product catalog items. 
            All submissions from vendors remain in a <strong>PENDING</strong> status and are hidden from customers until you explicitly verify and approve them.
          </p>
        </div>
      </div>
    </div>
  );
}
