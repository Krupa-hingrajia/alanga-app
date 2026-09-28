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

  // 1. Business Identity
  final String? businessName;
  final String? legalName;
  final String? businessType;

  // 2. Tax & Legal (KYC)
  final String? panNumber;
  final String? gstNumber;

  // 3. Pickup & Warehouse Address
  final String? pickupAddressLine1;
  final String? pickupAddressLine2;
  final String? city;
  final String? state;
  final String? pincode;
  final String? pickupContactPhone;

  // 4. Bank Account Details (Payouts)
  final String? bankAccountHolderName;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? bankName;
  final String? bankAccountType;

  // 5. Digital Signature
  final String? digitalSignatureUrl;

  const RegisterSubmittedEvent({
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.businessName,
    this.legalName,
    this.businessType,
    this.panNumber,
    this.gstNumber,
    this.pickupAddressLine1,
    this.pickupAddressLine2,
    this.city,
    this.state,
    this.pincode,
    this.pickupContactPhone,
    this.bankAccountHolderName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankName,
    this.bankAccountType,
    this.digitalSignatureUrl,
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
        legalName,
        businessType,
        panNumber,
        gstNumber,
        pickupAddressLine1,
        pickupAddressLine2,
        city,
        state,
        pincode,
        pickupContactPhone,
        bankAccountHolderName,
        bankAccountNumber,
        bankIfscCode,
        bankName,
        bankAccountType,
        digitalSignatureUrl,
      ];
}
