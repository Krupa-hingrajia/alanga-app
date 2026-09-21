import 'package:equatable/equatable.dart';

class ReviewReplyModel extends Equatable {
  final String id;
  final String reviewId;
  final String vendorId;
  final String vendorName;
  final String? vendorAvatar;
  final String reply;
  final DateTime createdAt;

  const ReviewReplyModel({
    required this.id,
    required this.reviewId,
    required this.vendorId,
    required this.vendorName,
    this.vendorAvatar,
    required this.reply,
    required this.createdAt,
  });

  factory ReviewReplyModel.fromJson(Map<String, dynamic> json) {
    String name = 'Vendor';
    String? avatar;
    if (json['vendor'] != null && json['vendor'] is Map<String, dynamic>) {
      name = json['vendor']['fullName'] as String? ?? 'Vendor';
      avatar = json['vendor']['profileImage'] as String?;
    }

    return ReviewReplyModel(
      id: json['id'] as String? ?? '',
      reviewId: json['reviewId'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      vendorName: name,
      vendorAvatar: avatar,
      reply: json['reply'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reviewId': reviewId,
        'vendorId': vendorId,
        'vendorName': vendorName,
        'vendorAvatar': vendorAvatar,
        'reply': reply,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, reviewId, vendorId, reply, createdAt];
}

class ReviewModel extends Equatable {
  final String id;
  final String productId;
  final String? productVariantId;
  final String customerId;
  final String orderId;
  final int rating;
  final String? title;
  final String description;
  final List<String> images;
  final bool isVerifiedPurchase;
  final int helpfulVotes;
  final String customerName;
  final String? customerAvatar;
  final String? productName;
  final String? productImage;
  final String? variantName;
  final String? vendorReply;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ReviewReplyModel> replies;

  const ReviewModel({
    required this.id,
    required this.productId,
    this.productVariantId,
    required this.customerId,
    required this.orderId,
    required this.rating,
    this.title,
    required this.description,
    this.images = const [],
    this.isVerifiedPurchase = true,
    this.helpfulVotes = 0,
    required this.customerName,
    this.customerAvatar,
    this.productName,
    this.productImage,
    this.variantName,
    this.vendorReply,
    required this.createdAt,
    required this.updatedAt,
    this.replies = const [],
  });

  String get review => description;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Parse customer
    String custName = 'Customer';
    String? custAvatar;
    if (json['customer'] != null && json['customer'] is Map<String, dynamic>) {
      custName = json['customer']['fullName'] as String? ?? 'Customer';
      custAvatar = json['customer']['profileImage'] as String?;
    }

    // Parse product info if populated
    String? prodName;
    String? prodImg;
    if (json['product'] != null && json['product'] is Map<String, dynamic>) {
      prodName = json['product']['name'] as String?;
      prodImg = json['product']['image'] as String?;
    }

    // Parse variant if populated
    String? vName;
    if (json['productVariant'] != null && json['productVariant'] is Map<String, dynamic>) {
      vName = json['productVariant']['variantName'] as String?;
    }

    // Parse images list
    List<String> imgList = [];
    if (json['images'] is List) {
      imgList = (json['images'] as List).map((e) => e.toString()).toList();
    } else if (json['images'] is String) {
      try {
        final parsed = json['images'] as String;
        if (parsed.startsWith('[')) {
          // It's a JSON string array
          imgList = (parsed
                  .replaceAll('[', '')
                  .replaceAll(']', '')
                  .replaceAll('"', '')
                  .split(','))
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      } catch (_) {}
    }

    // Parse replies
    List<ReviewReplyModel> replyList = [];
    if (json['replies'] is List) {
      replyList = (json['replies'] as List)
          .map((r) => ReviewReplyModel.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    // Parse direct vendorReply or fallback to first reply in replies
    String? vReply = json['vendorReply'] as String? ?? json['vendor_reply'] as String?;
    if (vReply == null && replyList.isNotEmpty) {
      vReply = replyList.first.reply;
    }

    final desc = json['review'] as String? ?? json['description'] as String? ?? '';

    return ReviewModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productVariantId: json['productVariantId'] as String? ?? json['variantId'] as String?,
      customerId: json['customerId'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      rating: json['rating'] is num ? (json['rating'] as num).toInt() : 5,
      title: json['title'] as String?,
      description: desc,
      images: imgList,
      isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? true,
      helpfulVotes: json['helpfulVotes'] is num ? (json['helpfulVotes'] as num).toInt() : 0,
      customerName: custName,
      customerAvatar: custAvatar,
      productName: prodName,
      productImage: prodImg,
      variantName: vName,
      vendorReply: vReply,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      replies: replyList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productVariantId': productVariantId,
        'customerId': customerId,
        'orderId': orderId,
        'rating': rating,
        'title': title,
        'review': description,
        'description': description,
        'images': images,
        'isVerifiedPurchase': isVerifiedPurchase,
        'helpfulVotes': helpfulVotes,
        'customerName': customerName,
        'customerAvatar': customerAvatar,
        'productName': productName,
        'productImage': productImage,
        'variantName': variantName,
        'vendorReply': vendorReply,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'replies': replies.map((r) => r.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        id,
        productId,
        productVariantId,
        customerId,
        orderId,
        rating,
        title,
        description,
        images,
        isVerifiedPurchase,
        customerName,
        vendorReply,
        createdAt,
        replies,
      ];
}

class ProductReviewsResponse extends Equatable {
  final String productId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final List<ReviewModel> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const ProductReviewsResponse({
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory ProductReviewsResponse.fromJson(Map<String, dynamic> json) {
    final distMap = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    if (json['ratingDistribution'] != null && json['ratingDistribution'] is Map) {
      final rawDist = json['ratingDistribution'] as Map;
      rawDist.forEach((key, val) {
        final k = int.tryParse(key.toString());
        final v = int.tryParse(val.toString());
        if (k != null && v != null) {
          distMap[k] = v;
        }
      });
    }

    List<ReviewModel> reviewItems = [];
    if (json['items'] is List) {
      reviewItems = (json['items'] as List)
          .map((i) => ReviewModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return ProductReviewsResponse(
      productId: json['productId'] as String? ?? '',
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : 0.0,
      totalReviews: json['totalReviews'] != null
          ? (json['totalReviews'] as num).toInt()
          : 0,
      ratingDistribution: distMap,
      items: reviewItems,
      page: json['page'] != null ? (json['page'] as num).toInt() : 1,
      limit: json['limit'] != null ? (json['limit'] as num).toInt() : 10,
      total: json['total'] != null ? (json['total'] as num).toInt() : 0,
      totalPages: json['totalPages'] != null ? (json['totalPages'] as num).toInt() : 1,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        averageRating,
        totalReviews,
        ratingDistribution,
        items,
        page,
        limit,
        total,
        totalPages,
      ];
}

class RatingSummaryModel extends Equatable {
  final String productId;
  final double averageRating;
  final int totalReviews;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;
  final Map<int, int> ratingDistribution;

  const RatingSummaryModel({
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
    this.fiveStarCount = 0,
    this.fourStarCount = 0,
    this.threeStarCount = 0,
    this.twoStarCount = 0,
    this.oneStarCount = 0,
    this.ratingDistribution = const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
  });

  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    final distMap = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    if (json['ratingDistribution'] != null && json['ratingDistribution'] is Map) {
      final rawDist = json['ratingDistribution'] as Map;
      rawDist.forEach((key, val) {
        final k = int.tryParse(key.toString());
        final v = int.tryParse(val.toString());
        if (k != null && v != null) {
          distMap[k] = v;
        }
      });
    }

    final total = json['totalReviews'] != null ? (json['totalReviews'] as num).toInt() : 0;
    final five = json['fiveStarCount'] != null
        ? (json['fiveStarCount'] as num).toInt()
        : (distMap[5] ?? 0);
    final four = json['fourStarCount'] != null
        ? (json['fourStarCount'] as num).toInt()
        : (distMap[4] ?? 0);
    final three = json['threeStarCount'] != null
        ? (json['threeStarCount'] as num).toInt()
        : (distMap[3] ?? 0);
    final two = json['twoStarCount'] != null
        ? (json['twoStarCount'] as num).toInt()
        : (distMap[2] ?? 0);
    final one = json['oneStarCount'] != null
        ? (json['oneStarCount'] as num).toInt()
        : (distMap[1] ?? 0);

    return RatingSummaryModel(
      productId: json['productId'] as String? ?? '',
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : 0.0,
      totalReviews: total,
      fiveStarCount: five,
      fourStarCount: four,
      threeStarCount: three,
      twoStarCount: two,
      oneStarCount: one,
      ratingDistribution: distMap,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        averageRating,
        totalReviews,
        fiveStarCount,
        fourStarCount,
        threeStarCount,
        twoStarCount,
        oneStarCount,
        ratingDistribution,
      ];
}
