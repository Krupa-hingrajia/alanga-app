import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  @JsonKey(name: 'fullName')
  final String fullName;
  final String email;
  @JsonKey(name: 'countryCode')
  final String countryCode;
  @JsonKey(name: 'mobileNumber')
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
