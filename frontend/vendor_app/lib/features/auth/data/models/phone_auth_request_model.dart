class PhoneAuthRequestModel {
  final String phoneNumber;
  final String? fullName;
  final String? businessName;
  final String? email;
  final String role;
  final String? firebaseUid;

  PhoneAuthRequestModel({
    required this.phoneNumber,
    this.fullName,
    this.businessName,
    this.email,
    this.role = 'VENDOR',
    this.firebaseUid,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'phoneNumber': phoneNumber,
      'role': role,
    };
    if (fullName != null && fullName!.isNotEmpty) map['fullName'] = fullName;
    if (businessName != null && businessName!.isNotEmpty) map['businessName'] = businessName;
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (firebaseUid != null && firebaseUid!.isNotEmpty) map['firebaseUid'] = firebaseUid;
    return map;
  }
}
