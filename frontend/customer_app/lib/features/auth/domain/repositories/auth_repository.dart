import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String identifier,
    required String password,
  });

  Future<UserEntity> phoneAuth({
    required String phoneNumber,
    String? fullName,
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
  });

  Future<UserEntity> getCurrentUser();

  Future<String?> forgotPassword(String identifier);

  Future<void> verifyOtp({
    required String identifier,
    required String otp,
  });

  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  });

  Future<String?> sendPhoneOtp(String phoneNumber);

  Future<UserEntity> verifyPhoneOtp({
    required String phoneNumber,
    required String otp,
    String? fullName,
  });
}
