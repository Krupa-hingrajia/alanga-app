import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String identifier,
    required String password,
  });

  Future<UserEntity> phoneAuth({
    required String phoneNumber,
    String? fullName,
    String? businessName,
    String? email,
    String? firebaseUid,
  });

  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String countryCode,
    required String mobileNumber,
    required String password,
    required String confirmPassword,
    required UserRole role,
    String? businessName,
    String? legalName,
    String? businessType,
    String? city,
    String? state,
    String? pincode,
    String? gstNumber,
    String? panNumber,
    String? pickupAddressLine1,
    String? pickupAddressLine2,
    String? pickupContactPhone,
    String? bankAccountHolderName,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankName,
    String? bankAccountType,
    String? digitalSignatureUrl,
  });

  Future<UserEntity> getCurrentUser();

  Future<void> logout();

  Future<String?> forgotPassword(String identifier);

  Future<void> verifyOtp({required String identifier, required String otp});

  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteAccount({String? password, String? reason});

  Future<UserEntity> updateProfile({
    String? fullName,
    String? email,
    String? businessName,
    String? phoneNumber,
    String? profileImage,
  });
}
