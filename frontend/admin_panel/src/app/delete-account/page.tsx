'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { AlangaLogo } from '@/components/AlangaLogo';
import { Trash2, AlertTriangle, CheckCircle2, ShieldCheck, Mail, ArrowLeft, Send } from 'lucide-react';

export default function DeleteAccountPage() {
  const [submitted, setSubmitted] = useState(false);
  const [phoneOrEmail, setPhoneOrEmail] = useState('');
  const [accountType, setAccountType] = useState('customer');
  const [reason, setReason] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!phoneOrEmail) return;
    setSubmitted(true);
  };

  return (
    <div className="min-h-screen bg-slate-50 text-slate-800">
      {/* Header */}
      <header className="bg-gradient-to-r from-red-950 via-slate-900 to-slate-900 text-white border-b border-red-900/30">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 py-8">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <AlangaLogo variant="emblem" size="md" />
              <div>
                <h1 className="text-xl sm:text-2xl font-bold tracking-tight text-white">ALANGA Marketplace</h1>
                <p className="text-xs text-slate-300">Account & Data Management Portal</p>
              </div>
            </div>
            <Link
              href="/privacy-policy"
              className="inline-flex items-center gap-1.5 text-xs px-3 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors border border-white/20"
            >
              <ArrowLeft className="w-3.5 h-3.5" /> Back to Privacy Policy
            </Link>
          </div>
          <div className="mt-6 pt-6 border-t border-slate-800">
            <h2 className="text-2xl sm:text-3xl font-extrabold text-white flex items-center gap-2.5">
              <Trash2 className="w-7 h-7 text-red-400" /> Account & Data Deletion
            </h2>
            <p className="mt-1 text-sm text-slate-300">
              Submit a formal request to delete your ALANGA customer or vendor account and associated data.
            </p>
          </div>
        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-4xl mx-auto px-4 sm:px-6 py-10 space-y-8">
        
        {/* Policy Information Card */}
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 sm:p-8 space-y-6">
          <div className="flex items-start gap-3 p-4 rounded-xl bg-amber-50 border border-amber-200">
            <AlertTriangle className="w-5 h-5 text-amber-700 shrink-0 mt-0.5" />
            <div className="text-sm text-amber-900 leading-relaxed">
              <strong>Google Play User Notice:</strong> You have the right to request the permanent deletion of your account and personal data from both <strong>ALANGA Store (Customer App)</strong> and <strong>ALANGA Vendor App</strong>. Please read below what data is removed and what is retained for statutory compliance.
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 space-y-2">
              <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                <Trash2 className="w-4 h-4 text-red-600" /> Data That Will Be Deleted
              </h3>
              <ul className="text-xs text-slate-600 list-disc list-inside space-y-1">
                <li>Personal Profile (Name, Phone number, Email address)</li>
                <li>Saved delivery addresses and GPS coordinates</li>
                <li>Active shopping cart items and wishlists</li>
                <li>Device authentication tokens and login sessions</li>
                <li>App notification subscriptions</li>
              </ul>
            </div>

            <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 space-y-2">
              <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                <ShieldCheck className="w-4 h-4 text-emerald-600" /> Data Retained by Law
              </h3>
              <ul className="text-xs text-slate-600 list-disc list-inside space-y-1">
                <li>Tax invoices and financial accounting records (required by Indian tax and commercial statutes for audit)</li>
                <li>Past fulfilled delivery logs for warranty/fraud dispute protection</li>
                <li>Retained securely in anonymized archive for statutory retention periods</li>
              </ul>
            </div>
          </div>

          {/* In-App Deletion Steps */}
          <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 space-y-2">
            <h3 className="font-bold text-sm text-slate-900">How to Delete Directly from the App</h3>
            <ol className="text-xs text-slate-600 list-decimal list-inside space-y-1">
              <li>Open the <strong>ALANGA</strong> app on your Android device.</li>
              <li>Tap the <strong>Profile</strong> tab in the bottom navigation bar.</li>
              <li>Go to <strong>Settings</strong> ➔ <strong>Account & Security</strong>.</li>
              <li>Tap <strong>Delete Account</strong> and confirm your request with OTP.</li>
            </ol>
          </div>
        </div>

        {/* Web Deletion Request Form */}
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 sm:p-8 space-y-6">
          <h3 className="text-lg font-bold text-slate-900">Online Deletion Request Form</h3>
          <p className="text-xs text-slate-600">
            If you no longer have the app installed, submit the form below. Our support team will process your request within 7 business days.
          </p>

          {submitted ? (
            <div className="p-6 rounded-xl bg-emerald-50 border border-emerald-200 text-center space-y-3">
              <CheckCircle2 className="w-10 h-10 text-emerald-600 mx-auto" />
              <h4 className="font-bold text-emerald-900 text-base">Request Submitted Successfully</h4>
              <p className="text-xs text-emerald-800 max-w-md mx-auto">
                We have received your account deletion request for <strong>{phoneOrEmail}</strong>. A confirmation SMS/Email with verification instructions will be sent.
              </p>
              <button
                type="button"
                onClick={() => setSubmitted(false)}
                className="text-xs text-emerald-700 underline font-medium hover:text-emerald-900"
              >
                Submit another request
              </button>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-4 max-w-lg">
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Account Type <span className="text-red-500">*</span>
                </label>
                <div className="grid grid-cols-2 gap-3">
                  <label className={`flex items-center gap-2 p-3 rounded-lg border text-xs font-medium cursor-pointer transition-colors ${accountType === 'customer' ? 'border-emerald-700 bg-emerald-50 text-emerald-900' : 'border-slate-200 hover:bg-slate-50'}`}>
                    <input
                      type="radio"
                      name="accountType"
                      value="customer"
                      checked={accountType === 'customer'}
                      onChange={(e) => setAccountType(e.target.value)}
                      className="accent-emerald-700"
                    />
                    Customer Account
                  </label>
                  <label className={`flex items-center gap-2 p-3 rounded-lg border text-xs font-medium cursor-pointer transition-colors ${accountType === 'vendor' ? 'border-emerald-700 bg-emerald-50 text-emerald-900' : 'border-slate-200 hover:bg-slate-50'}`}>
                    <input
                      type="radio"
                      name="accountType"
                      value="vendor"
                      checked={accountType === 'vendor'}
                      onChange={(e) => setAccountType(e.target.value)}
                      className="accent-emerald-700"
                    />
                    Vendor / Merchant
                  </label>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Registered Mobile Number or Email <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  placeholder="+91 9876543210 or yourname@example.com"
                  value={phoneOrEmail}
                  onChange={(e) => setPhoneOrEmail(e.target.value)}
                  className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-xs focus:ring-2 focus:ring-emerald-700 focus:outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Reason for Deletion (Optional)
                </label>
                <textarea
                  rows={3}
                  placeholder="Tell us why you would like to delete your account..."
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-xs focus:ring-2 focus:ring-emerald-700 focus:outline-none"
                />
              </div>

              <div className="pt-2">
                <button
                  type="submit"
                  className="inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-lg bg-red-600 hover:bg-red-700 text-white text-xs font-semibold transition-colors shadow-sm"
                >
                  <Send className="w-3.5 h-3.5" /> Submit Deletion Request
                </button>
              </div>
            </form>
          )}

          {/* Direct Contact Support */}
          <div className="pt-6 border-t border-slate-200 text-xs text-slate-600 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2">
            <span>Prefer to email us directly?</span>
            <a
              href="mailto:info@alangashop.com?subject=Account%20Deletion%20Request"
              className="inline-flex items-center gap-1.5 font-semibold text-emerald-700 hover:underline"
            >
              <Mail className="w-3.5 h-3.5" /> info@alangashop.com
            </a>
          </div>
        </div>

      </main>

      {/* Footer */}
      <footer className="text-center py-6 text-xs text-slate-500 border-t border-slate-200 bg-white">
        © {new Date().getFullYear()} ALANGA Marketplace. All rights reserved. • <Link href="/privacy-policy" className="hover:underline">Privacy Policy</Link> • <Link href="/delete-account" className="hover:underline">Delete Account</Link>
      </footer>
    </div>
  );
}
