import 'package:equatable/equatable.dart';

enum UserRole { customer, vendor, admin }
enum UserStatus { pending, active, rejected, suspended }

class UserEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String countryCode;
  final String mobileNumber;
  final UserRole role;
  final UserStatus status;
  final String? businessName;
  final String? businessType;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstNumber;
  final String? panNumber;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.role,
    required this.status,
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
        id,
        fullName,
        email,
        countryCode,
        mobileNumber,
        role,
        status,
        businessName,
        businessType,
        city,
        state,
        pincode,
        gstNumber,
        panNumber,
      ];
}
