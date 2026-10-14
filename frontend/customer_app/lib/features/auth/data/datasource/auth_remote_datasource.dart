import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/phone_auth_request_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<LoginResponseModel> phoneAuth(PhoneAuthRequestModel request);
  Future<RegisterResponseModel> register(RegisterRequestModel request);
  Future<UserModel> getCurrentUser();
  Future<String?> forgotPassword(String identifier);
  Future<void> verifyOtp(String identifier, String otp);
  Future<void> resetPassword(String identifier, String otp, String newPassword);
  Future<String?> sendPhoneOtp(String phoneNumber);
  Future<LoginResponseModel> verifyPhoneOtp(String phoneNumber, String otp, {String? fullName});
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
  Future<LoginResponseModel> phoneAuth(PhoneAuthRequestModel request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.phoneAuth,
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
  Future<String?> sendPhoneOtp(String phoneNumber) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.sendPhoneOtp,
        data: {'phoneNumber': phoneNumber},
      );
      final data = response.data as Map<String, dynamic>?;
      return data?['devOtp'] as String?;
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<LoginResponseModel> verifyPhoneOtp(String phoneNumber, String otp, {String? fullName}) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.verifyPhoneOtp,
        data: {
          'phoneNumber': phoneNumber,
          'otp': otp,
          if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
          'role': 'CUSTOMER',
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return LoginResponseModel.fromJson(data);
    } on DioException catch (_) {
      rethrow;
    }
  }
}
