import 'dart:developer';

import 'package:get/get.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxString errorMessage = ''.obs;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.checkAuthStatusUseCase,
  });

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      isAuthenticated.value = await checkAuthStatusUseCase();
      if (isAuthenticated.value) {
        currentUser.value = await getCurrentUserUseCase();
      }
    } catch (e) {
      isAuthenticated.value = false;
      currentUser.value = null;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await registerUseCase(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );

      currentUser.value = user;
      isAuthenticated.value = true;
      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Registration successful!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      log("Error while registering: ${errorMessage.value}");
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await loginUseCase(email: email, password: password);

      currentUser.value = user;
      isAuthenticated.value = true;
      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Login successful!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase();
      currentUser.value = null;
      isAuthenticated.value = false;

      // Navigate to login page
      Get.offAllNamed('/login');

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
