import 'package:json_annotation/json_annotation.dart';

part 'register_request_model.g.dart';

@JsonSerializable()
class RegisterRequestModel {
  final String fullName;
  final String email;
  final String countryCode;
  final String mobileNumber;
  final String password;
  final String confirmPassword;
  final String role;

  RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}
