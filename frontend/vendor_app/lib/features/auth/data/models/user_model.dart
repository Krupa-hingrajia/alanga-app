import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String countryCode;
  final String mobileNumber;
  final String role;
  final String status;
  final String? businessName;
  final String? businessType;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstNumber;
  final String? panNumber;

  UserModel({
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
      status: json['status'] as String? ?? 'PENDING',
      businessName: json['businessName'] as String?,
      businessType: json['businessType'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      gstNumber: json['gstNumber'] as String?,
      panNumber: json['panNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'countryCode': countryCode,
        'mobileNumber': mobileNumber,
        'role': role,
        'status': status,
        'businessName': businessName,
        'businessType': businessType,
        'city': city,
        'state': state,
        'pincode': pincode,
        'gstNumber': gstNumber,
        'panNumber': panNumber,
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

    UserStatus userStatus;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        userStatus = UserStatus.active;
        break;
      case 'REJECTED':
        userStatus = UserStatus.rejected;
        break;
      case 'SUSPENDED':
        userStatus = UserStatus.suspended;
        break;
      case 'PENDING':
      default:
        userStatus = UserStatus.pending;
        break;
    }

    return UserEntity(
      id: id,
      fullName: fullName,
      email: email,
      countryCode: countryCode,
      mobileNumber: mobileNumber,
      role: userRole,
      status: userStatus,
      businessName: businessName,
      businessType: businessType,
      city: city,
      state: state,
      pincode: pincode,
      gstNumber: gstNumber,
      panNumber: panNumber,
    );
  }
}
