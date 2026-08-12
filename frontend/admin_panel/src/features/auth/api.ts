import { client } from '@/services/api/client';
import { useAuthStore, User } from '@/services/auth/authStore';
import { LoginCredentials, LoginResponse } from './types';

export const loginAdmin = async (credentials: LoginCredentials): Promise<LoginResponse> => {
  const response = await client.post('/admin/auth/login', credentials);
  const { data } = response.data;
  
  // Set auth state
  useAuthStore.getState().setAuth(
    data.user,
    data.accessToken,
    data.refreshToken
  );
  
  return response.data;
};

export const logoutAdmin = async (): Promise<void> => {
  try {
    const refresh = useAuthStore.getState().refreshToken;
    if (refresh) {
      await client.post('/admin/auth/logout', { refreshToken: refresh });
    }
  } catch (err) {
    console.error('Logout error on backend:', err);
  } finally {
    useAuthStore.getState().logout();
  }
};

export const getAdminProfile = async (): Promise<User> => {
  const response = await client.get('/admin/auth/profile');
  return response.data.data;
};
