'use client';

import React, { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useMutation } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';
import { Mail, Lock, Eye, EyeOff, Loader2 } from 'lucide-react';
import { toast } from 'sonner';

import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card';
import { loginSchema, LoginCredentials } from '../types';
import { loginAdmin } from '../api';

import { AlangaLogo } from '@/components/AlangaLogo';

export default function LoginForm() {
  const router = useRouter();
  const [showPassword, setShowPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginCredentials>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      identifier: '',
      password: '',
    },
  });

  const loginMutation = useMutation({
    mutationFn: loginAdmin,
    onSuccess: (data) => {
      toast.success(data.message || 'Login successful!');
      router.push('/dashboard');
    },
    onError: (error: any) => {
      const errorMsg = error.response?.data?.message || 'Invalid email or password.';
      toast.error(errorMsg);
    },
  });

  const onSubmit = (data: LoginCredentials) => {
    loginMutation.mutate(data);
  };

  return (
    <Card className="w-full max-w-md border border-emerald-900/20 dark:border-emerald-800/40 shadow-2xl bg-white/95 dark:bg-[#0c1f15]/95 backdrop-blur-xl transition-all duration-300 overflow-hidden relative">
      {/* ALANGA Trademark Brand Ribbon */}
      <div className="h-1.5 w-full bg-gradient-to-r from-[#E6222B] via-[#F99F1B] via-[#EBDD1C] to-[#229944]" />
      
      <CardHeader className="space-y-2 pt-6">
        <div className="flex justify-center mb-2">
          <AlangaLogo size="md" variant="full" />
        </div>
        <CardTitle className="text-xl font-bold text-center tracking-tight text-zinc-900 dark:text-zinc-50">
          Admin Control Center
        </CardTitle>
        <CardDescription className="text-center text-xs text-zinc-500 dark:text-zinc-400">
          Authorized personnel only. Please sign in with your admin credentials.
        </CardDescription>
      </CardHeader>

      <form onSubmit={handleSubmit(onSubmit)}>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="identifier" className="text-sm font-medium text-zinc-700 dark:text-zinc-300">
              Email Address
            </Label>
            <div className="relative">
              <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-400" />
              <Input
                id="identifier"
                type="text"
                placeholder="admin@alanga.com"
                className="pl-10 h-11 bg-zinc-50 dark:bg-zinc-900 border-zinc-200 dark:border-zinc-800 focus:ring-emerald-500/20 focus:border-emerald-600 rounded-xl text-sm"
                disabled={loginMutation.isPending}
                {...register('identifier')}
              />
            </div>
            {errors.identifier && (
              <p className="text-xs text-red-500 font-medium mt-1">{errors.identifier.message}</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="password" className="text-sm font-medium text-zinc-700 dark:text-zinc-300">
              Password
            </Label>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-400" />
              <Input
                id="password"
                type={showPassword ? 'text' : 'password'}
                placeholder="••••••••"
                className="pl-10 pr-10 h-11 bg-zinc-50 dark:bg-zinc-900 border-zinc-200 dark:border-zinc-800 focus:ring-emerald-500/20 focus:border-emerald-600 rounded-xl text-sm"
                disabled={loginMutation.isPending}
                {...register('password')}
              />
              <button
                type="button"
                className="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 transition-colors"
                onClick={() => setShowPassword(!showPassword)}
                disabled={loginMutation.isPending}
              >
                {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
              </button>
            </div>
            {errors.password && (
              <p className="text-xs text-red-500 font-medium mt-1">{errors.password.message}</p>
            )}
          </div>
        </CardContent>

        <CardFooter className="pt-2 pb-6">
          <Button
            type="submit"
            className="w-full h-11 font-semibold text-white bg-gradient-to-r from-emerald-600 via-emerald-700 to-emerald-800 hover:from-emerald-700 hover:to-emerald-900 shadow-md shadow-emerald-700/25 hover:shadow-lg rounded-xl transition-all duration-300"
            disabled={loginMutation.isPending}
          >
            {loginMutation.isPending ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Signing you in...
              </>
            ) : (
              'Sign In to Dashboard'
            )}
          </Button>
        </CardFooter>
      </form>
    </Card>
  );
}
