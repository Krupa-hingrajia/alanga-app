import React from 'react';
import type { Metadata } from 'next';
import Link from 'next/link';
import { AlangaLogo } from '@/components/AlangaLogo';
import { ShieldCheck, Trash2, ArrowLeft, Mail, Database, CheckCircle2 } from 'lucide-react';

export const metadata: Metadata = {
  title: 'Data Deletion Policy | ALANGA Multi-Vendor Marketplace',
  description: 'Official Data Deletion and Retention Policy for ALANGA applications. Compliant with Google Play Store Data Safety requirements.',
};

export default function DataDeletionPage() {
  return (
    <div className="min-h-screen bg-slate-50 text-slate-800">
      <header className="bg-gradient-to-r from-slate-900 via-emerald-950 to-slate-900 text-white border-b border-emerald-900/30">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 py-8">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <AlangaLogo variant="emblem" size="md" />
              <div>
                <h1 className="text-xl sm:text-2xl font-bold tracking-tight text-white">ALANGA Marketplace</h1>
                <p className="text-xs text-slate-300">Data Safety & Compliance</p>
              </div>
            </div>
            <Link
              href="/privacy-policy"
              className="inline-flex items-center gap-1.5 text-xs px-3 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors border border-white/20"
            >
              <ArrowLeft className="w-3.5 h-3.5" /> Privacy Policy
            </Link>
          </div>
          <div className="mt-6 pt-6 border-t border-slate-800">
            <h2 className="text-2xl sm:text-3xl font-extrabold text-white flex items-center gap-2.5">
              <Database className="w-7 h-7 text-emerald-400" /> Data Deletion & Retention Policy
            </h2>
            <p className="mt-1 text-sm text-slate-300">
              Information regarding how personal data is managed, retained, and deleted upon request.
            </p>
          </div>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-4 sm:px-6 py-10 space-y-6">
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 sm:p-8 space-y-6">
          <section className="space-y-3">
            <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
              <CheckCircle2 className="w-5 h-5 text-emerald-600" /> User Rights Over Personal Data
            </h3>
            <p className="text-sm text-slate-600 leading-relaxed">
              Users of <strong>ALANGA Store</strong> (<code className="bg-slate-100 px-1 py-0.5 rounded text-xs">com.alanga.store</code>) and <strong>ALANGA Vendor</strong> (<code className="bg-slate-100 px-1 py-0.5 rounded text-xs">com.alanga.vendor</code>) can request partial or complete deletion of their stored data without necessarily deleting their active login account.
            </p>
          </section>

          <section className="space-y-3">
            <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
              <Trash2 className="w-5 h-5 text-red-600" /> Types of Data Eligible for Deletion
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
              <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 space-y-1">
                <div className="font-semibold text-slate-800">Delivery Address Book</div>
                <div className="text-slate-600">Remove saved home/work delivery addresses and GPS pinpoints anytime.</div>
              </div>
              <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 space-y-1">
                <div className="font-semibold text-slate-800">Search & Browsing History</div>
                <div className="text-slate-600">Clear recently viewed products and internal search queries.</div>
              </div>
              <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 space-y-1">
                <div className="font-semibold text-slate-800">Uploaded Photos & Reviews</div>
                <div className="text-slate-600">Request removal of submitted customer reviews or vendor catalog pictures.</div>
              </div>
              <div className="p-3.5 rounded-xl bg-slate-50 border border-slate-200 space-y-1">
                <div className="font-semibold text-slate-800">Full Account & Profile</div>
                <div className="text-slate-600">Permanently purge the entire user record and authentication profile.</div>
              </div>
            </div>
          </section>

          <section className="space-y-3">
            <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
              <ShieldCheck className="w-5 h-5 text-emerald-600" /> Data Retention Schedule
            </h3>
            <p className="text-sm text-slate-600 leading-relaxed">
              In accordance with tax laws and consumer protection regulations, transactional billing receipts and purchase invoices are archived in read-only encrypted format for statutory compliance audits before final disposal.
            </p>
          </section>

          <div className="pt-4 border-t border-slate-200 flex flex-col sm:flex-row gap-3 items-center justify-between">
            <Link
              href="/delete-account"
              className="inline-flex items-center gap-2 px-4 py-2.5 rounded-lg bg-red-600 hover:bg-red-700 text-white text-xs font-semibold transition-colors"
            >
              <Trash2 className="w-3.5 h-3.5" /> Submit Account Deletion Form
            </Link>
            <a
              href="mailto:info@alangashop.com?subject=Data%20Deletion%20Request"
              className="inline-flex items-center gap-1.5 text-xs text-slate-600 hover:text-slate-900 font-medium"
            >
              <Mail className="w-3.5 h-3.5 text-emerald-700" /> Email: info@alangashop.com
            </a>
          </div>
        </div>
      </main>

      <footer className="text-center py-6 text-xs text-slate-500 border-t border-slate-200 bg-white">
        © {new Date().getFullYear()} ALANGA Marketplace. All rights reserved. • <Link href="/privacy-policy" className="hover:underline">Privacy Policy</Link> • <Link href="/delete-account" className="hover:underline">Delete Account</Link>
      </footer>
    </div>
  );
}
