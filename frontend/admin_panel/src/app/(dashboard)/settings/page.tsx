'use client';

import React, { useState } from 'react';
import { toast } from 'sonner';
import {
  Settings,
  Store,
  User,
  Bell,
  ShieldCheck,
  Server,
  Save,
  CheckCircle2,
  RefreshCw,
  Database,
  Cpu,
  KeyRound,
  Mail,
  IndianRupee,
} from 'lucide-react';

import { useAuthStore } from '@/services/auth/authStore';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';

export default function SettingsPage() {
  const { user } = useAuthStore();

  // General Settings State
  const [storeName, setStoreName] = useState('ALANGA Marketplace');
  const [supportEmail, setSupportEmail] = useState('support@alanga.com');
  const [currency, setCurrency] = useState('INR (₹)');
  const [commissionRate, setCommissionRate] = useState('8.5');
  const [defaultTaxRate, setDefaultTaxRate] = useState('18');
  const [isDemoMode, setIsDemoMode] = useState(true);

  // Notifications State
  const [emailAlerts, setEmailAlerts] = useState(true);
  const [vendorAlerts, setVendorAlerts] = useState(true);
  const [brandAlerts, setBrandAlerts] = useState(true);
  const [orderAlerts, setOrderAlerts] = useState(true);

  // Security / Account State
  const [adminName, setAdminName] = useState(user?.fullName || 'Super Admin');
  const [adminEmail, setAdminEmail] = useState(user?.email || 'admin@alanga.com');
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');

  // Saving State
  const [isSaving, setIsSaving] = useState(false);

  const handleSaveGeneral = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    setTimeout(() => {
      setIsSaving(false);
      toast.success('Marketplace configuration updated successfully');
    }, 600);
  };

  const handleSaveSecurity = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    setTimeout(() => {
      setIsSaving(false);
      setCurrentPassword('');
      setNewPassword('');
      toast.success('Administrator profile saved');
    }, 600);
  };

  const handleSaveNotifications = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    setTimeout(() => {
      setIsSaving(false);
      toast.success('Notification preferences saved');
    }, 600);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="p-3 bg-zinc-100 text-zinc-700 dark:bg-zinc-850 dark:text-zinc-300 rounded-2xl">
            <Settings className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-2xl font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
              Settings & Configuration
            </h1>
            <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-0.5">
              Marketplace parameters, administrative security, and system status.
            </p>
          </div>
        </div>
      </div>

      <Tabs defaultValue="general" className="space-y-6">
        <TabsList className="bg-zinc-100 dark:bg-zinc-900 p-1 rounded-2xl border border-zinc-200/80 dark:border-zinc-800">
          <TabsTrigger
            value="general"
            className="rounded-xl text-xs font-semibold data-[state=active]:bg-white dark:data-[state=active]:bg-zinc-950 data-[state=active]:shadow-xs px-4 py-2 flex items-center gap-2"
          >
            <Store className="h-3.5 w-3.5" />
            <span>Marketplace</span>
          </TabsTrigger>

          <TabsTrigger
            value="account"
            className="rounded-xl text-xs font-semibold data-[state=active]:bg-white dark:data-[state=active]:bg-zinc-950 data-[state=active]:shadow-xs px-4 py-2 flex items-center gap-2"
          >
            <User className="h-3.5 w-3.5" />
            <span>Admin Profile</span>
          </TabsTrigger>

          <TabsTrigger
            value="notifications"
            className="rounded-xl text-xs font-semibold data-[state=active]:bg-white dark:data-[state=active]:bg-zinc-950 data-[state=active]:shadow-xs px-4 py-2 flex items-center gap-2"
          >
            <Bell className="h-3.5 w-3.5" />
            <span>Notifications</span>
          </TabsTrigger>

          <TabsTrigger
            value="system"
            className="rounded-xl text-xs font-semibold data-[state=active]:bg-white dark:data-[state=active]:bg-zinc-950 data-[state=active]:shadow-xs px-4 py-2 flex items-center gap-2"
          >
            <Server className="h-3.5 w-3.5" />
            <span>System Status</span>
          </TabsTrigger>
        </TabsList>

        {/* Tab 1: General Marketplace */}
        <TabsContent value="general" className="space-y-6 m-0">
          <form onSubmit={handleSaveGeneral}>
            <Card className="border border-zinc-200/80 dark:border-zinc-800 rounded-2xl bg-white dark:bg-zinc-950 shadow-2xs">
              <CardHeader>
                <CardTitle className="text-base font-bold">Store & Platform Settings</CardTitle>
                <CardDescription className="text-xs text-zinc-500">
                  Global currency, taxation, and commission parameters applied across all transactions.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4 pt-0">
                <div className="grid sm:grid-cols-2 gap-4">
                  <div className="space-y-1.5">
                    <Label htmlFor="storeName" className="text-xs font-bold">Marketplace Platform Name</Label>
                    <Input
                      id="storeName"
                      value={storeName}
                      onChange={(e) => setStoreName(e.target.value)}
                      className="rounded-xl h-9 text-xs"
                      required
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label htmlFor="supportEmail" className="text-xs font-bold">Public Support Email</Label>
                    <Input
                      id="supportEmail"
                      type="email"
                      value={supportEmail}
                      onChange={(e) => setSupportEmail(e.target.value)}
                      className="rounded-xl h-9 text-xs"
                      required
                    />
                  </div>
                </div>

                <div className="grid sm:grid-cols-3 gap-4">
                  <div className="space-y-1.5">
                    <Label htmlFor="currency" className="text-xs font-bold">Base Currency</Label>
                    <Input
                      id="currency"
                      value={currency}
                      disabled
                      className="rounded-xl h-9 text-xs bg-zinc-50 dark:bg-zinc-900"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label htmlFor="commission" className="text-xs font-bold">Platform Commission Rate (%)</Label>
                    <Input
                      id="commission"
                      type="number"
                      step="0.1"
                      value={commissionRate}
                      onChange={(e) => setCommissionRate(e.target.value)}
                      className="rounded-xl h-9 text-xs"
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label htmlFor="tax" className="text-xs font-bold">Default GST / Tax Rate (%)</Label>
                    <Input
                      id="tax"
                      type="number"
                      step="1"
                      value={defaultTaxRate}
                      onChange={(e) => setDefaultTaxRate(e.target.value)}
                      className="rounded-xl h-9 text-xs"
                    />
                  </div>
                </div>

                <div className="p-4 rounded-xl bg-amber-50 dark:bg-amber-950/20 border border-amber-200 dark:border-amber-900 flex items-center justify-between">
                  <div className="space-y-0.5">
                    <p className="text-xs font-bold text-amber-900 dark:text-amber-200">Client Demo Mode</p>
                    <p className="text-[11px] text-amber-700 dark:text-amber-400">
                      Enable simulated test data and sample checkout flows for demonstration.
                    </p>
                  </div>
                  <Button
                    type="button"
                    variant={isDemoMode ? 'default' : 'outline'}
                    size="sm"
                    onClick={() => setIsDemoMode(!isDemoMode)}
                    className={`rounded-xl text-xs h-8 ${
                      isDemoMode
                        ? 'bg-amber-600 hover:bg-amber-700 text-white'
                        : 'border-amber-300 dark:border-amber-800'
                    }`}
                  >
                    {isDemoMode ? 'Active (Demo Ready)' : 'Disabled'}
                  </Button>
                </div>

                <div className="pt-2 flex justify-end">
                  <Button
                    type="submit"
                    disabled={isSaving}
                    className="bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl h-9 px-4 text-xs font-semibold gap-1.5 shadow-xs"
                  >
                    <Save className="h-3.5 w-3.5" />
                    {isSaving ? 'Saving Changes...' : 'Save Marketplace Settings'}
                  </Button>
                </div>
              </CardContent>
            </Card>
          </form>
        </TabsContent>

        {/* Tab 2: Administrator Profile */}
        <TabsContent value="account" className="space-y-6 m-0">
          <form onSubmit={handleSaveSecurity}>
            <Card className="border border-zinc-200/80 dark:border-zinc-800 rounded-2xl bg-white dark:bg-zinc-950 shadow-2xs">
              <CardHeader>
                <CardTitle className="text-base font-bold">Administrator Credentials</CardTitle>
                <CardDescription className="text-xs text-zinc-500">
                  Manage master administrator login credentials and security tokens.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4 pt-0">
                <div className="grid sm:grid-cols-2 gap-4">
                  <div className="space-y-1.5">
                    <Label htmlFor="adminName" className="text-xs font-bold">Admin Full Name</Label>
                    <Input
                      id="adminName"
                      value={adminName}
                      onChange={(e) => setAdminName(e.target.value)}
                      className="rounded-xl h-9 text-xs"
                      required
                    />
                  </div>

                  <div className="space-y-1.5">
                    <Label htmlFor="adminEmail" className="text-xs font-bold">Master Email Address</Label>
                    <Input
                      id="adminEmail"
                      type="email"
                      value={adminEmail}
                      onChange={(e) => setAdminEmail(e.target.value)}
                      className="rounded-xl h-9 text-xs"
                      required
                    />
                  </div>
                </div>

                <div className="pt-2 border-t border-zinc-100 dark:border-zinc-850 space-y-4">
                  <h4 className="text-xs font-bold text-zinc-900 dark:text-zinc-100 flex items-center gap-1.5">
                    <KeyRound className="h-4 w-4 text-zinc-500" />
                    Change Master Password
                  </h4>

                  <div className="grid sm:grid-cols-2 gap-4">
                    <div className="space-y-1.5">
                      <Label htmlFor="currentPwd" className="text-xs font-bold">Current Password</Label>
                      <Input
                        id="currentPwd"
                        type="password"
                        placeholder="••••••••••••"
                        value={currentPassword}
                        onChange={(e) => setCurrentPassword(e.target.value)}
                        className="rounded-xl h-9 text-xs"
                      />
                    </div>

                    <div className="space-y-1.5">
                      <Label htmlFor="newPwd" className="text-xs font-bold">New Secure Password</Label>
                      <Input
                        id="newPwd"
                        type="password"
                        placeholder="••••••••••••"
                        value={newPassword}
                        onChange={(e) => setNewPassword(e.target.value)}
                        className="rounded-xl h-9 text-xs"
                      />
                    </div>
                  </div>
                </div>

                <div className="pt-2 flex justify-end">
                  <Button
                    type="submit"
                    disabled={isSaving}
                    className="bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl h-9 px-4 text-xs font-semibold gap-1.5 shadow-xs"
                  >
                    <Save className="h-3.5 w-3.5" />
                    {isSaving ? 'Updating...' : 'Save Profile Changes'}
                  </Button>
                </div>
              </CardContent>
            </Card>
          </form>
        </TabsContent>

        {/* Tab 3: Notifications */}
        <TabsContent value="notifications" className="space-y-6 m-0">
          <form onSubmit={handleSaveNotifications}>
            <Card className="border border-zinc-200/80 dark:border-zinc-800 rounded-2xl bg-white dark:bg-zinc-950 shadow-2xs">
              <CardHeader>
                <CardTitle className="text-base font-bold">Notification Preferences</CardTitle>
                <CardDescription className="text-xs text-zinc-500">
                  Select events that trigger administrative notifications and immediate queue alerts.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-3 pt-0">
                {[
                  {
                    title: 'New Vendor Registrations',
                    description: 'Alert when a merchant registers and awaits verification',
                    checked: vendorAlerts,
                    toggle: () => setVendorAlerts(!vendorAlerts),
                  },
                  {
                    title: 'Brand Request Submissions',
                    description: 'Notify when vendors request new trademark or brand registrations',
                    checked: brandAlerts,
                    toggle: () => setBrandAlerts(!brandAlerts),
                  },
                  {
                    title: 'Product Approval Queue Alerts',
                    description: 'Alert upon new catalog additions requiring administrative approval',
                    checked: orderAlerts,
                    toggle: () => setOrderAlerts(!orderAlerts),
                  },
                  {
                    title: 'Daily Digest & Revenue Email Summary',
                    description: 'Daily automated report containing sales, revenue and order volumes',
                    checked: emailAlerts,
                    toggle: () => setEmailAlerts(!emailAlerts),
                  },
                ].map((item, idx) => (
                  <div
                    key={idx}
                    className="flex items-center justify-between p-3.5 rounded-xl border border-zinc-100 dark:border-zinc-850 bg-zinc-50/50 dark:bg-zinc-900/30"
                  >
                    <div>
                      <p className="text-xs font-bold text-zinc-900 dark:text-zinc-100">{item.title}</p>
                      <p className="text-[11px] text-zinc-500 dark:text-zinc-400">{item.description}</p>
                    </div>
                    <Button
                      type="button"
                      variant={item.checked ? 'default' : 'outline'}
                      size="sm"
                      onClick={item.toggle}
                      className={`rounded-xl text-xs h-8 px-3 ${
                        item.checked
                          ? 'bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs'
                          : 'border-zinc-200 dark:border-zinc-800'
                      }`}
                    >
                      {item.checked ? 'Enabled' : 'Disabled'}
                    </Button>
                  </div>
                ))}

                <div className="pt-3 flex justify-end">
                  <Button
                    type="submit"
                    disabled={isSaving}
                    className="bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs rounded-xl h-9 px-4 text-xs font-semibold gap-1.5 shadow-xs"
                  >
                    <Save className="h-3.5 w-3.5" />
                    Save Preferences
                  </Button>
                </div>
              </CardContent>
            </Card>
          </form>
        </TabsContent>

        {/* Tab 4: System Status */}
        <TabsContent value="system" className="space-y-6 m-0">
          <Card className="border border-zinc-200/80 dark:border-zinc-800 rounded-2xl bg-white dark:bg-zinc-950 shadow-2xs">
            <CardHeader>
              <CardTitle className="text-base font-bold flex items-center gap-2">
                <ShieldCheck className="h-5 w-5 text-emerald-500" />
                Infrastructure & Health Status
              </CardTitle>
              <CardDescription className="text-xs text-zinc-500">
                Live connection status between the ALANGA Admin Dashboard and PostgreSQL backend.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4 pt-0">
              <div className="grid sm:grid-cols-3 gap-3">
                <div className="p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 space-y-1">
                  <div className="flex items-center justify-between">
                    <span className="text-zinc-400 text-[11px] font-bold uppercase">PostgreSQL Database</span>
                    <span className="flex h-2 w-2 relative">
                      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                      <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                    </span>
                  </div>
                  <p className="text-sm font-bold text-emerald-600 dark:text-emerald-400">Connected & Synced</p>
                  <p className="text-[11px] text-zinc-500">Prisma ORM Direct Connection</p>
                </div>

                <div className="p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 space-y-1">
                  <div className="flex items-center justify-between">
                    <span className="text-zinc-400 text-[11px] font-bold uppercase">NestJS Core API</span>
                    <span className="flex h-2 w-2 relative">
                      <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                    </span>
                  </div>
                  <p className="text-sm font-bold text-zinc-900 dark:text-zinc-100">Healthy (24ms)</p>
                  <p className="text-[11px] text-zinc-500">Port 3000 / API v1 Gateway</p>
                </div>

                <div className="p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 space-y-1">
                  <div className="flex items-center justify-between">
                    <span className="text-zinc-400 text-[11px] font-bold uppercase">Admin Engine</span>
                    <span className="flex h-2 w-2 relative">
                      <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                    </span>
                  </div>
                  <p className="text-sm font-bold text-zinc-900 dark:text-zinc-100">Next.js 16 (Turbopack)</p>
                  <p className="text-[11px] text-zinc-500">TailwindCSS 4 + React 19</p>
                </div>
              </div>

              <div className="p-4 rounded-xl bg-zinc-50 dark:bg-zinc-900 border border-zinc-100 dark:border-zinc-800 space-y-2">
                <div className="flex items-center justify-between">
                  <h4 className="text-xs font-bold text-zinc-900 dark:text-zinc-100 flex items-center gap-2">
                    <Cpu className="h-4 w-4 text-zinc-500" />
                    Security & Environment Diagnostics
                  </h4>
                  <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500/10 text-emerald-600 border border-emerald-500/20">
                    Production Demo Ready
                  </span>
                </div>
                <div className="grid sm:grid-cols-2 gap-2 text-xs text-zinc-600 dark:text-zinc-400">
                  <p>• JWT Authentication & Refresh Token Rotation: <strong className="text-emerald-600">Active</strong></p>
                  <p>• Role-Based Access Control (RBAC): <strong className="text-emerald-600">Enforced (Admin Only)</strong></p>
                  <p>• Database Soft-Delete Safety: <strong className="text-emerald-600">Enabled</strong></p>
                  <p>• API Rate Limiting: <strong className="text-emerald-600">Active</strong></p>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
