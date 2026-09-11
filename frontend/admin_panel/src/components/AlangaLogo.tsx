import React from 'react';
import Image from 'next/image';

interface AlangaLogoProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
  showTagline?: boolean;
  variant?: 'full' | 'emblem' | 'horizontal';
  className?: string;
}

export function AlangaLogo({
  size = 'md',
  showTagline = true,
  variant = 'horizontal',
  className = '',
}: AlangaLogoProps) {
  if (variant === 'emblem') {
    const dimensions = {
      sm: { width: 32, height: 32 },
      md: { width: 40, height: 40 },
      lg: { width: 56, height: 56 },
      xl: { width: 80, height: 80 },
    }[size];

    return (
      <div className={`relative flex items-center justify-center shrink-0 rounded-2xl overflow-hidden shadow-sm ${className}`}>
        <Image
          src="/alanga-emblem.png"
          alt="ALANGA Emblem"
          width={dimensions.width}
          height={dimensions.height}
          className="object-cover rounded-xl"
          priority
        />
      </div>
    );
  }

  if (variant === 'full') {
    const width = size === 'sm' ? 140 : size === 'md' ? 190 : size === 'lg' ? 240 : 300;
    const height = Math.round(width * (265 / 280));

    return (
      <div className={`flex flex-col items-center justify-center text-center ${className}`}>
        <div className="relative rounded-2xl overflow-hidden shadow-xl border border-emerald-800/30 bg-[#0c2e1c] p-2">
          <Image
            src="/alanga-logo.png"
            alt="ALANGA - Quality Products, Trusted Choice"
            width={width}
            height={height}
            className="object-contain"
            priority
          />
        </div>
      </div>
    );
  }

  // Horizontal variant (default for Sidebar & Headers)
  return (
    <div className={`flex items-center gap-3 ${className}`}>
      <div className="relative h-10 w-10 shrink-0 rounded-xl overflow-hidden bg-[#0c2e1c] p-1 border border-emerald-700/50 shadow-sm flex items-center justify-center">
        <Image
          src="/alanga-emblem.png"
          alt="ALANGA"
          width={36}
          height={36}
          className="object-contain"
          priority
        />
      </div>
      <div className="flex flex-col">
        <div className="flex items-center gap-1.5">
          <span className="font-extrabold text-base tracking-wider text-zinc-900 dark:text-zinc-50">
            ALANGA
          </span>
          <span className="text-[10px] uppercase font-bold tracking-widest px-1.5 py-0.5 rounded bg-gradient-to-r from-amber-500 to-emerald-600 text-white shadow-2xs">
            ADMIN
          </span>
        </div>
        {showTagline && (
          <span className="text-[9px] font-semibold tracking-wider text-emerald-700 dark:text-emerald-400 uppercase">
            Quality Products, Trusted Choice
          </span>
        )}
      </div>
    </div>
  );
}

export default AlangaLogo;
