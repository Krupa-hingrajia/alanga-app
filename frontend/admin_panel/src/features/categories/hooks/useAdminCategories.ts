import { useQuery } from '@tanstack/react-query';
import { getAdminCategories, CategoryFilterParams } from '../api';

export function useAdminCategories(params?: CategoryFilterParams) {
  return useQuery({
    queryKey: ['adminCategories', params],
    queryFn: () => getAdminCategories(params),
  });
}
