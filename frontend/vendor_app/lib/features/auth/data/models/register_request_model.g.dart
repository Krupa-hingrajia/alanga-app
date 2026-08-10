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
  businessName: json['businessName'] as String?,
  businessType: json['businessType'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  pincode: json['pincode'] as String?,
  gstNumber: json['gstNumber'] as String?,
  panNumber: json['panNumber'] as String?,
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
  'businessName': instance.businessName,
  'businessType': instance.businessType,
  'city': instance.city,
  'state': instance.state,
  'pincode': instance.pincode,
  'gstNumber': instance.gstNumber,
  'panNumber': instance.panNumber,
};
