import 'package:dio/dio.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../../../../core/error/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storageService;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService storageService,
  })  : _remoteDataSource = remoteDataSource,
        _storageService = storageService;

  @override
  Future<UserEntity> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final loginModel = LoginRequestModel(identifier: identifier, password: password);
      final response = await _remoteDataSource.login(loginModel);

      await _storageService.saveAccessToken(response.accessToken);
      await _storageService.saveRefreshToken(response.refreshToken);
      await _storageService.saveUserData(response.user.toJson());

      return response.user.toEntity();
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      throw ServerFailure(message);
    }
  }

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
    String? businessType,
    String? city,
    String? state,
    String? pincode,
    String? gstNumber,
    String? panNumber,
  }) async {
    try {
      String roleStr = 'CUSTOMER';
      if (role == UserRole.admin) {
        roleStr = 'ADMIN';
      } else if (role == UserRole.vendor) {
        roleStr = 'VENDOR';
      }

      final registerModel = RegisterRequestModel(
        fullName: fullName,
        email: email,
        countryCode: countryCode,
        mobileNumber: mobileNumber,
        password: password,
        confirmPassword: confirmPassword,
        role: roleStr,
        businessName: businessName,
        businessType: businessType,
        city: city,
        state: state,
        pincode: pincode,
        gstNumber: gstNumber,
        panNumber: panNumber,
      );

      final response = await _remoteDataSource.register(registerModel);
      return response.user.toEntity();
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      throw ServerFailure(message);
    }
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      await _storageService.saveUserData(userModel.toJson());
      return userModel.toEntity();
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      throw ServerFailure(message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Continue clearing storage
    } finally {
      await _storageService.clearAll();
    }
  }

  @override
  Future<String?> forgotPassword(String identifier) async {
    try {
      return await _remoteDataSource.forgotPassword(identifier);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> verifyOtp({required String identifier, required String otp}) async {
    try {
      await _remoteDataSource.verifyOtp(identifier, otp);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(identifier, otp, newPassword);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(currentPassword, newPassword);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteAccount({String? password, String? reason}) async {
    try {
      await _remoteDataSource.deleteAccount(password: password, reason: reason);
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    } catch (e) {
      // If network offline or endpoint issue, still ensure local wipe for Apple compliance
      await _storageService.clearAll();
      rethrow;
    } finally {
      await _storageService.clearAll();
    }
  }

  @override
  Future<UserEntity> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profileImage,
  }) async {
    try {
      final updatedModel = await _remoteDataSource.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
      );
      final currentData = await _storageService.getUserData() ?? {};
      if (fullName != null) currentData['fullName'] = fullName;
      if (phoneNumber != null) currentData['phoneNumber'] = phoneNumber;
      if (profileImage != null) currentData['profileImage'] = profileImage;
      await _storageService.saveUserData(currentData);
      return updatedModel.toEntity();
    } on DioException catch (e) {
      throw ServerFailure(_getErrorMessage(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final responseData = e.response?.data;
      if (responseData is Map && responseData.containsKey('message')) {
        return responseData['message'] as String;
      }
    }
    return e.message ?? 'Unknown connection error';
  }
}
