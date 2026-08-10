import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmittedEvent extends RegisterEvent {
  final String fullName;
  final String email;
  final String countryCode;
  final String mobileNumber;
  final String password;
  final String confirmPassword;
  final UserRole role;

  const RegisterSubmittedEvent({
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        countryCode,
        mobileNumber,
        password,
        confirmPassword,
        role,
      ];
}
