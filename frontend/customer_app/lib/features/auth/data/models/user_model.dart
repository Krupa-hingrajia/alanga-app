import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String countryCode;
  final String mobileNumber;
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final phone = json['phoneNumber'] as String? ?? json['mobileNumber'] as String? ?? '';
    final code = json['countryCode'] as String? ?? '+91';

    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      countryCode: code,
      mobileNumber: phone,
      role: json['role'] as String? ?? 'CUSTOMER',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'countryCode': countryCode,
        'mobileNumber': mobileNumber,
        'role': role,
      };

  UserEntity toEntity() {
    UserRole userRole;
    switch (role.toUpperCase()) {
      case 'ADMIN':
        userRole = UserRole.admin;
        break;
      case 'VENDOR':
        userRole = UserRole.vendor;
        break;
      case 'CUSTOMER':
      default:
        userRole = UserRole.customer;
        break;
    }

    return UserEntity(
      id: id,
      fullName: fullName,
      email: email,
      countryCode: countryCode,
      mobileNumber: mobileNumber,
      role: userRole,
    );
  }
}
