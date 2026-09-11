import '../../../addresses/data/models/address_model.dart';

class OrderItemModel {
  final String id;
  final String orderId;
  final String vendorId;
  final String productId;
  final String productVariantId;
  final String productNameSnapshot;
  final String? variantNameSnapshot;
  final Map<String, dynamic>? variantAttributesSnapshot;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double shippingCharge;
  final double totalPrice;
  final String status;
  final String? imageUrl;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.vendorId,
    required this.productId,
    required this.productVariantId,
    required this.productNameSnapshot,
    this.variantNameSnapshot,
    this.variantAttributesSnapshot,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.shippingCharge,
    required this.totalPrice,
    required this.status,
    this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final productMap = json['product'] as Map<String, dynamic>? ?? {};
    final variantMap = json['productVariant'] as Map<String, dynamic>? ?? {};
    final imagesList = variantMap['images'] as List? ?? productMap['productImages'] as List? ?? [];

    String? img;
    if (imagesList.isNotEmpty && imagesList[0]['imageUrl'] != null) {
      img = imagesList[0]['imageUrl'].toString();
    } else if (productMap['primaryImageUrl'] != null) {
      img = productMap['primaryImageUrl'].toString();
    } else if (productMap['image'] != null) {
      img = productMap['image'].toString();
    }

    return OrderItemModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productVariantId: json['productVariantId'] as String? ?? '',
      productNameSnapshot: json['productNameSnapshot'] as String? ?? productMap['name'] as String? ?? 'Product',
      variantNameSnapshot: json['variantNameSnapshot'] as String? ?? variantMap['variantName'] as String?,
      variantAttributesSnapshot: json['variantAttributesSnapshot'] is Map
          ? Map<String, dynamic>.from(json['variantAttributesSnapshot'] as Map)
          : null,
      sku: json['sku'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      shippingCharge: (json['shippingCharge'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'PENDING',
      imageUrl: img,
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String? addressId;
  final Map<String, dynamic>? shippingAddressSnapshot;
  final AddressModel? address;
  final double subtotal;
  final double shippingCharge;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItemModel> orderItems;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    this.addressId,
    this.shippingAddressSnapshot,
    this.address,
    required this.subtotal,
    required this.shippingCharge,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['orderItems'] as List? ?? [];
    final itemsList = rawItems
        .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      addressId: json['addressId'] as String?,
      shippingAddressSnapshot: json['shippingAddressSnapshot'] is Map
          ? Map<String, dynamic>.from(json['shippingAddressSnapshot'] as Map)
          : null,
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingCharge: (json['shippingCharge'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? 'COD',
      paymentStatus: json['paymentStatus'] as String? ?? 'PENDING',
      status: json['status'] as String? ?? 'PENDING',
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      orderItems: itemsList,
    );
  }
}
