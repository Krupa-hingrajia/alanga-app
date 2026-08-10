// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequestModel _$RegisterRequestModelFromJson(
  Map<String, dynamic> json,
) => RegisterRequestModel(
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  countryCode: json['countryCode'] as String,
  mobileNumber: json['mobileNumber'] as String,
  password: json['password'] as String,
  confirmPassword: json['confirmPassword'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$RegisterRequestModelToJson(
  RegisterRequestModel instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'email': instance.email,
  'countryCode': instance.countryCode,
  'mobileNumber': instance.mobileNumber,
  'password': instance.password,
  'confirmPassword': instance.confirmPassword,
  'role': instance.role,
};
