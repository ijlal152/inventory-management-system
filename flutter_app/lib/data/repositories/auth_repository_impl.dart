import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<User> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await remoteDataSource.register(
      username: username,
      email: email,
      password: password,
      fullName: fullName,
    );

    // Save token and user data locally
    await localDataSource.saveToken(response.token);
    await localDataSource.saveCurrentUser(response.user);

    return response.user.toEntity();
  }

  @override
  Future<User> login({required String email, required String password}) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );

    // Save token and user data locally
    await localDataSource.saveToken(response.token);
    await localDataSource.saveCurrentUser(response.user);

    return response.user.toEntity();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUserData();
  }

  @override
  Future<User?> getCurrentUser() async {
    final userModel = await localDataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await localDataSource.isAuthenticated();
  }

  @override
  Future<User> getProfile() async {
    final token = await localDataSource.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final userModel = await remoteDataSource.getProfile(token);
    await localDataSource.saveCurrentUser(userModel);
    return userModel.toEntity();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await localDataSource.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    await remoteDataSource.changePassword(
      token: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
