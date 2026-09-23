import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordRequestOtpEvent extends ForgotPasswordEvent {
  final String identifier;

  const ForgotPasswordRequestOtpEvent({required this.identifier});

  @override
  List<Object?> get props => [identifier];
}

class ForgotPasswordVerifyOtpEvent extends ForgotPasswordEvent {
  final String identifier;
  final String otp;

  const ForgotPasswordVerifyOtpEvent({
    required this.identifier,
    required this.otp,
  });

  @override
  List<Object?> get props => [identifier, otp];
}

class ForgotPasswordResetPasswordEvent extends ForgotPasswordEvent {
  final String identifier;
  final String otp;
  final String newPassword;

  const ForgotPasswordResetPasswordEvent({
    required this.identifier,
    required this.otp,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [identifier, otp, newPassword];
}

class ForgotPasswordResetFlowEvent extends ForgotPasswordEvent {
  const ForgotPasswordResetFlowEvent();
}
