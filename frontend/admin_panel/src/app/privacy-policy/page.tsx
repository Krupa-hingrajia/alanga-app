import React from 'react';
import type { Metadata } from 'next';
import Link from 'next/link';
import { AlangaLogo } from '@/components/AlangaLogo';
import { Shield, Lock, FileText, Trash2, Mail, MapPin, ArrowRight, CheckCircle2 } from 'lucide-react';

export const metadata: Metadata = {
  title: 'Privacy Policy | ALANGA Multi-Vendor Marketplace',
  description: 'Official Privacy Policy for ALANGA Customer App (com.alanga.store) and ALANGA Vendor App (com.alanga.vendor). Fully compliant with Google Play Store standards.',
};

export default function PrivacyPolicyPage() {
  return (
    <div className="min-h-screen bg-slate-50 text-slate-800">
      {/* Header */}
      <header className="bg-gradient-to-r from-emerald-950 via-emerald-900 to-slate-900 text-white border-b border-emerald-800/40">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 py-8">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <AlangaLogo variant="emblem" size="md" />
              <div>
                <h1 className="text-xl sm:text-2xl font-bold tracking-tight text-white">ALANGA Marketplace</h1>
                <p className="text-xs text-emerald-200">Legal & Privacy Center</p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" /> Google Play Compliant
              </span>
              <Link
                href="/delete-account"
                className="inline-flex items-center gap-1 text-xs px-3 py-1.5 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-colors border border-white/20"
              >
                <Trash2 className="w-3.5 h-3.5" /> Account Deletion
              </Link>
            </div>
          </div>
          <div className="mt-6 pt-6 border-t border-emerald-800/40">
            <h2 className="text-2xl sm:text-3xl font-extrabold text-white">Privacy Policy</h2>
            <p className="mt-1 text-sm text-emerald-100/80">
              Last Updated & Effective: October 13, 2026 • Applies to ALANGA Customer App & ALANGA Vendor App
            </p>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-5xl mx-auto px-4 sm:px-6 py-10">
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200/80 p-6 sm:p-10 space-y-8">
          
          {/* Quick Notice */}
          <div className="rounded-xl bg-emerald-50/60 border border-emerald-200 p-4 sm:p-5 flex items-start gap-3">
            <Shield className="w-5 h-5 text-emerald-700 shrink-0 mt-0.5" />
            <div className="text-sm text-emerald-900 leading-relaxed">
              <strong>Your Privacy Matters:</strong> This Privacy Policy applies to the <strong>ALANGA Customer Application</strong> (<code className="bg-emerald-100 px-1 py-0.5 rounded text-xs font-mono">com.alanga.store</code>) and <strong>ALANGA Vendor Application</strong> (<code className="bg-emerald-100 px-1 py-0.5 rounded text-xs font-mono">com.alanga.vendor</code>). We treat your personal and transactional information with extreme confidentiality and industry-standard security.
            </div>
          </div>

          {/* Section 1 */}
          <section className="space-y-3">
            <h3 className="text-lg font-bold text-slate-900 flex items-center gap-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center text-xs font-bold">1</span>
              Overview & Scope
            </h3>
            <p className="text-sm text-slate-600 leading-relaxed">
              ALANGA (&quot;we&quot;, &quot;our&quot;, or &quot;us&quot;) operates a multi-vendor digital commerce marketplace connecting customers with verified merchant stores and suppliers. This policy explains what personal data we collect, why we collect it, how it is safeguarded, and your legal rights over your information.
            </p>
          </section>

          {/* Section 2 */}
          <section className="space-y-3">
            <h3 className="text-lg font-bold text-slate-900 flex items-center gap-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center text-xs font-bold">2</span>
              Information We Collect
            </h3>
            <div className="space-y-3 text-sm text-slate-600 leading-relaxed">
              <div className="p-3.5 rounded-lg bg-slate-50 border border-slate-200">
                <h4 className="font-semibold text-slate-800 mb-1">A. Customer Data (Alanga Store App)</h4>
                <ul className="list-disc list-inside space-y-1 text-slate-600">
                  <li><strong>Account Identity:</strong> Phone number and email address verified through secure One-Time Passwords (OTP).</li>
                  <li><strong>Profile & Addresses:</strong> Full name, delivery addresses, postal pin-codes, and delivery contact details.</li>
                  <li><strong>Order & Purchase History:</strong> Cart contents, placed orders, invoice amounts, payment reference IDs, and fulfillment status.</li>
                </ul>
              </div>

              <div className="p-3.5 rounded-lg bg-slate-50 border border-slate-200">
                <h4 className="font-semibold text-slate-800 mb-1">B. Vendor & Merchant Data (Alanga Vendor App)</h4>
                <ul className="list-disc list-inside space-y-1 text-slate-600">
                  <li><strong>Business Profile:</strong> Store name, registered merchant contact, business tax identification (e.g. GST/PAN where applicable).</li>
                  <li><strong>Payout & Financial Info:</strong> Settlement bank accounts or UPI identifiers for receiving product sales disbursements.</li>
                  <li><strong>Catalog Media:</strong> Product listings, photos, variant attributes, and store description banners.</li>
                </ul>
              </div>

              <div className="p-3.5 rounded-lg bg-slate-50 border border-slate-200">
                <h4 className="font-semibold text-slate-800 mb-1">C. Device & Technical Diagnostics</h4>
                <p>Device brand/model, operating system version, network state, and crash analytics for maintaining application stability and preventing fraudulent logins.</p>
              </div>
            </div>
          </section>

          {/* Section 3 */}
          <section className="space-y-3">
            <h3 className="text-lg font-bold text-slate-900 flex items-center gap-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center text-xs font-bold">3</span>
              App Permissions & Justification
            </h3>
            <div className="text-sm text-slate-600 overflow-x-auto">
              <table className="w-full text-left border-collapse border border-slate-200 rounded-lg">
                <thead>
                  <tr className="bg-slate-100 text-slate-700 font-semibold text-xs uppercase tracking-wider">
                    <th className="p-3 border-b border-slate-200">Permission</th>
                    <th className="p-3 border-b border-slate-200">Purpose</th>
                    <th className="p-3 border-b border-slate-200">Optional / Mandatory</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-200 text-xs">
                  <tr>
                    <td className="p-3 font-medium text-slate-800">Internet & Network</td>
                    <td className="p-3">Communicating with backend servers for catalog, cart, and orders.</td>
                    <td className="p-3 text-emerald-700 font-semibold">Mandatory</td>
                  </tr>
                  <tr>
                    <td className="p-3 font-medium text-slate-800">Location (Coarse/Fine)</td>
                    <td className="p-3">Autofilling delivery address and detecting serviceable delivery zones.</td>
                    <td className="p-3 text-slate-600">Optional (User-Prompted)</td>
                  </tr>
                  <tr>
                    <td className="p-3 font-medium text-slate-800">Camera & Photos</td>
                    <td className="p-3">Uploading product catalog images (Vendors) or return/review evidence (Customers).</td>
                    <td className="p-3 text-slate-600">Optional (User-Prompted)</td>
                  </tr>
                  <tr>
                    <td className="p-3 font-medium text-slate-800">Notifications</td>
                    <td className="p-3">Real-time status updates on order dispatch, delivery, and important alerts.</td>
                    <td className="p-3 text-slate-600">Optional</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>

          {/* Section 4 */}
          <section className="space-y-3">
            <h3 className="text-lg font-bold text-slate-900 flex items-center gap-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center text-xs font-bold">4</span>
              How We Use and Protect Your Data
            </h3>
            <p className="text-sm text-slate-600 leading-relaxed">
              We never sell or rent your personal information to third parties. Data is used strictly for fulfilling orders, managing payments, verifying account identity, and delivering customer support. Sensitive credentials and tokens are secured via modern cryptographic hashing and HTTPS TLS 1.3 transport encryption.
            </p>
          </section>

          {/* Section 5 - Deletion */}
          <section className="space-y-3">
            <h3 className="text-lg font-bold text-slate-900 flex items-center gap-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center text-xs font-bold">5</span>
              Account & Data Deletion Rights
            </h3>
            <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 space-y-2">
              <p className="text-sm text-slate-700">
                You have the full right to delete your account and associated personal data at any time.
              </p>
              <div className="flex flex-col sm:flex-row gap-2 pt-2">
                <Link
                  href="/delete-account"
                  className="inline-flex items-center justify-center gap-2 px-4 py-2 rounded-lg bg-emerald-800 hover:bg-emerald-900 text-white text-xs font-semibold transition-colors"
                >
                  <Trash2 className="w-3.5 h-3.5" /> Request Account & Data Deletion <ArrowRight className="w-3.5 h-3.5" />
                </Link>
                <Link
                  href="/data-deletion"
                  className="inline-flex items-center justify-center gap-2 px-4 py-2 rounded-lg bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 text-xs font-medium transition-colors"
                >
                  <FileText className="w-3.5 h-3.5" /> Learn Data Retention Practices
                </Link>
              </div>
            </div>
          </section>

          {/* Section 6 - Children */}
          <section className="space-y-3">
            <h3 className="text-lg font-bold text-slate-900 flex items-center gap-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center text-xs font-bold">6</span>
              Children&apos;s Privacy
            </h3>
            <p className="text-sm text-slate-600 leading-relaxed">
              Our applications are not directed toward children under 13 years of age. We do not knowingly collect personal identifiable information from children.
            </p>
          </section>

          {/* Section 7 - Contact */}
          <section className="space-y-3 pt-4 border-t border-slate-200">
            <h3 className="text-lg font-bold text-slate-900 flex items-center gap-2">
              <span className="w-6 h-6 rounded-full bg-emerald-100 text-emerald-800 flex items-center justify-center text-xs font-bold">7</span>
              Contact & Privacy Inquiries
            </h3>
            <p className="text-sm text-slate-600">
              For any questions, data subject requests, or privacy concerns, please contact our Data Protection Officer:
            </p>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs text-slate-700 pt-2">
              <div className="p-3 rounded-lg bg-slate-50 border border-slate-200 flex items-center gap-2.5">
                <Mail className="w-4 h-4 text-emerald-700 shrink-0" />
                <div>
                  <div className="font-semibold text-slate-900">Email Support</div>
                  <a href="mailto:info@alangashop.com" className="text-emerald-700 hover:underline">info@alangashop.com</a>
                </div>
              </div>
              <div className="p-3 rounded-lg bg-slate-50 border border-slate-200 flex items-center gap-2.5">
                <MapPin className="w-4 h-4 text-emerald-700 shrink-0" />
                <div>
                  <div className="font-semibold text-slate-900">Registered Office</div>
                  <div>Navi Mumbai, Maharashtra, India</div>
                </div>
              </div>
            </div>
          </section>

        </div>
      </main>

      {/* Footer */}
      <footer className="text-center py-6 text-xs text-slate-500 border-t border-slate-200 bg-white">
        © {new Date().getFullYear()} ALANGA Marketplace. All rights reserved. • <Link href="/privacy-policy" className="hover:underline">Privacy Policy</Link> • <Link href="/delete-account" className="hover:underline">Delete Account</Link>
      </footer>
    </div>
  );
}
