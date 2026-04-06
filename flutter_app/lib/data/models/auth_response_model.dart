import 'user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String token;

  AuthResponseModel({required this.user, required this.token});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Backend returns: { success: true, message: "...", data: { user: {...}, token: "..." } }
    final data = json['data'];
    return AuthResponseModel(
      user: UserModel.fromJson(data['user']),
      token: data['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': token};
  }
}
