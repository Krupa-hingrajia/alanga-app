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
