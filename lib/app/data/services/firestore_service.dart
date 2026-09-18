import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import 'auth_service.dart';

class FirestoreService extends GetxService {
  final UserProvider _userProvider;
  final AuthService _authService;

  FirestoreService({
    UserProvider? userProvider,
    AuthService? authService,
  })  : _userProvider = userProvider ?? UserProvider(),
        _authService = authService ?? Get.find<AuthService>();

  /// Stream of users scoped to the currently authenticated Master Admin's masterCode
  Stream<List<UserModel>> streamUsers() {
    final masterCode = _authService.masterCode;
    if (masterCode == null || masterCode.isEmpty) {
      return Stream.value(<UserModel>[]);
    }

    return _userProvider.streamUsersByMasterCode(masterCode).map((snapshot) {
      final users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

      // Sort by currentDate descending (newest first)
      users.sort((a, b) => b.currentDate.compareTo(a.currentDate));

      return users;
    });
  }

  /// Create a new user (default 3-day demo) matching the exact schema of the client software
  Future<void> addUser({
    required String id,
    required String pass,
    String deviceId = '',
  }) async {
    final currentAdmin = _authService.currentAdmin.value;
    if (currentAdmin == null || currentAdmin.masterCode.isEmpty) {
      throw Exception('Unauthorized: No active Master Admin session.');
    }

    final cleanId = id.trim();
    final cleanPass = pass.trim();
    if (cleanId.isEmpty) {
      throw Exception('User ID is required.');
    }
    if (cleanPass.isEmpty) {
      throw Exception('Password is required.');
    }

    // Check if user ID already exists
    final existing = await _userProvider.getUser(cleanId);
    if (existing.exists) {
      throw Exception('A user with ID "$cleanId" already exists.');
    }

    final now = DateTime.now();
    final demoExpiry = now.add(const Duration(days: 3));

    final newUserData = <String, dynamic>{
      'id': cleanId,
      'pass': cleanPass,
      'deviceId': deviceId.trim(),
      'currentDate': Timestamp.fromDate(now),
      'expiryDate': Timestamp.fromDate(demoExpiry),
      'stop': false, // Access allowed initially
      'masterCode': currentAdmin.masterCode,
    };

    await _userProvider.setUser(cleanId, newUserData);
  }

  /// Toggle or set stop status (blocks or unblocks user access)
  Future<void> setStopStatus(UserModel user, bool isStopped) async {
    final currentAdmin = _authService.currentAdmin.value;
    if (currentAdmin == null || currentAdmin.masterCode != user.masterCode) {
      throw Exception('Unauthorized: Cannot modify a user belonging to another Master Admin.');
    }

    await _userProvider.updateUser(user.id, {
      'stop': isStopped,
    });
  }

  /// Transition a user to Production / extend validity (30-day period)
  Future<void> startProduction(UserModel user) async {
    final currentAdmin = _authService.currentAdmin.value;
    if (currentAdmin == null || currentAdmin.masterCode != user.masterCode) {
      throw Exception('Unauthorized: Cannot modify a user belonging to another Master Admin.');
    }

    final now = DateTime.now();
    final prodExpiry = now.add(const Duration(days: 30));

    final updateData = <String, dynamic>{
      'currentDate': Timestamp.fromDate(now),
      'expiryDate': Timestamp.fromDate(prodExpiry),
    };

    await _userProvider.updateUser(user.id, updateData);
  }

  /// Reset the hardware Device ID so the user can re-bind their software
  Future<void> resetDeviceId(UserModel user) async {
    final currentAdmin = _authService.currentAdmin.value;
    if (currentAdmin == null || currentAdmin.masterCode != user.masterCode) {
      throw Exception('Unauthorized: Cannot modify a user belonging to another Master Admin.');
    }

    await _userProvider.updateUser(user.id, {
      'deviceId': '',
    });
  }

  /// Delete a user document
  Future<void> deleteUser(UserModel user) async {
    final currentAdmin = _authService.currentAdmin.value;
    if (currentAdmin == null || currentAdmin.masterCode != user.masterCode) {
      throw Exception('Unauthorized: Cannot delete a user belonging to another Master Admin.');
    }

    await _userProvider.deleteUser(user.id);
  }
}
