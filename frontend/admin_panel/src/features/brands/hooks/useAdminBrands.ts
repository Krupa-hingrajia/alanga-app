import { useQuery } from '@tanstack/react-query';
import { getAdminBrands, BrandFilterParams } from '../api';

export function useAdminBrands(params?: BrandFilterParams) {
  return useQuery({
    queryKey: ['adminBrands', params],
    queryFn: () => getAdminBrands(params),
  });
}
