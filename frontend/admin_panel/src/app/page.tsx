'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/services/auth/authStore';

export default function Home() {
  const router = useRouter();
  const { accessToken } = useAuthStore();

  useEffect(() => {
    try {
      const persisted = typeof window !== 'undefined' ? localStorage.getItem('alanga-admin-auth') : null;
      const parsedToken = persisted ? JSON.parse(persisted)?.state?.accessToken : null;
      const token = accessToken || parsedToken;
      
      if (token) {
        router.replace('/dashboard');
      } else {
        router.replace('/login');
      }
    } catch {
      router.replace('/login');
    }
  }, [accessToken, router]);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-zinc-50 dark:bg-zinc-950 gap-3">
      <div className="h-8 w-8 animate-spin rounded-full border-4 border-rose-500 border-t-transparent" />
      <p className="text-xs text-zinc-400 font-medium">Redirecting to ALANGA Admin...</p>
    </div>
  );
}
