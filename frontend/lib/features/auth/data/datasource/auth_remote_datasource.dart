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
}
