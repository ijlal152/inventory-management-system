import 'package:dio/dio.dart';

import '../../models/auth_response_model.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> getProfile(String token);

  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          if (fullName != null) 'fullName': fullName,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      final error = e.response?.data;
      throw Exception(error?['message'] ?? 'Registration failed');
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      final error = e.response?.data;
      throw Exception(error?['message'] ?? 'Login failed');
    }
  }

  @override
  Future<UserModel> getProfile(String token) async {
    try {
      final response = await dio.get(
        '/auth/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return UserModel.fromJson(data);
      } else {
        throw Exception('Failed to get profile');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to get profile: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dio.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
            response.data['message'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      final error = e.response?.data;
      throw Exception(error?['message'] ?? 'Failed to change password');
    }
  }
}
