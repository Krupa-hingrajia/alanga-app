import 'package:equatable/equatable.dart';

enum ForgotPasswordStep { email, otp, newPassword, done }

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {
  final ForgotPasswordStep step;

  const ForgotPasswordLoading({required this.step});

  @override
  List<Object?> get props => [step];
}

class ForgotPasswordOtpSent extends ForgotPasswordState {
  final String identifier;
  final String? devOtp;

  const ForgotPasswordOtpSent({
    required this.identifier,
    this.devOtp,
  });

  @override
  List<Object?> get props => [identifier, devOtp];
}

class ForgotPasswordOtpVerified extends ForgotPasswordState {
  final String identifier;
  final String otp;

  const ForgotPasswordOtpVerified({
    required this.identifier,
    required this.otp,
  });

  @override
  List<Object?> get props => [identifier, otp];
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;

  const ForgotPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String errorMessage;
  final ForgotPasswordStep step;
  final String? identifier;
  final String? otp;

  const ForgotPasswordFailure({
    required this.errorMessage,
    required this.step,
    this.identifier,
    this.otp,
  });

  @override
  List<Object?> get props => [errorMessage, step, identifier, otp];
}
