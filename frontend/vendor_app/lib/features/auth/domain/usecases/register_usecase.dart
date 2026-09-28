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

  // 1. Business Identity
  final String? businessName;
  final String? legalName;
  final String? businessType;

  // 2. Tax & Legal (KYC)
  final String? panNumber;
  final String? gstNumber;

  // 3. Pickup & Warehouse Address
  final String? pickupAddressLine1;
  final String? pickupAddressLine2;
  final String? city;
  final String? state;
  final String? pincode;
  final String? pickupContactPhone;

  // 4. Bank Account Details (Payouts)
  final String? bankAccountHolderName;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? bankName;
  final String? bankAccountType;

  // 5. Digital Signature
  final String? digitalSignatureUrl;

  RegisterParams({
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.businessName,
    this.legalName,
    this.businessType,
    this.panNumber,
    this.gstNumber,
    this.pickupAddressLine1,
    this.pickupAddressLine2,
    this.city,
    this.state,
    this.pincode,
    this.pickupContactPhone,
    this.bankAccountHolderName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankName,
    this.bankAccountType,
    this.digitalSignatureUrl,
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
      legalName: params.legalName,
      businessType: params.businessType,
      city: params.city,
      state: params.state,
      pincode: params.pincode,
      gstNumber: params.gstNumber,
      panNumber: params.panNumber,
      pickupAddressLine1: params.pickupAddressLine1,
      pickupAddressLine2: params.pickupAddressLine2,
      pickupContactPhone: params.pickupContactPhone,
      bankAccountHolderName: params.bankAccountHolderName,
      bankAccountNumber: params.bankAccountNumber,
      bankIfscCode: params.bankIfscCode,
      bankName: params.bankName,
      bankAccountType: params.bankAccountType,
      digitalSignatureUrl: params.digitalSignatureUrl,
    );
  }
}
