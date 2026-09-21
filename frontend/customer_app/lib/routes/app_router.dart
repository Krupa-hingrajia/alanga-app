import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../core/widgets/main_navigation_screen.dart';

// Categories imports
import '../features/categories/data/models/category_model.dart';
import '../features/categories/presentation/screens/category_products_screen.dart';

// Products imports
import '../features/products/data/models/product_model.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/products/presentation/screens/product_detail_screen.dart';

import '../core/dependency_injection/injection.dart';
import '../core/storage/secure_storage_service.dart';

// Checkout & Orders imports
import '../features/checkout/data/models/order_model.dart';
import '../features/checkout/presentation/screens/checkout_screen.dart';
import '../features/checkout/presentation/screens/order_success_screen.dart';
import '../features/checkout/presentation/screens/order_list_screen.dart';
import '../features/checkout/presentation/screens/order_detail_screen.dart';
import '../features/checkout/presentation/screens/order_tracking_screen.dart';

// Addresses imports
import '../features/addresses/presentation/screens/address_list_screen.dart';

// Reviews imports
import '../features/reviews/data/models/review_model.dart';
import '../features/reviews/presentation/screens/write_review_screen.dart';
import '../features/reviews/presentation/screens/my_reviews_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final storage = sl<SecureStorageService>();
      final token = await storage.getAccessToken();

      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';

      if (token == null) {
        if (!isLoggingIn && !isRegistering) {
          return '/login';
        }
      } else {
        if (isLoggingIn || isRegistering) {
          return '/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const MainNavigationScreen(initialIndex: 2),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const MainNavigationScreen(initialIndex: 3),
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressListScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-success',
        builder: (context, state) => OrderSuccessScreen(
          order: state.extra as OrderModel,
        ),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) => OrderDetailScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id/track',
        builder: (context, state) => OrderTrackingScreen(
          orderId: state.pathParameters['id']!,
          order: state.extra as OrderModel?,
        ),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => ProductListScreen(
          initialQuery: state.extra as String?,
        ),
      ),
      GoRoute(
        path: '/products/details',
        builder: (context, state) => ProductDetailScreen(
          product: state.extra as ProductModel,
        ),
      ),
      GoRoute(
        path: '/products/detail',
        builder: (context, state) => ProductDetailScreen(
          product: state.extra as ProductModel,
        ),
      ),
      GoRoute(
        path: '/categories/products',
        builder: (context, state) => CategoryProductsScreen(
          category: state.extra as CategoryModel,
        ),
      ),
      GoRoute(
        path: '/reviews/write',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return WriteReviewScreen(
            productId: extra['productId'] as String,
            productName: extra['productName'] as String,
            productImage: extra['productImage'] as String?,
            orderId: extra['orderId'] as String,
            variantId: extra['variantId'] as String?,
            variantName: extra['variantName'] as String?,
            existingReview: extra['existingReview'] as ReviewModel?,
          );
        },
      ),
      GoRoute(
        path: '/reviews/my-reviews',
        builder: (context, state) => const MyReviewsScreen(),
      ),
    ],
  );
}
