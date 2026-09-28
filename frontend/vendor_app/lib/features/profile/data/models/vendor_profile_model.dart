class VendorProfileModel {
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String status;
  final String kycStatus;
  
  // 1. Business Identity
  final String storeName;
  final String? legalName;
  final String businessType;
  final String? businessDescription;

  // 2. Tax & Legal (KYC)
  final String? panNumber;
  final String? panCardUrl;
  final String? gstNumber;
  final String? gstCertificateUrl;

  // 3. Pickup & Warehouse Address
  final String? pickupAddressLine1;
  final String? pickupAddressLine2;
  final String? pickupCity;
  final String? pickupState;
  final String? pickupPincode;
  final String? pickupContactPhone;

  // 4. Bank Account Details (Payouts)
  final String? bankAccountHolderName;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? bankName;
  final String bankAccountType;
  final String? cancelledChequeUrl;

  // 5. Digital Signature
  final String? digitalSignatureUrl;

  VendorProfileModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.status,
    required this.kycStatus,
    required this.storeName,
    this.legalName,
    required this.businessType,
    this.businessDescription,
    this.panNumber,
    this.panCardUrl,
    this.gstNumber,
    this.gstCertificateUrl,
    this.pickupAddressLine1,
    this.pickupAddressLine2,
    this.pickupCity,
    this.pickupState,
    this.pickupPincode,
    this.pickupContactPhone,
    this.bankAccountHolderName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankName,
    this.bankAccountType = 'CURRENT',
    this.cancelledChequeUrl,
    this.digitalSignatureUrl,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    final profile = (json['profile'] as Map<String, dynamic>?) ?? {};
    return VendorProfileModel(
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      kycStatus: json['kycStatus'] as String? ?? 'NOT_SUBMITTED',
      storeName: profile['storeName'] as String? ?? (json['fullName'] as String? ?? 'Store'),
      legalName: profile['legalName'] as String?,
      businessType: profile['businessType'] as String? ?? 'Individual Seller',
      businessDescription: profile['businessDescription'] as String?,
      panNumber: profile['panNumber'] as String?,
      panCardUrl: profile['panCardUrl'] as String?,
      gstNumber: profile['gstNumber'] as String?,
      gstCertificateUrl: profile['gstCertificateUrl'] as String?,
      pickupAddressLine1: profile['pickupAddressLine1'] as String?,
      pickupAddressLine2: profile['pickupAddressLine2'] as String?,
      pickupCity: profile['pickupCity'] as String?,
      pickupState: profile['pickupState'] as String?,
      pickupPincode: profile['pickupPincode'] as String?,
      pickupContactPhone: profile['pickupContactPhone'] as String? ?? json['phoneNumber'] as String?,
      bankAccountHolderName: profile['bankAccountHolderName'] as String?,
      bankAccountNumber: profile['bankAccountNumber'] as String?,
      bankIfscCode: profile['bankIfscCode'] as String?,
      bankName: profile['bankName'] as String?,
      bankAccountType: profile['bankAccountType'] as String? ?? 'CURRENT',
      cancelledChequeUrl: profile['cancelledChequeUrl'] as String?,
      digitalSignatureUrl: profile['digitalSignatureUrl'] as String?,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'storeName': storeName,
      'legalName': legalName,
      'businessType': businessType,
      'businessDescription': businessDescription,
      'panNumber': panNumber,
      'panCardUrl': panCardUrl,
      'gstNumber': gstNumber,
      'gstCertificateUrl': gstCertificateUrl,
      'pickupAddressLine1': pickupAddressLine1,
      'pickupAddressLine2': pickupAddressLine2,
      'pickupCity': pickupCity,
      'pickupState': pickupState,
      'pickupPincode': pickupPincode,
      'pickupContactPhone': pickupContactPhone,
      'bankAccountHolderName': bankAccountHolderName,
      'bankAccountNumber': bankAccountNumber,
      'bankIfscCode': bankIfscCode,
      'bankName': bankName,
      'bankAccountType': bankAccountType,
      'cancelledChequeUrl': cancelledChequeUrl,
      'digitalSignatureUrl': digitalSignatureUrl,
    };
  }
}
