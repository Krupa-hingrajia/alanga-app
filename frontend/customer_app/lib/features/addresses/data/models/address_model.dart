class AddressModel {
  final String id;
  final String customerId;
  final String fullName;
  final String mobileNumber;
  final String? alternateMobile;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String addressType;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressModel({
    required this.id,
    required this.customerId,
    required this.fullName,
    required this.mobileNumber,
    this.alternateMobile,
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.addressType,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      if (landmark != null && landmark!.isNotEmpty) 'Landmark: $landmark',
      '$city, $state - $postalCode',
      country,
    ];
    return parts.join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      alternateMobile: json['alternateMobile'] as String?,
      addressLine1: json['addressLine1'] as String? ?? '',
      addressLine2: json['addressLine2'] as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? 'India',
      postalCode: json['postalCode'] as String? ?? '',
      addressType: json['addressType'] as String? ?? 'HOME',
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      if (alternateMobile != null && alternateMobile!.isNotEmpty)
        'alternateMobile': alternateMobile,
      'addressLine1': addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty)
        'addressLine2': addressLine2,
      if (landmark != null && landmark!.isNotEmpty) 'landmark': landmark,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'addressType': addressType,
      'isDefault': isDefault,
    };
  }
}
