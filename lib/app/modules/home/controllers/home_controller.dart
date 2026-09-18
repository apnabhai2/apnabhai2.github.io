import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firestore_service.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt touchedPieIndex = (-1).obs;
  final RxBool isActionLoading = false.obs;

  StreamSubscription<List<UserModel>>? _usersSubscription;

  @override
  void onInit() {
    super.onInit();
    _subscribeToUsers();
  }

  void _subscribeToUsers() {
    isLoading.value = true;
    errorMessage.value = '';

    _usersSubscription?.cancel();
    _usersSubscription = _firestoreService.streamUsers().listen(
      (users) {
        allUsers.value = users;
        isLoading.value = false;
      },
      onError: (error) {
        errorMessage.value = 'Failed to load user statistics.';
        isLoading.value = false;
      },
    );
  }

  // Real-time computed metrics strictly for the current Master Admin
  int get totalUsers => allUsers.length;
  int get demoUsers => allUsers.where((u) => u.isDemo && !u.isExpired && !u.stop).length;
  int get productionUsers => allUsers.where((u) => u.isProduction && !u.isExpired && !u.stop).length;
  int get expiredUsers => allUsers.where((u) => u.isExpired).length;
  int get stoppedUsers => allUsers.where((u) => u.stop).length;
  List<UserModel> get recentUsers => allUsers.take(5).toList();

  double get demoPercentage {
    if (totalUsers == 0) return 0.0;
    return (demoUsers / totalUsers) * 100;
  }

  double get productionPercentage {
    if (totalUsers == 0) return 0.0;
    return (productionUsers / totalUsers) * 100;
  }

  double get expiredPercentage {
    if (totalUsers == 0) return 0.0;
    return (expiredUsers / totalUsers) * 100;
  }

  double get stoppedPercentage {
    if (totalUsers == 0) return 0.0;
    return (stoppedUsers / totalUsers) * 100;
  }

  /// Extend license for 30 days
  Future<void> startProduction(UserModel user) async {
    isActionLoading.value = true;
    try {
      await _firestoreService.startProduction(user);
      Get.snackbar(
        'Validity Extended',
        'User "${user.id}" validity extended for 30 days.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Action Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Reset device ID
  Future<void> resetDeviceId(UserModel user) async {
    isActionLoading.value = true;
    try {
      await _firestoreService.resetDeviceId(user);
      Get.snackbar(
        'Device ID Cleared',
        'Hardware ID for "${user.id}" was reset.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Reset Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Delete user
  Future<void> deleteUser(UserModel user) async {
    isActionLoading.value = true;
    try {
      await _firestoreService.deleteUser(user);
      Get.snackbar(
        'User Deleted',
        'User "${user.id}" has been removed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Deletion Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Toggle stop status
  Future<void> toggleStopUser(UserModel user) async {
    final targetStop = !user.stop;
    isActionLoading.value = true;
    try {
      await _firestoreService.setStopStatus(user, targetStop);
      Get.snackbar(
        targetStop ? 'User Stopped' : 'User Resumed',
        targetStop
            ? 'User "${user.id}" status set to stopped (stop=true).'
            : 'User "${user.id}" access restored (stop=false).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: targetStop
            ? const Color(0xFFEF4444).withValues(alpha: 0.9)
            : const Color(0xFF10B981).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Action Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  @override
  void onClose() {
    _usersSubscription?.cancel();
    super.onClose();
  }
}
