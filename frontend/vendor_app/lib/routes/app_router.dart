import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/success_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';

// Settings & Profile imports
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/change_password_screen.dart';
import '../features/settings/presentation/screens/legal_content_screen.dart';
import '../features/settings/presentation/screens/support_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';

// Products imports
import '../features/products/data/models/product_model.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/products/presentation/screens/add_edit_product_screen.dart';
import '../features/products/presentation/screens/product_detail_screen.dart';

// Inventory imports
import '../features/inventory/presentation/screens/product_inventory_screen.dart';

// Shipping imports
import '../features/shipping/presentation/screens/product_shipping_screen.dart';

// Orders imports
import '../features/orders/data/models/vendor_order_model.dart';
import '../features/orders/presentation/screens/vendor_order_list_screen.dart';
import '../features/orders/presentation/screens/vendor_order_detail_screen.dart';

import '../core/dependency_injection/injection.dart';
import '../core/storage/secure_storage_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final storage = sl<SecureStorageService>();
      final token = await storage.getAccessToken();
      
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isSuccess = state.matchedLocation == '/success';
      final isForgotPassword = state.matchedLocation == '/forgot-password';

      if (token == null) {
        if (!isLoggingIn && !isRegistering && !isSuccess && !isForgotPassword) {
          return '/login';
        }
      } else {
        if (isLoggingIn || isRegistering || isForgotPassword) {
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
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => const SuccessScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Settings & Profile routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/settings/privacy-policy',
        builder: (context, state) => const LegalContentScreen(type: LegalContentType.privacyPolicy),
      ),
      GoRoute(
        path: '/settings/terms',
        builder: (context, state) => const LegalContentScreen(type: LegalContentType.termsOfService),
      ),
      GoRoute(
        path: '/settings/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),

      // Products routes
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/products/add',
        builder: (context, state) => const AddEditProductScreen(),
      ),
      GoRoute(
        path: '/products/edit',
        builder: (context, state) => AddEditProductScreen(
          product: state.extra as ProductModel?,
        ),
      ),
      GoRoute(
        path: '/products/details',
        builder: (context, state) => ProductDetailScreen(
          product: state.extra as ProductModel,
        ),
      ),
      GoRoute(
        path: '/products/inventory',
        builder: (context, state) {
          if (state.extra is ProductModel) {
            final p = state.extra as ProductModel;
            return ProductInventoryScreen(
              productId: p.id,
              productName: p.name,
            );
          } else if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            return ProductInventoryScreen(
              productId: map['productId'] as String,
              productName: map['productName'] as String?,
            );
          } else {
            final productId = state.uri.queryParameters['productId'] ?? '';
            return ProductInventoryScreen(productId: productId);
          }
        },
      ),
      GoRoute(
        path: '/products/shipping',
        builder: (context, state) {
          if (state.extra is ProductModel) {
            final p = state.extra as ProductModel;
            return ProductShippingScreen(
              productId: p.id,
              productName: p.name,
            );
          } else if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            return ProductShippingScreen(
              productId: map['productId'] as String,
              productName: map['productName'] as String?,
            );
          } else {
            final productId = state.uri.queryParameters['productId'] ?? '';
            return ProductShippingScreen(productId: productId);
          }
        },
      ),

      // Orders routes
      GoRoute(
        path: '/orders',
        builder: (context, state) => const VendorOrderListScreen(),
      ),
      GoRoute(
        path: '/orders/details',
        builder: (context, state) {
          final order = state.extra as VendorOrderModel;
          return VendorOrderDetailScreen(order: order);
        },
      ),
    ],
  );
}
