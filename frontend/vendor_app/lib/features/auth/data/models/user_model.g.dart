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
  status: json['status'] as String? ?? 'PENDING',
  businessName: json['businessName'] as String?,
  businessType: json['businessType'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  pincode: json['pincode'] as String?,
  gstNumber: json['gstNumber'] as String?,
  panNumber: json['panNumber'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'countryCode': instance.countryCode,
  'mobileNumber': instance.mobileNumber,
  'role': instance.role,
  'status': instance.status,
  'businessName': instance.businessName,
  'businessType': instance.businessType,
  'city': instance.city,
  'state': instance.state,
  'pincode': instance.pincode,
  'gstNumber': instance.gstNumber,
  'panNumber': instance.panNumber,
};
