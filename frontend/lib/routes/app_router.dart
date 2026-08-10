import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
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
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await sl<SecureStorageService>().clearAll();
                  router.go('/login');
                },
              ),
            ],
          ),
          body: const Center(
            child: Text(
              'Welcome to E-Commerce Marketplace!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ],
  );
}
