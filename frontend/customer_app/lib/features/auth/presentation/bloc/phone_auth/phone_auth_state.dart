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
  final String phoneNumber;
  final String? devOtp;

  const PhoneAuthCodeSentState({
    required this.phoneNumber,
    this.devOtp,
  });

  @override
  List<Object?> get props => [phoneNumber, devOtp];
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
