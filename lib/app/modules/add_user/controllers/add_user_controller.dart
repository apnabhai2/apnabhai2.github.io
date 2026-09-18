import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../routes/app_routes.dart';

class AddUserController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final userIdController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isPasswordObscured = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String? get masterCode => _authService.masterCode;

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  /// Create user under current Master Admin
  Future<void> submit() async {
    if (isLoading.value) return; // Prevent multiple clicks

    errorMessage.value = '';

    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final id = userIdController.text.trim();
      final pass = passwordController.text.trim();

      await _firestoreService.addUser(
        id: id,
        pass: pass,
      );

      // Clear input fields
      userIdController.clear();
      passwordController.clear();

      Get.snackbar(
        'User Created',
        'User "$id" created with 3-day demo period under $masterCode.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
      );

      // Navigate to All Users screen
      Get.offNamed(Routes.ALL_USERS);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    userIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
