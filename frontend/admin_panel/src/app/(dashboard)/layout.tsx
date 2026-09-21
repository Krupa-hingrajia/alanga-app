'use client';

import React, { useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import Link from 'next/link';
import { useQuery } from '@tanstack/react-query';
import {
  LayoutDashboard,
  FolderTree,
  FolderGit2,
  Tag,
  ShoppingBag,
  Users,
  UserCheck,
  ShoppingCart,
  Clock,
  CheckCircle,
  Settings,
  LogOut,
  Menu,
  X,
  Bell,
  ChevronRight,
  ShieldCheck,
} from 'lucide-react';
import { toast } from 'sonner';

import { useAuthStore } from '@/services/auth/authStore';
import { logoutAdmin } from '@/features/auth/api';
import { getDashboardSummary } from '@/features/dashboard/api';
import { ThemeToggle } from '@/components/ThemeToggle';
import { AlangaLogo } from '@/components/AlangaLogo';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

interface NavItem {
  href: string;
  label: string;
  icon: React.ComponentType<{ className?: string }>;
  badgeKey?: 'pendingBrands' | 'pendingProducts' | 'pendingVendorApprovals';
}

interface NavSection {
  title?: string;
  items: NavItem[];
}

const navigationSections: NavSection[] = [
  {
    items: [
      { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
    ],
  },
  {
    title: 'Marketplace Management',
    items: [
      { href: '/categories', label: 'Categories', icon: FolderTree },
      { href: '/subcategories', label: 'Sub Categories', icon: FolderGit2 },
      { href: '/brands', label: 'Brands', icon: Tag },
      { href: '/products', label: 'Products', icon: ShoppingBag },
      { href: '/orders', label: 'Orders', icon: ShoppingCart },
    ],
  },
  {
    title: 'Users',
    items: [
      { href: '/vendors', label: 'Vendors', icon: Users, badgeKey: 'pendingVendorApprovals' },
      { href: '/customers', label: 'Customers', icon: UserCheck },
    ],
  },
  {
    title: 'Requests',
    items: [
      { href: '/requests/brands', label: 'Brand Requests', icon: Clock, badgeKey: 'pendingBrands' },
      { href: '/requests/products', label: 'Product Approvals', icon: CheckCircle, badgeKey: 'pendingProducts' },
    ],
  },
  {
    items: [
      { href: '/settings', label: 'Settings', icon: Settings },
    ],
  },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const { user, accessToken } = useAuthStore();
  const [mounted, setMounted] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  // Sync mounted state to avoid hydration issues
  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    if (mounted && !accessToken) {
      router.push('/login');
    }
  }, [mounted, accessToken, router]);

  // Query summary for live badge counters in the sidebar
  const { data: summary } = useQuery({
    queryKey: ['dashboardSummary'],
    queryFn: getDashboardSummary,
    enabled: Boolean(accessToken),
    staleTime: 30000,
  });

  if (!mounted || !accessToken) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-zinc-50 dark:bg-zinc-950">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-emerald-600 border-t-transparent" />
      </div>
    );
  }

  const handleLogout = async () => {
    const logoutPromise = logoutAdmin();
    toast.promise(logoutPromise, {
      loading: 'Signing out...',
      success: () => {
        router.push('/login');
        return 'Signed out successfully.';
      },
      error: 'Logout failed, clearing session.',
    });
  };

  const getBreadcrumbs = () => {
    const paths = pathname.split('/').filter(Boolean);
    return (
      <div className="flex items-center space-x-1 text-xs text-zinc-500 dark:text-zinc-400 capitalize">
        <span className="font-semibold text-zinc-700 dark:text-zinc-300">Admin</span>
        {paths.map((p, idx) => (
          <React.Fragment key={p}>
            <ChevronRight className="h-3 w-3 text-zinc-400" />
            <span
              className={
                idx === paths.length - 1
                  ? 'text-zinc-900 dark:text-zinc-50 font-bold'
                  : 'hover:text-zinc-700 dark:hover:text-zinc-200'
              }
            >
              {p.replace('-', ' ')}
            </span>
          </React.Fragment>
        ))}
      </div>
    );
  };

  const renderNavLinks = (onItemClick?: () => void) => {
    return navigationSections.map((section, sIdx) => (
      <div key={sIdx} className="space-y-1 mb-4">
        {section.title && (
          <p className="px-3 text-[11px] font-bold uppercase tracking-wider text-zinc-400 dark:text-zinc-500 mb-1.5">
            {section.title}
          </p>
        )}
        {section.items.map((item) => {
          const Icon = item.icon;
          const isActive =
            item.href === '/dashboard'
              ? pathname === '/dashboard'
              : pathname === item.href || pathname.startsWith(item.href + '/');

          const badgeCount =
            item.badgeKey && summary ? (summary[item.badgeKey] as number) : 0;

          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={onItemClick}
              className={`flex items-center justify-between px-3.5 h-10 rounded-xl text-xs font-semibold transition-all duration-200 group ${
                isActive
                  ? 'bg-emerald-500/10 text-emerald-800 dark:bg-emerald-500/20 dark:text-emerald-300 font-bold shadow-2xs border-r-2 border-emerald-600'
                  : 'text-zinc-600 dark:text-zinc-400 hover:bg-emerald-50/50 dark:hover:bg-emerald-950/20 hover:text-emerald-900 dark:hover:text-emerald-200'
              }`}
            >
              <div className="flex items-center gap-2.5 min-w-0">
                <Icon
                  className={`h-4 w-4 shrink-0 transition-colors ${
                    isActive
                      ? 'text-emerald-700 dark:text-emerald-400'
                      : 'text-zinc-400 dark:text-zinc-500 group-hover:text-emerald-600 dark:group-hover:text-emerald-400'
                  }`}
                />
                <span className="truncate">{item.label}</span>
              </div>

              {badgeCount > 0 && (
                <span className="ml-auto px-1.5 py-0.5 text-[10px] font-bold rounded-full bg-gradient-to-r from-amber-500 to-rose-500 text-white shadow-xs">
                  {badgeCount}
                </span>
              )}
            </Link>
          );
        })}
      </div>
    ));
  };

  return (
    <div className="min-h-screen flex bg-zinc-50/60 dark:bg-zinc-950 transition-colors duration-300">
      {/* Desktop Sidebar */}
      <aside className="hidden md:flex flex-col w-64 border-r border-emerald-900/10 dark:border-emerald-950/60 bg-white/95 dark:bg-[#0b1a13]/95 shrink-0 sticky top-0 h-screen transition-all duration-300 z-20">
        <div className="h-16 flex items-center px-4 border-b border-emerald-900/10 dark:border-emerald-950/60">
          <AlangaLogo variant="horizontal" />
        </div>

        <nav className="flex-1 px-3 py-4 overflow-y-auto custom-scrollbar">
          {renderNavLinks()}
        </nav>

        <div className="p-3 border-t border-zinc-100 dark:border-zinc-900">
          <Button
            variant="ghost"
            onClick={handleLogout}
            className="w-full justify-start h-10 px-3 rounded-xl text-xs font-semibold text-rose-600 dark:text-rose-400 hover:bg-rose-50 dark:hover:bg-rose-950/30"
          >
            <LogOut className="h-4 w-4 mr-2.5 text-rose-500" />
            Logout Session
          </Button>
        </div>
      </aside>

      {/* Mobile Sidebar Modal */}
      {mobileMenuOpen && (
        <div className="fixed inset-0 z-50 md:hidden flex">
          <div
            className="fixed inset-0 bg-black/50 backdrop-blur-xs transition-opacity"
            onClick={() => setMobileMenuOpen(false)}
          />
          <aside className="relative flex flex-col w-72 max-w-xs bg-white dark:bg-[#0b1a13] h-full border-r border-emerald-900/10 dark:border-emerald-950/60 p-4 shadow-2xl z-10 transition-all">
            <div className="flex items-center justify-between mb-4 pb-3 border-b border-emerald-900/10 dark:border-emerald-950/60">
              <AlangaLogo variant="horizontal" />
              <Button
                variant="ghost"
                size="icon"
                className="h-8 w-8 rounded-lg"
                onClick={() => setMobileMenuOpen(false)}
              >
                <X className="h-4 w-4 text-zinc-500" />
              </Button>
            </div>

            <nav className="flex-1 overflow-y-auto pr-1">
              {renderNavLinks(() => setMobileMenuOpen(false))}
            </nav>

            <div className="pt-3 border-t border-zinc-100 dark:border-zinc-900">
              <Button
                variant="ghost"
                onClick={() => {
                  setMobileMenuOpen(false);
                  handleLogout();
                }}
                className="w-full justify-start h-10 px-3 rounded-xl text-xs font-semibold text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/30"
              >
                <LogOut className="h-4 w-4 mr-2.5 text-rose-500" />
                Logout Session
              </Button>
            </div>
          </aside>
        </div>
      )}

      {/* Main Body Area */}
      <div className="flex-1 flex flex-col min-w-0 overflow-x-hidden">
        {/* Navbar */}
        <header className="h-16 flex items-center justify-between px-4 md:px-8 border-b border-zinc-200/70 dark:border-zinc-800 bg-white/70 dark:bg-zinc-950/70 backdrop-blur-md sticky top-0 z-10 transition-colors duration-300">
          <div className="flex items-center gap-3">
            <Button
              variant="ghost"
              size="icon"
              className="md:hidden h-9 w-9 rounded-xl border border-zinc-200 dark:border-zinc-800"
              onClick={() => setMobileMenuOpen(true)}
            >
              <Menu className="h-4 w-4 text-zinc-600 dark:text-zinc-400" />
            </Button>
            {getBreadcrumbs()}
          </div>

          <div className="flex items-center gap-3">
            <ThemeToggle />

            <Link href="/requests/products">
              <Button
                variant="outline"
                size="icon"
                className="relative rounded-xl bg-white/50 dark:bg-zinc-900/50 border-emerald-900/10 dark:border-emerald-950/60 h-9 w-9"
                title="Notifications"
              >
                <Bell className="h-4 w-4 text-zinc-600 dark:text-zinc-400" />
                {summary &&
                  (summary.pendingBrands > 0 || summary.pendingProducts > 0) && (
                    <span className="absolute -top-1 -right-1 h-2.5 w-2.5 bg-amber-500 rounded-full ring-2 ring-white dark:ring-zinc-950" />
                  )}
              </Button>
            </Link>

            <DropdownMenu>
              <DropdownMenuTrigger className="flex items-center gap-2 p-1 rounded-xl hover:bg-emerald-50/50 dark:hover:bg-emerald-950/30 focus:outline-none transition-colors">
                <div className="h-8 w-8 rounded-xl bg-gradient-to-tr from-[#11261B] via-emerald-600 to-amber-500 flex items-center justify-center text-white font-bold text-xs shadow-xs border border-emerald-500/30">
                  {user?.fullName?.charAt(0) || 'A'}
                </div>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56 mt-1 rounded-2xl border-zinc-200 dark:border-zinc-800 p-2">
                <DropdownMenuLabel className="font-normal px-2 py-1.5">
                  <div className="flex flex-col space-y-1">
                    <p className="text-xs font-bold leading-none text-zinc-900 dark:text-zinc-50">
                      {user?.fullName || 'Administrator'}
                    </p>
                    <p className="text-[11px] leading-none text-zinc-500 dark:text-zinc-400">
                      {user?.email || 'admin@alanga.com'}
                    </p>
                  </div>
                </DropdownMenuLabel>
                <DropdownMenuSeparator className="bg-zinc-100 dark:bg-zinc-900 my-1" />
                <DropdownMenuItem
                  onClick={() => router.push('/settings')}
                  className="flex items-center px-2 py-1.5 rounded-lg text-xs font-medium cursor-pointer"
                >
                  <Settings className="mr-2 h-3.5 w-3.5 text-zinc-500" />
                  <span>Settings</span>
                </DropdownMenuItem>
                <DropdownMenuSeparator className="bg-zinc-100 dark:bg-zinc-900 my-1" />
                <DropdownMenuItem
                  onClick={handleLogout}
                  className="flex items-center px-2 py-1.5 rounded-lg text-xs font-semibold text-rose-600 dark:text-rose-400 cursor-pointer focus:bg-rose-50 dark:focus:bg-rose-950/30"
                >
                  <LogOut className="mr-2 h-3.5 w-3.5" />
                  <span>Log out</span>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </header>

        {/* Page Content Container */}
        <main className="flex-1 p-4 md:p-8 max-w-7xl w-full mx-auto">{children}</main>
      </div>
    </div>
  );
}
