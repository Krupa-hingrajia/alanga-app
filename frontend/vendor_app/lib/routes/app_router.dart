import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/success_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';

// Categories imports
import '../features/categories/data/models/category_model.dart';
import '../features/categories/presentation/screens/category_list_screen.dart';
import '../features/categories/presentation/screens/add_edit_category_screen.dart';
import '../features/categories/presentation/screens/category_detail_screen.dart';

// Brands imports
import '../features/brands/data/models/brand_model.dart';
import '../features/brands/presentation/screens/brand_list_screen.dart';
import '../features/brands/presentation/screens/add_edit_brand_screen.dart';
import '../features/brands/presentation/screens/brand_detail_screen.dart';

// Products imports
import '../features/products/data/models/product_model.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/products/presentation/screens/add_edit_product_screen.dart';
import '../features/products/presentation/screens/product_detail_screen.dart';

// SubCategories imports
import '../features/sub_categories/data/models/sub_category_model.dart';
import '../features/sub_categories/presentation/screens/sub_category_list_screen.dart';
import '../features/sub_categories/presentation/screens/add_edit_sub_category_screen.dart';
import '../features/sub_categories/presentation/screens/sub_category_detail_screen.dart';

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

      if (token == null) {
        if (!isLoggingIn && !isRegistering && !isSuccess) {
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
        path: '/success',
        builder: (context, state) => const SuccessScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DashboardScreen(),
      ),
      
      // Categories routes
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryListScreen(),
      ),
      GoRoute(
        path: '/categories/add',
        builder: (context, state) => const AddEditCategoryScreen(),
      ),
      GoRoute(
        path: '/categories/edit',
        builder: (context, state) => AddEditCategoryScreen(
          category: state.extra as CategoryModel?,
        ),
      ),
      GoRoute(
        path: '/categories/details',
        builder: (context, state) => CategoryDetailScreen(
          category: state.extra as CategoryModel,
        ),
      ),

      // Brands routes
      GoRoute(
        path: '/brands',
        builder: (context, state) => const BrandListScreen(),
      ),
      GoRoute(
        path: '/brands/add',
        builder: (context, state) => const AddEditBrandScreen(),
      ),
      GoRoute(
        path: '/brands/edit',
        builder: (context, state) => AddEditBrandScreen(
          brand: state.extra as BrandModel?,
        ),
      ),
      GoRoute(
        path: '/brands/details',
        builder: (context, state) => BrandDetailScreen(
          brand: state.extra as BrandModel,
        ),
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

      // SubCategories routes
      GoRoute(
        path: '/subcategories',
        builder: (context, state) => const SubCategoryListScreen(),
      ),
      GoRoute(
        path: '/subcategories/add',
        builder: (context, state) => const AddEditSubCategoryScreen(),
      ),
      GoRoute(
        path: '/subcategories/edit',
        builder: (context, state) => AddEditSubCategoryScreen(
          subCategory: state.extra as SubCategoryModel?,
        ),
      ),
      GoRoute(
        path: '/subcategories/details',
        builder: (context, state) {
          final extraMap = state.extra as Map<String, dynamic>;
          final subCategory = extraMap['subCategory'] as SubCategoryModel;
          final categoryName = extraMap['categoryName'] as String;
          return SubCategoryDetailScreen(
            subCategory: subCategory,
            categoryName: categoryName,
          );
        },
      ),
    ],
  );
}
