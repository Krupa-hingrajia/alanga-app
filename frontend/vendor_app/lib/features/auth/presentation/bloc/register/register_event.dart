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
  final String? businessName;
  final String? businessType;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstNumber;
  final String? panNumber;

  const RegisterSubmittedEvent({
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.businessName,
    this.businessType,
    this.city,
    this.state,
    this.pincode,
    this.gstNumber,
    this.panNumber,
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
        businessName,
        businessType,
        city,
        state,
        pincode,
        gstNumber,
        panNumber,
      ];
}
