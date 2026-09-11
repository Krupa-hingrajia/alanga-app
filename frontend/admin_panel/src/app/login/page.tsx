'use client';

import React, { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import LoginForm from '@/features/auth/components/LoginForm';
import { useAuthStore } from '@/services/auth/authStore';

export default function LoginPage() {
  const router = useRouter();
  const { accessToken } = useAuthStore();

  useEffect(() => {
    if (accessToken) {
      router.push('/dashboard');
    }
  }, [accessToken, router]);

  return (
    <div className="relative min-h-screen flex items-center justify-center p-4 bg-[#07180f] dark:bg-[#05120b] transition-colors duration-500 overflow-hidden">
      {/* ALANGA Signature Ambient Waves & Glows */}
      <div className="absolute -top-[20%] -left-[10%] w-[60%] h-[60%] bg-emerald-600/15 rounded-full blur-[140px] pointer-events-none" />
      <div className="absolute -bottom-[20%] -right-[10%] w-[60%] h-[60%] bg-[#F99F1B]/15 rounded-full blur-[140px] pointer-events-none" />
      <div className="absolute bottom-[10%] left-[5%] w-[40%] h-[40%] bg-[#E6222B]/10 rounded-full blur-[120px] pointer-events-none" />
      <div className="absolute top-[20%] right-[15%] w-[35%] h-[35%] bg-emerald-500/10 rounded-full blur-[100px] pointer-events-none" />

      {/* Subtle Dot Grid Pattern */}
      <div
        className="absolute inset-0 opacity-[0.03] pointer-events-none"
        style={{
          backgroundImage: 'radial-gradient(#22c55e 1px, transparent 1px)',
          backgroundSize: '24px 24px',
        }}
      />

      <div className="relative z-10 w-full flex justify-center py-8">
        <LoginForm />
      </div>
    </div>
  );
}
