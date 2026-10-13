import 'package:equatable/equatable.dart';

abstract class PhoneAuthEvent extends Equatable {
  const PhoneAuthEvent();

  @override
  List<Object?> get props => [];
}

class SendPhoneOtpEvent extends PhoneAuthEvent {
  final String phoneNumber;

  const SendPhoneOtpEvent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyPhoneOtpEvent extends PhoneAuthEvent {
  final String phoneNumber;
  final String otp;
  final String? fullName;

  const VerifyPhoneOtpEvent({
    required this.phoneNumber,
    required this.otp,
    this.fullName,
  });

  @override
  List<Object?> get props => [phoneNumber, otp, fullName];
}

class ResetPhoneAuthStateEvent extends PhoneAuthEvent {
  const ResetPhoneAuthStateEvent();
}
