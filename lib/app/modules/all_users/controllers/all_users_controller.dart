import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';

class AllUsersController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'ALL'.obs; // ALL, DEMO, PRODUCTION, EXPIRED
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Track updating users per user ID so only the clicked card shows a spinner
  final RxSet<String> updatingUserIds = <String>{}.obs;

  final TextEditingController searchController = TextEditingController();
  StreamSubscription<List<UserModel>>? _subscription;

  @override
  void onInit() {
    super.onInit();

    // Debounce search input for high performance
    debounce(
      searchQuery,
      (_) => _applyFilter(),
      time: const Duration(milliseconds: 150),
    );

    // Re-filter whenever allUsers or selectedFilter change
    ever(allUsers, (_) => _applyFilter());
    ever(selectedFilter, (_) => _applyFilter());

    // Listen to admin authentication state changes
    ever(_authService.currentAdmin, (_) => _bindUsersStream());

    _bindUsersStream();
  }

  /// Real-time stream binding for Master Admin users
  void _bindUsersStream() {
    final masterCode = _authService.masterCode;
    if (masterCode == null || masterCode.isEmpty) {
      if (!_authService.isInitializing.value) {
        isLoading.value = false;
      }
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    _subscription?.cancel();
    _subscription = _firestoreService.streamUsers().listen(
      (users) {
        allUsers.assignAll(users);
        _applyFilter();
        isLoading.value = false;
      },
      onError: (err) {
        errorMessage.value = 'Failed to load users: $err';
        isLoading.value = false;
      },
    );
  }

  /// Filter application reacting to allUsers, selectedFilter, and searchQuery
  void _applyFilter() {
    final q = searchQuery.value.trim().toLowerCase();
    final filter = selectedFilter.value;

    final results = allUsers.where((user) {
      // 1. Status Filter
      if (filter == 'STOPPED') {
        if (!user.stop) return false;
      } else if (filter == 'DEMO') {
        if (!user.isDemo || user.isExpired || user.stop) return false;
      } else if (filter == 'PRODUCTION') {
        if (!user.isProduction || user.isExpired || user.stop) return false;
      } else if (filter == 'EXPIRED') {
        if (!user.isExpired) return false;
      }

      // 2. Search query filter
      if (q.isNotEmpty) {
        final matchId = user.id.toLowerCase().contains(q);
        final matchDevice = user.deviceId.toLowerCase().contains(q);
        final matchPass = user.pass.toLowerCase().contains(q);
        if (!matchId && !matchDevice && !matchPass) {
          return false;
        }
      }

      return true;
    }).toList();

    filteredUsers.assignAll(results);
  }

  // Reactive counts for filter badges
  int get totalCount => allUsers.length;
  int get demoCount => allUsers.where((u) => u.isDemo && !u.isExpired && !u.stop).length;
  int get productionCount => allUsers.where((u) => u.isProduction && !u.isExpired && !u.stop).length;
  int get expiredCount => allUsers.where((u) => u.isExpired).length;
  int get stoppedCount => allUsers.where((u) => u.stop).length;

  bool isUserUpdating(String id) => updatingUserIds.contains(id);

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  /// Toggle stop status (change stop to true or false) with optimistic update
  Future<void> toggleStopUser(UserModel user) async {
    final targetStop = !user.stop;
    updatingUserIds.add(user.id);
    try {
      await _firestoreService.setStopStatus(user, targetStop);

      // Optimistically update local list so UI reflects immediately
      final updated = user.copyWith(stop: targetStop);
      final index = allUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        allUsers[index] = updated;
        allUsers.refresh();
      }

      Get.closeAllSnackbars();
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
      Get.closeAllSnackbars();
      Get.snackbar(
        'Operation Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      updatingUserIds.remove(user.id);
    }
  }

  /// Extend 30 days validity with optimistic update
  Future<void> startProduction(UserModel user) async {
    updatingUserIds.add(user.id);
    try {
      await _firestoreService.startProduction(user);

      // Optimistically update local list so UI reflects immediately
      final now = DateTime.now();
      final updated = user.copyWith(
        currentDate: now,
        expiryDate: now.add(const Duration(days: 30)),
      );

      final index = allUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        allUsers[index] = updated;
        allUsers.refresh();
      }

      Get.closeAllSnackbars();
      Get.snackbar(
        'Validity Extended',
        'User "${user.id}" validity extended for 30 days.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.closeAllSnackbars();
      Get.snackbar(
        'Operation Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      updatingUserIds.remove(user.id);
    }
  }

  /// Reset user hardware device ID with optimistic update
  Future<void> resetDeviceId(UserModel user) async {
    updatingUserIds.add(user.id);
    try {
      await _firestoreService.resetDeviceId(user);

      final updated = user.copyWith(deviceId: '');
      final index = allUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        allUsers[index] = updated;
        allUsers.refresh();
      }

      Get.closeAllSnackbars();
      Get.snackbar(
        'Device ID Cleared',
        'Hardware ID for "${user.id}" was reset.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.closeAllSnackbars();
      Get.snackbar(
        'Reset Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      updatingUserIds.remove(user.id);
    }
  }

  /// Delete user with optimistic update
  Future<void> deleteUser(UserModel user) async {
    updatingUserIds.add(user.id);
    try {
      await _firestoreService.deleteUser(user);

      allUsers.removeWhere((u) => u.id == user.id);
      allUsers.refresh();

      Get.closeAllSnackbars();
      Get.snackbar(
        'User Deleted',
        'User "${user.id}" has been deleted.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.closeAllSnackbars();
      Get.snackbar(
        'Delete Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      updatingUserIds.remove(user.id);
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
