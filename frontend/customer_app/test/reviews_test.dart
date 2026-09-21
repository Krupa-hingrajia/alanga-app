import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/features/reviews/data/models/review_model.dart';

void main() {
  group('ReviewModel and RatingSummaryModel Tests', () {
    test('ReviewModel.fromJson parses complete review data correctly', () {
      final json = {
        'id': 'rev-1',
        'productId': 'prod-101',
        'productVariantId': 'var-1',
        'customerId': 'cust-1',
        'orderId': 'ord-1',
        'rating': 5,
        'title': 'Great Product',
        'description': 'Loved the material, comfortable fit and quick delivery.',
        'images': ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
        'isVerifiedPurchase': true,
        'customer': {
          'fullName': 'Rahul Sharma',
          'profileImage': 'https://example.com/avatar.jpg',
        },
        'product': {
          'name': 'Premium Cotton Shirt',
          'image': 'https://example.com/shirt.jpg',
        },
        'vendorReply': 'Thank you Rahul for the wonderful review!',
        'createdAt': '2026-09-20T10:00:00Z',
        'updatedAt': '2026-09-20T10:00:00Z',
      };

      final review = ReviewModel.fromJson(json);

      expect(review.id, 'rev-1');
      expect(review.productId, 'prod-101');
      expect(review.customerName, 'Rahul Sharma');
      expect(review.rating, 5);
      expect(review.title, 'Great Product');
      expect(review.description, 'Loved the material, comfortable fit and quick delivery.');
      expect(review.images.length, 2);
      expect(review.vendorReply, 'Thank you Rahul for the wonderful review!');
      expect(review.isVerifiedPurchase, true);
    });

    test('RatingSummaryModel.fromJson parses star counts and breakdown correctly', () {
      final json = {
        'productId': 'prod-101',
        'averageRating': 4.6,
        'totalReviews': 15,
        'fiveStarCount': 10,
        'fourStarCount': 3,
        'threeStarCount': 1,
        'twoStarCount': 1,
        'oneStarCount': 0,
        'ratingDistribution': {
          '1': 0,
          '2': 1,
          '3': 1,
          '4': 3,
          '5': 10,
        },
      };

      final summary = RatingSummaryModel.fromJson(json);

      expect(summary.productId, 'prod-101');
      expect(summary.averageRating, 4.6);
      expect(summary.totalReviews, 15);
      expect(summary.fiveStarCount, 10);
      expect(summary.fourStarCount, 3);
      expect(summary.threeStarCount, 1);
      expect(summary.twoStarCount, 1);
      expect(summary.oneStarCount, 0);
    });
  });
}
