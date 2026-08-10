import 'package:equatable/equatable.dart';

enum UserRole { customer, vendor, admin }

class UserEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String countryCode;
  final String mobileNumber;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.role,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        countryCode,
        mobileNumber,
        role,
      ];
}
