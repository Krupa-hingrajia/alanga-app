class ApiEndpoints {
  // Use http://10.0.2.2:3000/api/v1 for Android emulator localhost
  // Use http://localhost:3000/api/v1 for iOS simulator localhost
  static const String baseUrl = 'http://localhost:3000/api/v1';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
}
