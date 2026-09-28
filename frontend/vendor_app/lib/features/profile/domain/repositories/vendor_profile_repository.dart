import '../../data/models/vendor_profile_model.dart';

abstract class VendorProfileRepository {
  Future<VendorProfileModel> getProfile();
  Future<VendorProfileModel> updateProfile(Map<String, dynamic> data);
}
