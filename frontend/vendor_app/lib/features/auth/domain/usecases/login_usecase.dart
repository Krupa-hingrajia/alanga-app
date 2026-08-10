import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String identifier;
  final String password;

  LoginParams({required this.identifier, required this.password});
}

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<UserEntity> call(LoginParams params) async {
    return await _repository.login(
      identifier: params.identifier,
      password: params.password,
    );
  }
}
