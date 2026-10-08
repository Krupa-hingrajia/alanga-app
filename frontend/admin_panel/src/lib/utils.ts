import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function getMediaUrl(path?: string | null): string {
  if (!path) return '';
  if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('data:')) {
    return path;
  }
  const apiUrl =
    process.env.NEXT_PUBLIC_API_URL ||
    'https://alanga-backend-uat-807103326316.asia-southeast1.run.app/api/v1';
  const baseUrl = apiUrl.replace(/\/api(\/v\d+)?\/?$/, '');
  return `${baseUrl}${path.startsWith('/') ? '' : '/'}${path}`;
}
