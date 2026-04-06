import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  Future<UserModel?> getCurrentUser();
  Future<void> saveCurrentUser(UserModel user);
  Future<void> clearUserData();
  Future<bool> isAuthenticated();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userJson = sharedPreferences.getString(_userKey);
    if (userJson == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveCurrentUser(UserModel user) async {
    await sharedPreferences.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clearUserData() async {
    await deleteToken();
    await sharedPreferences.remove(_userKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
