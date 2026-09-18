import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isPasswordObscured = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  /// Master Admin Login submission
  Future<void> submitLogin() async {
    if (isLoading.value) return; // Prevent multiple submissions

    errorMessage.value = '';

    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final username = usernameController.text.trim();
      final password = passwordController.text;

      final profile = await _authService.login(
        usernameOrEmail: username,
        password: password,
      );

      // Successfully authenticated & loaded trusted masterCode
      Get.snackbar(
        'Welcome, ${profile.username}',
        'Authenticated as Master Admin (${profile.masterCode})',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );

      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = msg;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
