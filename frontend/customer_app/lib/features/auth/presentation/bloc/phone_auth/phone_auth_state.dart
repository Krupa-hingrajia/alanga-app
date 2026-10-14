import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

abstract class PhoneAuthState extends Equatable {
  const PhoneAuthState();

  @override
  List<Object?> get props => [];
}

class PhoneAuthInitial extends PhoneAuthState {
  const PhoneAuthInitial();
}

class PhoneAuthLoading extends PhoneAuthState {
  final String? message;
  const PhoneAuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class PhoneAuthCodeSentState extends PhoneAuthState {
  final String verificationId;
  final String phoneNumber;
  final int? resendToken;

  const PhoneAuthCodeSentState({
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });

  @override
  List<Object?> get props => [verificationId, phoneNumber, resendToken];
}

class PhoneAuthSuccessState extends PhoneAuthState {
  final UserEntity user;
  const PhoneAuthSuccessState({required this.user});

  @override
  List<Object?> get props => [user];
}

class PhoneAuthFailureState extends PhoneAuthState {
  final String errorMessage;
  const PhoneAuthFailureState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
