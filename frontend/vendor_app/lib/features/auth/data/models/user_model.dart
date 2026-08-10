import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String countryCode;
  final String mobileNumber;
  final String role;
  @JsonKey(defaultValue: 'PENDING')
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

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

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
