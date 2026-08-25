import { useQuery } from '@tanstack/react-query';
import { getAdminSubCategories, SubCategoryFilterParams } from '../api';

export function useAdminSubCategories(params?: SubCategoryFilterParams) {
  return useQuery({
    queryKey: ['adminSubCategories', params],
    queryFn: () => getAdminSubCategories(params),
  });
}
