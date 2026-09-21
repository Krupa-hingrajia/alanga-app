import React from 'react';
import {
  ShoppingCart,
  Clock,
  RotateCw,
  Truck,
  CheckCircle2,
  XCircle,
  IndianRupee,
  CheckCheck,
  Package,
  CalendarCheck,
  ArrowRight,
} from 'lucide-react';

interface OrderSummaryCardsProps {
  totalOrders: number;
  pendingOrders: number;
  confirmedOrders: number;
  processingOrders: number;
  packedOrders: number;
  shippedOrders: number;
  deliveredOrders: number;
  cancelledOrders: number;
  todayOrders: number;
  totalRevenue: number;
  isLoading?: boolean;
  selectedStatus?: string;
  selectedDatePreset?: string;
  onStatusClick?: (status: string) => void;
  onTodayClick?: () => void;
}

export function OrderSummaryCards({
  totalOrders,
  pendingOrders,
  confirmedOrders,
  processingOrders,
  packedOrders,
  shippedOrders,
  deliveredOrders,
  cancelledOrders,
  todayOrders,
  totalRevenue,
  isLoading,
  selectedStatus,
  selectedDatePreset,
  onStatusClick,
  onTodayClick,
}: OrderSummaryCardsProps) {
  const formatCurrency = (val: number) => {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 0,
    }).format(val);
  };

  const cards = [
    {
      id: 'ALL',
      title: 'Total Orders',
      value: totalOrders,
      icon: ShoppingCart,
      color: 'text-teal-600 dark:text-teal-400',
      bgColor: 'bg-teal-50 dark:bg-teal-950/40',
      activeBorder: 'border-teal-500 bg-teal-50/40 dark:bg-teal-950/30 ring-2 ring-teal-500/20',
      description: 'All marketplace orders',
    },
    {
      id: 'PENDING',
      title: 'Pending Review',
      value: pendingOrders,
      icon: Clock,
      color: 'text-amber-600 dark:text-amber-400',
      bgColor: 'bg-amber-50 dark:bg-amber-950/40',
      activeBorder: 'border-amber-500 bg-amber-50/40 dark:bg-amber-950/30 ring-2 ring-amber-500/20',
      description: 'Awaiting vendor action',
    },
    {
      id: 'CONFIRMED',
      title: 'Confirmed',
      value: confirmedOrders,
      icon: CheckCheck,
      color: 'text-blue-600 dark:text-blue-400',
      bgColor: 'bg-blue-50 dark:bg-blue-950/40',
      activeBorder: 'border-blue-500 bg-blue-50/40 dark:bg-blue-950/30 ring-2 ring-blue-500/20',
      description: 'Accepted by vendors',
    },
    {
      id: 'PROCESSING',
      title: 'Processing',
      value: processingOrders,
      icon: RotateCw,
      color: 'text-indigo-600 dark:text-indigo-400',
      bgColor: 'bg-indigo-50 dark:bg-indigo-950/40',
      activeBorder: 'border-indigo-500 bg-indigo-50/40 dark:bg-indigo-950/30 ring-2 ring-indigo-500/20',
      description: 'Being prepared',
    },
    {
      id: 'PACKED',
      title: 'Packed',
      value: packedOrders,
      icon: Package,
      color: 'text-purple-600 dark:text-purple-400',
      bgColor: 'bg-purple-50 dark:bg-purple-950/40',
      activeBorder: 'border-purple-500 bg-purple-50/40 dark:bg-purple-950/30 ring-2 ring-purple-500/20',
      description: 'Ready for courier',
    },
    {
      id: 'SHIPPED',
      title: 'Shipped',
      value: shippedOrders,
      icon: Truck,
      color: 'text-cyan-600 dark:text-cyan-400',
      bgColor: 'bg-cyan-50 dark:bg-cyan-950/40',
      activeBorder: 'border-cyan-500 bg-cyan-50/40 dark:bg-cyan-950/30 ring-2 ring-cyan-500/20',
      description: 'In transit / Out for delivery',
    },
    {
      id: 'DELIVERED',
      title: 'Delivered',
      value: deliveredOrders,
      icon: CheckCircle2,
      color: 'text-emerald-600 dark:text-emerald-400',
      bgColor: 'bg-emerald-50 dark:bg-emerald-950/40',
      activeBorder: 'border-emerald-500 bg-emerald-50/40 dark:bg-emerald-950/30 ring-2 ring-emerald-500/20',
      description: 'Completed deliveries',
    },
    {
      id: 'CANCELLED',
      title: 'Cancelled',
      value: cancelledOrders,
      icon: XCircle,
      color: 'text-rose-600 dark:text-rose-400',
      bgColor: 'bg-rose-50 dark:bg-rose-950/40',
      activeBorder: 'border-rose-500 bg-rose-50/40 dark:bg-rose-950/30 ring-2 ring-rose-500/20',
      description: 'Revoked / Returned',
    },
    {
      id: 'TODAY',
      title: "Today's Orders",
      value: todayOrders,
      icon: CalendarCheck,
      color: 'text-orange-600 dark:text-orange-400',
      bgColor: 'bg-orange-50 dark:bg-orange-950/40',
      activeBorder: 'border-orange-500 bg-orange-50/40 dark:bg-orange-950/30 ring-2 ring-orange-500/20',
      description: 'Placed today',
      isToday: true,
    },
    {
      id: 'REVENUE',
      title: 'Total Revenue',
      value: formatCurrency(totalRevenue),
      icon: IndianRupee,
      color: 'text-emerald-700 dark:text-emerald-300',
      bgColor: 'bg-emerald-50 dark:bg-emerald-950/40',
      activeBorder: 'border-emerald-200 dark:border-emerald-900/50',
      description: 'Net delivered & active revenue',
      isRevenue: true,
    },
  ];

  return (
    <div className="space-y-2">
      {/* 10 Dashboard Summary Cards in a Clean 5-Column Responsive Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-3">
        {cards.map((card) => {
          const Icon = card.icon;
          const isClickable = !card.isRevenue && (onStatusClick || onTodayClick);
          const isSelected = card.isToday
            ? selectedDatePreset === 'TODAY'
            : selectedStatus === card.id && selectedDatePreset !== 'TODAY';

          return (
            <div
              key={card.id}
              onClick={() => {
                if (card.isToday && onTodayClick) {
                  onTodayClick();
                } else if (!card.isRevenue && onStatusClick) {
                  onStatusClick(card.id);
                }
              }}
              className={`p-3.5 rounded-2xl bg-white dark:bg-zinc-950 border transition-all relative overflow-hidden ${
                isClickable
                  ? 'cursor-pointer hover:border-zinc-300 dark:hover:border-zinc-700 hover:shadow-xs'
                  : ''
              } ${
                isSelected
                  ? card.activeBorder
                  : 'border-zinc-200/80 dark:border-zinc-800 shadow-2xs'
              }`}
            >
              {/* Selected Indicator Pill */}
              {isSelected && !card.isRevenue && (
                <div className="absolute top-0 right-0 w-2 h-2 rounded-bl-md bg-emerald-500" />
              )}

              <div className="flex items-center justify-between gap-2">
                <span className="text-[11px] font-semibold text-zinc-500 dark:text-zinc-400 truncate">
                  {card.title}
                </span>
                <div className={`p-1.5 rounded-xl ${card.bgColor} ${card.color} shrink-0`}>
                  <Icon className="h-3.5 w-3.5" />
                </div>
              </div>

              <div className="mt-1.5">
                {isLoading ? (
                  <div className="h-6 w-16 bg-zinc-100 dark:bg-zinc-800 rounded animate-pulse" />
                ) : (
                  <div className="flex items-baseline justify-between gap-1">
                    <p
                      className={`font-bold tracking-tight text-zinc-900 dark:text-zinc-50 truncate ${
                        card.isRevenue ? 'text-sm lg:text-xs xl:text-sm font-mono' : 'text-lg'
                      }`}
                    >
                      {card.value}
                    </p>
                    {isClickable && (
                      <span className="text-[10px] text-zinc-400 hover:text-zinc-600 hidden group-hover:inline-block">
                        Filter
                      </span>
                    )}
                  </div>
                )}
                <p className="text-[10px] text-zinc-400 dark:text-zinc-500 truncate mt-0.5">
                  {card.description}
                </p>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
