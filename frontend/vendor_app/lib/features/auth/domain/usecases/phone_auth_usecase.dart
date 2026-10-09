import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class PhoneAuthUseCase {
  final AuthRepository _repository;

  PhoneAuthUseCase(this._repository);

  Future<UserEntity> call({
    required String phoneNumber,
    String? fullName,
    String? businessName,
    String? email,
    String? firebaseUid,
  }) async {
    return await _repository.phoneAuth(
      phoneNumber: phoneNumber,
      fullName: fullName,
      businessName: businessName,
      email: email,
      firebaseUid: firebaseUid,
    );
  }
}
