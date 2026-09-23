import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<RegisterResponseModel> register(RegisterRequestModel request);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
  Future<String?> forgotPassword(String identifier);
  Future<void> verifyOtp(String identifier, String otp);
  Future<void> resetPassword(String identifier, String otp, String newPassword);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount({String? password, String? reason});
  Future<UserModel> updateProfile({String? fullName, String? phoneNumber, String? profileImage});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSourceImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return LoginResponseModel.fromJson(data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return RegisterResponseModel.fromJson(data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiEndpoints.me);
      final data = response.data['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout);
    } catch (_) {
      // Gracefully handle logout network issue
    }
  }

  @override
  Future<String?> forgotPassword(String identifier) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.forgotPassword,
        data: {'identifier': identifier},
      );
      final data = response.data as Map<String, dynamic>?;
      return data?['devOtp'] as String?;
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> verifyOtp(String identifier, String otp) async {
    try {
      await _apiService.post(
        ApiEndpoints.verifyOtp,
        data: {'identifier': identifier, 'otp': otp},
      );
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String identifier, String otp, String newPassword) async {
    try {
      await _apiService.post(
        ApiEndpoints.resetPassword,
        data: {
          'identifier': identifier,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _apiService.post(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount({String? password, String? reason}) async {
    try {
      await _apiService.delete(
        ApiEndpoints.deleteAccount,
        data: {
          if (password != null) 'password': password,
          if (reason != null) 'reason': reason,
        },
      );
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile({String? fullName, String? phoneNumber, String? profileImage}) async {
    try {
      final response = await _apiService.patch(
        ApiEndpoints.updateProfile,
        data: {
          if (fullName != null) 'fullName': fullName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (profileImage != null) 'profileImage': profileImage,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (_) {
      rethrow;
    }
  }
}
