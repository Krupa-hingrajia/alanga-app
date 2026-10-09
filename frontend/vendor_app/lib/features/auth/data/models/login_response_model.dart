import 'user_model.dart';

class LoginResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;

  LoginResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.isNewUser = false,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'isNewUser': isNewUser,
      };
}
