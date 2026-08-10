// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  countryCode: json['countryCode'] as String,
  mobileNumber: json['mobileNumber'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'countryCode': instance.countryCode,
  'mobileNumber': instance.mobileNumber,
  'role': instance.role,
};
