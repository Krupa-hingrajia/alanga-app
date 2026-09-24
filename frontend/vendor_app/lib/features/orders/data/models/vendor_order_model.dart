class VendorCustomerModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;

  const VendorCustomerModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });

  factory VendorCustomerModel.fromJson(Map<String, dynamic> json) {
    return VendorCustomerModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Customer',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
  };
}

class VendorAddressModel {
  final String id;
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

  const VendorAddressModel({
    required this.id,
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
  });

  factory VendorAddressModel.fromJson(Map<String, dynamic> json) {
    return VendorAddressModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      alternateMobile: json['alternateMobile']?.toString(),
      addressLine1: json['addressLine1']?.toString() ?? '',
      addressLine2: json['addressLine2']?.toString(),
      landmark: json['landmark']?.toString(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? 'India',
      postalCode: json['postalCode']?.toString() ?? '',
      addressType: json['addressType']?.toString() ?? 'HOME',
    );
  }

  String get formattedAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      if (landmark != null && landmark!.isNotEmpty) 'Near $landmark',
      '$city, $state - $postalCode',
      country,
    ];
    return parts.where((p) => p != null && p.isNotEmpty).join(', ');
  }
}

class VendorOrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final String? productVariantId;
  final String vendorId;
  final String productName;
  final String? variantName;
  final String? sku;
  final int quantity;
  final double unitPrice;
  final double shippingCharge;
  final double totalPrice;
  final String status;
  final String? productImage;

  const VendorOrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    this.productVariantId,
    required this.vendorId,
    required this.productName,
    this.variantName,
    this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.shippingCharge,
    required this.totalPrice,
    required this.status,
    this.productImage,
  });

  factory VendorOrderItemModel.fromJson(Map<String, dynamic> json) {
    String? img;
    final productMap = json['product'] is Map
        ? Map<String, dynamic>.from(json['product'] as Map)
        : null;

    // 1. Variant image takes highest priority when available
    final variantMap = json['productVariant'] is Map
        ? Map<String, dynamic>.from(json['productVariant'] as Map)
        : null;
    if (variantMap != null) {
      if (variantMap['image'] != null && variantMap['image'].toString().trim().isNotEmpty) {
        img = variantMap['image'].toString().trim();
      } else if (variantMap['images'] is List && (variantMap['images'] as List).isNotEmpty) {
        final vList = variantMap['images'] as List;
        final firstItem = vList.first;
        if (firstItem is Map) {
          img = (firstItem['imageUrl'] ?? firstItem['image'] ?? firstItem['url'])?.toString().trim();
        } else if (firstItem is String && firstItem.trim().isNotEmpty) {
          img = firstItem.trim();
        }
      } else if (variantMap['productImages'] is List && (variantMap['productImages'] as List).isNotEmpty) {
        final vList = variantMap['productImages'] as List;
        final firstItem = vList.first;
        if (firstItem is Map) {
          img = (firstItem['imageUrl'] ?? firstItem['image'] ?? firstItem['url'])?.toString().trim();
        } else if (firstItem is String && firstItem.trim().isNotEmpty) {
          img = firstItem.trim();
        }
      }
    }

    // 2. Fall back to product image if variant has no specific image
    if (img == null || img.isEmpty) {
      if (productMap != null) {
        if (productMap['image'] != null && productMap['image'].toString().trim().isNotEmpty) {
          img = productMap['image'].toString().trim();
        } else if (productMap['productImages'] is List &&
            (productMap['productImages'] as List).isNotEmpty) {
          final list = productMap['productImages'] as List;
          final thumb = list.firstWhere(
            (element) => element is Map && (element['isPrimary'] == true || element['isThumbnail'] == true),
            orElse: () => list.first,
          );
          if (thumb is Map) {
            img = (thumb['imageUrl'] ?? thumb['image'] ?? thumb['url'])?.toString().trim();
          } else if (thumb is String && thumb.trim().isNotEmpty) {
            img = thumb.trim();
          }
        } else if (productMap['images'] is List && (productMap['images'] as List).isNotEmpty) {
          final list = productMap['images'] as List;
          final thumb = list.firstWhere(
            (element) => element is Map && (element['isPrimary'] == true || element['isThumbnail'] == true),
            orElse: () => list.first,
          );
          if (thumb is Map) {
            img = (thumb['imageUrl'] ?? thumb['image'] ?? thumb['url'])?.toString().trim();
          } else if (thumb is String && thumb.trim().isNotEmpty) {
            img = thumb.trim();
          }
        }
      }
    }

    final resolvedVendorId = (json['vendorId']?.toString().isNotEmpty == true)
        ? json['vendorId'].toString()
        : (productMap != null ? productMap['vendorId']?.toString() ?? '' : '');

    return VendorOrderItemModel(
      id: json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productVariantId: json['productVariantId']?.toString(),
      vendorId: resolvedVendorId,
      productName: json['productNameSnapshot']?.toString() ??
          (productMap != null ? productMap['name']?.toString() ?? 'Product' : 'Product'),
      variantName: json['variantNameSnapshot']?.toString() ??
          (variantMap != null ? variantMap['variantName']?.toString() : null),
      sku: json['sku']?.toString() ??
          (variantMap != null ? variantMap['sku']?.toString() : null),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      shippingCharge: (json['shippingCharge'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString().toUpperCase() ?? 'PENDING',
      productImage: img,
    );
  }
}

class VendorOrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String? shippingAddressId;
  final double subtotal;
  final double taxAmount;
  final double shippingTotal;
  final double grandTotal;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String? cancelReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final VendorCustomerModel? customer;
  final VendorAddressModel? address;
  final List<VendorOrderItemModel> orderItems;

  const VendorOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    this.shippingAddressId,
    required this.subtotal,
    required this.taxAmount,
    required this.shippingTotal,
    required this.grandTotal,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    this.address,
    required this.orderItems,
  });

  factory VendorOrderModel.fromJson(Map<String, dynamic> json) {
    // Address may be in json['address'] or json['shippingAddressSnapshot']
    VendorAddressModel? addressModel;
    if (json['address'] is Map) {
      addressModel = VendorAddressModel.fromJson(Map<String, dynamic>.from(json['address'] as Map));
    } else if (json['shippingAddressSnapshot'] is Map) {
      addressModel = VendorAddressModel.fromJson(Map<String, dynamic>.from(json['shippingAddressSnapshot'] as Map));
    }

    VendorCustomerModel? customerModel;
    if (json['customer'] is Map) {
      customerModel = VendorCustomerModel.fromJson(Map<String, dynamic>.from(json['customer'] as Map));
    }

    List<VendorOrderItemModel> items = [];
    if (json['orderItems'] is List) {
      items = (json['orderItems'] as List)
          .whereType<Map>()
          .map((e) => VendorOrderItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final sTotal = ((json['shippingTotal'] ?? json['shippingCharge']) as num?)?.toDouble() ?? 0.0;
    final gTotal = ((json['grandTotal'] ?? json['totalAmount']) as num?)?.toDouble() ?? 0.0;

    // Resolve status: if all items for this vendor share the same status, use it
    String resolvedStatus = json['status']?.toString().toUpperCase() ?? 'PENDING';
    if (items.isNotEmpty) {
      final itemStatuses = items.map((e) => e.status.toUpperCase()).toSet();
      if (itemStatuses.length == 1) {
        resolvedStatus = itemStatuses.first;
      }
    }

    return VendorOrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      shippingAddressId: json['shippingAddressId']?.toString(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      shippingTotal: sTotal,
      grandTotal: gTotal,
      paymentMethod: json['paymentMethod']?.toString() ?? 'COD',
      paymentStatus: json['paymentStatus']?.toString() ?? 'PENDING',
      status: resolvedStatus,
      cancelReason: json['cancelReason']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      customer: customerModel,
      address: addressModel,
      orderItems: items,
    );
  }

  // --- Computed Helpers for Vendor ---

  /// Sum of items belonging to this vendor
  double get vendorItemsTotal {
    return orderItems.fold(0.0, (acc, item) => acc + (item.unitPrice * item.quantity));
  }

  /// Sum of shipping charges for this vendor's items
  double get vendorShippingTotal {
    return orderItems.fold(0.0, (acc, item) => acc + item.shippingCharge);
  }

  /// Vendor portion total
  double get vendorGrandTotal {
    final total = orderItems.fold(0.0, (acc, item) => acc + item.totalPrice);
    return total > 0 ? total : grandTotal;
  }

  /// Total quantity of vendor items
  int get vendorTotalQuantity {
    return orderItems.fold(0, (acc, item) => acc + item.quantity);
  }

  /// First product thumbnail image
  String? get firstProductThumbnail {
    for (final item in orderItems) {
      if (item.productImage != null && item.productImage!.isNotEmpty) {
        return item.productImage;
      }
    }
    return null;
  }

  /// First product name for overview
  String get firstProductName {
    if (orderItems.isEmpty) return 'Order #$orderNumber';
    return orderItems.first.productName;
  }

  /// First product variant name if any
  String? get firstVariantName {
    if (orderItems.isEmpty) return null;
    return orderItems.first.variantName;
  }

  /// Next valid status for vendor progression
  /// PENDING -> CONFIRMED -> PROCESSING -> PACKED -> SHIPPED -> DELIVERED
  String? get nextValidStatus {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'CONFIRMED';
      case 'CONFIRMED':
        return 'PROCESSING';
      case 'PROCESSING':
        return 'PACKED';
      case 'PACKED':
        return 'SHIPPED';
      case 'SHIPPED':
      case 'OUT_FOR_DELIVERY':
        return 'DELIVERED';
      default:
        return null;
    }
  }

  /// Action button label for the next status
  String? get nextStatusActionLabel {
    switch (nextValidStatus) {
      case 'CONFIRMED':
        return 'Confirm Order';
      case 'PROCESSING':
        return 'Mark Processing';
      case 'PACKED':
        return 'Mark Packed';
      case 'SHIPPED':
        return 'Ship Order';
      case 'DELIVERED':
        return 'Mark Delivered';
      default:
        return null;
    }
  }

  /// Whether the vendor can advance the order status
  bool get canAdvanceStatus => nextValidStatus != null;
}
