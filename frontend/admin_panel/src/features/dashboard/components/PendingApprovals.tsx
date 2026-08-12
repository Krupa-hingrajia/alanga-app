import React from 'react';
import Link from 'next/link';
import { ArrowUpRight, Users, FolderTree, Tag, ShoppingBag } from 'lucide-react';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { DashboardSummary } from '../api';

interface PendingApprovalsProps {
  summary: DashboardSummary;
}

export default function PendingApprovals({ summary }: PendingApprovalsProps) {
  const approvalItems = [
    {
      title: 'Vendors',
      count: summary.pendingVendorApprovals,
      description: 'New vendor accounts waiting for credentials review',
      link: '/vendors',
      icon: Users,
      badgeColor: 'bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-400',
    },
    {
      title: 'Categories',
      count: summary.pendingCategories,
      description: 'Vendor suggested categories awaiting taxonomy approval',
      link: '/categories',
      icon: FolderTree,
      badgeColor: 'bg-rose-100 text-rose-800 dark:bg-rose-900/30 dark:text-rose-400',
    },
    {
      title: 'Brands',
      count: summary.pendingBrands,
      description: 'New vendor brands needing registration verification',
      link: '/brands',
      icon: Tag,
      badgeColor: 'bg-fuchsia-100 text-fuchsia-800 dark:bg-fuchsia-900/30 dark:text-fuchsia-400',
    },
    {
      title: 'Products',
      count: summary.pendingProducts,
      description: 'Submitted products requiring quality standard checks',
      link: '/products',
      icon: ShoppingBag,
      badgeColor: 'bg-rose-100 text-rose-800 dark:bg-rose-900/30 dark:text-rose-400',
    },
  ];

  return (
    <Card className="border border-zinc-200/60 dark:border-zinc-800/60 bg-white dark:bg-zinc-950">
      <CardHeader>
        <CardTitle className="text-lg font-bold text-zinc-900 dark:text-zinc-50">
          Pending Approval Queues
        </CardTitle>
        <CardDescription className="text-zinc-500 dark:text-zinc-400">
          Click any queue to review, approve, or reject vendor submissions.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {approvalItems.map((item, idx) => {
          const Icon = item.icon;
          return (
            <div
              key={idx}
              className="flex items-center justify-between p-4 rounded-2xl border border-zinc-100 dark:border-zinc-900 bg-zinc-50/50 dark:bg-zinc-900/10 hover:bg-zinc-50 dark:hover:bg-zinc-900/30 transition-colors"
            >
              <div className="flex items-start gap-4">
                <div className="p-2.5 bg-white dark:bg-zinc-900 border border-zinc-200/50 dark:border-zinc-800/50 rounded-xl text-zinc-700 dark:text-zinc-300">
                  <Icon className="h-5 w-5" />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h4 className="font-semibold text-sm text-zinc-900 dark:text-zinc-50">{item.title}</h4>
                    {item.count > 0 && (
                      <span className={`px-2 py-0.5 rounded-full text-xs font-bold ${item.badgeColor}`}>
                        {item.count} Pending
                      </span>
                    )}
                  </div>
                  <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
                    {item.description}
                  </p>
                </div>
              </div>

              <Link href={item.link} passHref>
                <Button variant="ghost" size="icon" className="rounded-xl hover:bg-zinc-200/50 dark:hover:bg-zinc-800">
                  <ArrowUpRight className="h-5 w-5 text-zinc-500" />
                </Button>
              </Link>
            </div>
          );
        })}
      </CardContent>
    </Card>
  );
}
