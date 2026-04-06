import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  });

  Future<User> login({required String email, required String password});

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<bool> isAuthenticated();

  Future<User> getProfile();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
