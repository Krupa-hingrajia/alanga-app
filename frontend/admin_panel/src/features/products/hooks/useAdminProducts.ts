import { useQuery } from '@tanstack/react-query';
import { getAdminProducts, ProductFilterParams } from '../api';

export function useAdminProducts(params?: ProductFilterParams) {
  return useQuery({
    queryKey: ['adminProducts', params],
    queryFn: () => getAdminProducts(params),
  });
}
