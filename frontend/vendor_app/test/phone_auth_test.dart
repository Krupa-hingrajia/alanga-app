import 'package:flutter_test/flutter_test.dart';
import 'package:vendor_app/features/auth/domain/entities/user_entity.dart';
import 'package:vendor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:vendor_app/features/auth/domain/usecases/phone_auth_usecase.dart';
import 'package:vendor_app/features/auth/data/models/phone_auth_request_model.dart';
import 'package:vendor_app/features/auth/presentation/widgets/country_code_picker.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserEntity> phoneAuth({
    required String phoneNumber,
    String? fullName,
    String? businessName,
    String? email,
    String? firebaseUid,
  }) async {
    return UserEntity(
      id: 'test-user-id',
      fullName: fullName ?? 'Test Vendor',
      email: email ?? 'vendor@test.com',
      countryCode: '+91',
      mobileNumber: phoneNumber,
      role: UserRole.vendor,
      status: UserStatus.active,
      businessName: businessName ?? 'Test Store',
    );
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {}

  @override
  Future<void> deleteAccount({String? password, String? reason}) async {}

  @override
  Future<String?> forgotPassword(String identifier) async => '123456';

  @override
  Future<UserEntity> getCurrentUser() async => throw UnimplementedError();

  @override
  Future<UserEntity> login({required String identifier, required String password}) async => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
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
  }) async => throw UnimplementedError();

  @override
  Future<void> resetPassword({required String identifier, required String otp, required String newPassword}) async {}

  @override
  Future<UserEntity> updateProfile({String? fullName, String? phoneNumber, String? profileImage}) async => throw UnimplementedError();

  @override
  Future<void> verifyOtp({required String identifier, required String otp}) async {}
}

void main() {
  group('Phone Authentication Tests', () {
    late MockAuthRepository mockRepository;
    late PhoneAuthUseCase phoneAuthUseCase;

    setUp(() {
      mockRepository = MockAuthRepository();
      phoneAuthUseCase = PhoneAuthUseCase(mockRepository);
    });

    test('PhoneAuthRequestModel serializes correctly', () {
      final model = PhoneAuthRequestModel(
        phoneNumber: '+919999999999',
        fullName: 'Test Vendor',
        businessName: 'Alanga Store',
        role: 'VENDOR',
        firebaseUid: 'uid-123',
      );

      final json = model.toJson();
      expect(json['phoneNumber'], '+919999999999');
      expect(json['fullName'], 'Test Vendor');
      expect(json['businessName'], 'Alanga Store');
      expect(json['role'], 'VENDOR');
      expect(json['firebaseUid'], 'uid-123');
    });

    test('PhoneAuthUseCase returns UserEntity on success', () async {
      final user = await phoneAuthUseCase(
        phoneNumber: '+919999999999',
        fullName: 'Test Vendor',
        businessName: 'Alanga Store',
        firebaseUid: 'uid-123',
      );

      expect(user.id, 'test-user-id');
      expect(user.mobileNumber, '+919999999999');
      expect(user.role, UserRole.vendor);
      expect(user.businessName, 'Alanga Store');
    });

    test('Country code picker supports India, UAE, Sri Lanka, USA and international countries', () {
      final india = supportedCountries.firstWhere((c) => c.dialCode == '+91');
      final uae = supportedCountries.firstWhere((c) => c.dialCode == '+971');
      final sriLanka = supportedCountries.firstWhere((c) => c.dialCode == '+94');
      final usa = supportedCountries.firstWhere((c) => c.dialCode == '+1');

      expect(india.name, 'India');
      expect(uae.name, 'United Arab Emirates');
      expect(sriLanka.name, 'Sri Lanka');
      expect(usa.name, 'United States');
    });
  });
}
