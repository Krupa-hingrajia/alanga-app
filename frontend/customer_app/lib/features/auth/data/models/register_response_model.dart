import 'user_model.dart';

class RegisterResponseModel {
  final UserModel user;

  RegisterResponseModel({required this.user});

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(user: UserModel.fromJson(json));
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
      };
}
