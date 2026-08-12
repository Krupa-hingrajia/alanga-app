'use client';

import React, { useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import Link from 'next/link';
import {
  LayoutDashboard,
  Users,
  FolderTree,
  GitBranch,
  Tag,
  ShoppingBag,
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
import { ThemeToggle } from '@/components/ThemeToggle';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

const sidebarLinks = [
  { href: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/vendors', label: 'Vendors', icon: Users },
  { href: '/categories', label: 'Categories', icon: FolderTree },
  { href: '/subcategories', label: 'Subcategories', icon: GitBranch },
  { href: '/brands', label: 'Brands', icon: Tag },
  { href: '/products', label: 'Products', icon: ShoppingBag },
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

  if (!mounted || !accessToken) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-zinc-50 dark:bg-zinc-950">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-rose-500 border-t-transparent" />
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
      <div className="flex items-center space-x-1 text-sm text-zinc-500 dark:text-zinc-400 capitalize">
        <span className="font-medium text-zinc-700 dark:text-zinc-300">Admin</span>
        {paths.map((p, idx) => (
          <React.Fragment key={p}>
            <ChevronRight className="h-3 w-3 text-zinc-400" />
            <span className={idx === paths.length - 1 ? 'text-zinc-900 dark:text-zinc-50 font-semibold' : ''}>
              {p}
            </span>
          </React.Fragment>
        ))}
      </div>
    );
  };

  return (
    <div className="min-h-screen flex bg-zinc-50/50 dark:bg-zinc-950/50 transition-colors duration-300">
      {/* Desktop Sidebar */}
      <aside className="hidden md:flex flex-col w-64 border-r border-zinc-200/60 dark:border-zinc-800/60 bg-white dark:bg-zinc-950 shrink-0 sticky top-0 h-screen transition-all duration-300">
        <div className="h-16 flex items-center px-6 border-b border-zinc-100 dark:border-zinc-900 gap-2">
          <div className="p-1.5 bg-gradient-to-tr from-rose-500 to-amber-500 rounded-lg text-white">
            <ShieldCheck className="h-5 w-5" />
          </div>
          <span className="font-bold text-lg bg-gradient-to-r from-rose-500 to-amber-500 bg-clip-text text-transparent">
            Alanga Admin
          </span>
        </div>

        <nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
          {sidebarLinks.map((link) => {
            const Icon = link.icon;
            const active = pathname === link.href || pathname.startsWith(link.href + '/');
            return (
              <Link
                key={link.href}
                href={link.href}
                className={`flex items-center px-4 h-11 rounded-xl text-sm font-medium gap-3 transition-all duration-200 ${
                  active
                    ? 'bg-rose-500/10 text-rose-500 dark:bg-rose-500/20'
                    : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-900 hover:text-zinc-900 dark:hover:text-zinc-50'
                }`}
              >
                <Icon className={`h-5 w-5 ${active ? 'text-rose-500' : 'text-zinc-400 dark:text-zinc-500'}`} />
                {link.label}
              </Link>
            );
          })}
        </nav>

        <div className="p-4 border-t border-zinc-100 dark:border-zinc-900">
          <Button
            variant="ghost"
            onClick={handleLogout}
            className="w-full justify-start h-11 px-4 rounded-xl text-sm font-medium text-rose-500 hover:bg-rose-500/10 hover:text-rose-500 dark:hover:bg-rose-500/20"
          >
            <LogOut className="h-5 w-5 mr-3 text-rose-500" />
            Logout
          </Button>
        </div>
      </aside>

      {/* Mobile Sidebar Modal */}
      {mobileMenuOpen && (
        <div className="fixed inset-0 z-50 md:hidden flex">
          <div className="fixed inset-0 bg-black/40 backdrop-blur-sm" onClick={() => setMobileMenuOpen(false)} />
          <aside className="relative flex flex-col w-64 max-w-xs bg-white dark:bg-zinc-950 h-full border-r border-zinc-200/60 dark:border-zinc-800/60 p-4 transition-all duration-300">
            <div className="flex items-center justify-between mb-8 pb-4 border-b border-zinc-100 dark:border-zinc-900">
              <div className="flex items-center gap-2">
                <div className="p-1.5 bg-gradient-to-tr from-rose-500 to-amber-500 rounded-lg text-white">
                  <ShieldCheck className="h-5 w-5" />
                </div>
                <span className="font-bold text-lg bg-gradient-to-r from-rose-500 to-amber-500 bg-clip-text text-transparent">
                  Alanga Admin
                </span>
              </div>
              <Button variant="ghost" size="icon" onClick={() => setMobileMenuOpen(false)}>
                <X className="h-5 w-5 text-zinc-500" />
              </Button>
            </div>

            <nav className="flex-1 space-y-1">
              {sidebarLinks.map((link) => {
                const Icon = link.icon;
                const active = pathname === link.href || pathname.startsWith(link.href + '/');
                return (
                  <Link
                    key={link.href}
                    href={link.href}
                    onClick={() => setMobileMenuOpen(false)}
                    className={`flex items-center px-4 h-11 rounded-xl text-sm font-medium gap-3 transition-all duration-200 ${
                      active
                        ? 'bg-rose-500/10 text-rose-500 dark:bg-rose-500/20'
                        : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-900 hover:text-zinc-900 dark:hover:text-zinc-50'
                    }`}
                  >
                    <Icon className={`h-5 w-5 ${active ? 'text-rose-500' : 'text-zinc-400 dark:text-zinc-500'}`} />
                    {link.label}
                  </Link>
                );
              })}
            </nav>

            <div className="pt-4 border-t border-zinc-100 dark:border-zinc-900">
              <Button
                variant="ghost"
                onClick={() => {
                  setMobileMenuOpen(false);
                  handleLogout();
                }}
                className="w-full justify-start h-11 px-4 rounded-xl text-sm font-medium text-rose-500 hover:bg-rose-500/10 hover:text-rose-500"
              >
                <LogOut className="h-5 w-5 mr-3 text-rose-500" />
                Logout
              </Button>
            </div>
          </aside>
        </div>
      )}

      {/* Main Body Area */}
      <div className="flex-1 flex flex-col min-w-0 overflow-x-hidden">
        {/* Navbar */}
        <header className="h-16 flex items-center justify-between px-4 md:px-8 border-b border-zinc-200/60 dark:border-zinc-800/60 bg-white/50 dark:bg-zinc-950/50 backdrop-blur-md sticky top-0 z-30 transition-colors duration-300">
          <div className="flex items-center gap-4">
            <Button
              variant="ghost"
              size="icon"
              className="md:hidden"
              onClick={() => setMobileMenuOpen(true)}
            >
              <Menu className="h-5 w-5 text-zinc-600 dark:text-zinc-400" />
            </Button>
            {getBreadcrumbs()}
          </div>

          <div className="flex items-center gap-4">
            <ThemeToggle />

            <Button
              variant="outline"
              size="icon"
              className="rounded-full bg-white/50 dark:bg-zinc-900/50 border-zinc-200 dark:border-zinc-800 h-9 w-9"
            >
              <Bell className="h-[1.2rem] w-[1.2rem] text-zinc-600 dark:text-zinc-400" />
            </Button>

            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <button className="flex items-center gap-2 p-1 rounded-full hover:bg-zinc-100 dark:hover:bg-zinc-900 focus:outline-none transition-colors">
                  <div className="h-8 w-8 rounded-full bg-gradient-to-tr from-rose-500 to-amber-500 flex items-center justify-center text-white font-bold text-sm shadow-md">
                    {user?.fullName?.charAt(0) || 'A'}
                  </div>
                </button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56 mt-1 border-zinc-200 dark:border-zinc-850">
                <DropdownMenuLabel className="font-normal">
                  <div className="flex flex-col space-y-1">
                    <p className="text-sm font-semibold leading-none text-zinc-900 dark:text-zinc-50">
                      {user?.fullName || 'Admin User'}
                    </p>
                    <p className="text-xs leading-none text-zinc-500 dark:text-zinc-400">
                      {user?.email || 'admin@alanga.com'}
                    </p>
                  </div>
                </DropdownMenuLabel>
                <DropdownMenuSeparator className="bg-zinc-100 dark:bg-zinc-900" />
                <DropdownMenuItem onClick={handleLogout} className="text-rose-500 focus:text-rose-500 cursor-pointer">
                  <LogOut className="mr-2 h-4 w-4" />
                  <span>Log out</span>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </header>

        {/* Page Content Container */}
        <main className="flex-1 p-4 md:p-8 overflow-y-auto">
          {children}
        </main>
      </div>
    </div>
  );
}
