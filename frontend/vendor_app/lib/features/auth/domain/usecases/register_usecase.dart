import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String fullName;
  final String email;
  final String countryCode;
  final String mobileNumber;
  final String password;
  final String confirmPassword;
  final UserRole role;
  final String? businessName;
  final String? businessType;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstNumber;
  final String? panNumber;

  RegisterParams({
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.businessName,
    this.businessType,
    this.city,
    this.state,
    this.pincode,
    this.gstNumber,
    this.panNumber,
  });
}

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<UserEntity> call(RegisterParams params) async {
    return await _repository.register(
      fullName: params.fullName,
      email: params.email,
      countryCode: params.countryCode,
      mobileNumber: params.mobileNumber,
      password: params.password,
      confirmPassword: params.confirmPassword,
      role: params.role,
      businessName: params.businessName,
      businessType: params.businessType,
      city: params.city,
      state: params.state,
      pincode: params.pincode,
      gstNumber: params.gstNumber,
      panNumber: params.panNumber,
    );
  }
}
