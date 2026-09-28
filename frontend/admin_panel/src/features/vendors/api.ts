import { client } from '@/services/api/client';

export interface VendorProfile {
  id?: string;
  storeName?: string;
  legalName?: string;
  businessType?: string;
  businessDescription?: string;
  panNumber?: string;
  panCardUrl?: string;
  gstNumber?: string;
  gstCertificateUrl?: string;
  pickupAddressLine1?: string;
  pickupAddressLine2?: string;
  pickupCity?: string;
  pickupState?: string;
  pickupPincode?: string;
  pickupContactPhone?: string;
  bankAccountHolderName?: string;
  bankAccountNumber?: string;
  bankIfscCode?: string;
  bankName?: string;
  bankAccountType?: string;
  cancelledChequeUrl?: string;
}

export interface Vendor {
  id: string;
  fullName: string;
  email: string;
  countryCode?: string;
  mobileNumber?: string;
  phoneNumber?: string | null;
  role: string;
  status: string;
  kycStatus?: string;
  vendorProfile?: VendorProfile;
  businessName?: string;
  businessType?: string;
  city?: string;
  state?: string;
  pincode?: string;
  gstNumber?: string;
  panNumber?: string;
  createdAt: string;
  updatedAt: string;
}

export interface VendorListResponse {
  items: Vendor[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export const getVendors = async (params: {
  status?: string;
  search?: string;
  page?: number;
  limit?: number;
}): Promise<VendorListResponse> => {
  const response = await client.get('/admin/vendors', { params });
  return response.data.data;
};

export const getVendorById = async (id: string): Promise<Vendor> => {
  const response = await client.get(`/admin/vendors/${id}`);
  return response.data.data;
};

export const approveVendor = async (id: string): Promise<Vendor> => {
  const response = await client.put(`/admin/vendors/${id}/approve`);
  return response.data.data;
};

export const approveVendorKyc = async (id: string): Promise<Vendor> => {
  const response = await client.put(`/admin/vendors/${id}/approve-kyc`);
  return response.data.data;
};

export const rejectVendor = async (id: string): Promise<Vendor> => {
  const response = await client.put(`/admin/vendors/${id}/reject`);
  return response.data.data;
};

export const rejectVendorKyc = async (id: string): Promise<Vendor> => {
  const response = await client.put(`/admin/vendors/${id}/reject-kyc`);
  return response.data.data;
};

export const suspendVendor = async (id: string): Promise<Vendor> => {
  const response = await client.put(`/admin/vendors/${id}/suspend`);
  return response.data.data;
};
