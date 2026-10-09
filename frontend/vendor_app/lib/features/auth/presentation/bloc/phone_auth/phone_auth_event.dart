import 'package:equatable/equatable.dart';

abstract class PhoneAuthEvent extends Equatable {
  const PhoneAuthEvent();

  @override
  List<Object?> get props => [];
}

class SendOtpEvent extends PhoneAuthEvent {
  final String phoneNumber;
  final int? forceResendingToken;

  const SendOtpEvent({
    required this.phoneNumber,
    this.forceResendingToken,
  });

  @override
  List<Object?> get props => [phoneNumber, forceResendingToken];
}

class VerifyOtpEvent extends PhoneAuthEvent {
  final String verificationId;
  final String smsCode;
  final String phoneNumber;
  final String? fullName;
  final String? businessName;
  final String? email;

  const VerifyOtpEvent({
    required this.verificationId,
    required this.smsCode,
    required this.phoneNumber,
    this.fullName,
    this.businessName,
    this.email,
  });

  @override
  List<Object?> get props => [verificationId, smsCode, phoneNumber, fullName, businessName, email];
}

class DirectPhoneAuthLoginEvent extends PhoneAuthEvent {
  final String phoneNumber;
  final String firebaseUid;
  final String? fullName;
  final String? businessName;
  final String? email;

  const DirectPhoneAuthLoginEvent({
    required this.phoneNumber,
    required this.firebaseUid,
    this.fullName,
    this.businessName,
    this.email,
  });

  @override
  List<Object?> get props => [phoneNumber, firebaseUid, fullName, businessName, email];
}

class ResetPhoneAuthStateEvent extends PhoneAuthEvent {
  const ResetPhoneAuthStateEvent();
}
