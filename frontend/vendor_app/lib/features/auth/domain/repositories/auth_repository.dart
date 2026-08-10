import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String identifier,
    required String password,
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
    String? businessType,
    String? city,
    String? state,
    String? pincode,
    String? gstNumber,
    String? panNumber,
  });

  Future<UserEntity> getCurrentUser();
}
