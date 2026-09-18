import 'dart:convert';
import 'package:get/get.dart';
import '../models/master_admin_model.dart';
import '../providers/auth_provider.dart';
import 'session_storage.dart';

class AuthService extends GetxService {
  final AppAuthProvider _authProvider;

  AuthService({AppAuthProvider? authProvider})
      : _authProvider = authProvider ?? AppAuthProvider();

  final Rx<MasterAdminModel?> currentAdmin = Rx<MasterAdminModel?>(null);
  final RxBool isInitializing = true.obs;

  bool get isAuthenticated => currentAdmin.value != null;
  String? get masterCode => currentAdmin.value?.masterCode;
  String? get adminUsername => currentAdmin.value?.username;

  @override
  void onInit() {
    super.onInit();
    _initSession();
  }

  /// Restore existing session on web page load
  void _initSession() {
    try {
      final savedJson = loadSession('master_admin_session');
      if (savedJson != null && savedJson.isNotEmpty) {
        final map = jsonDecode(savedJson) as Map<String, dynamic>;
        final profile = MasterAdminModel.fromMap(map, map['username'] as String? ?? '');
        if (profile.masterCode.isNotEmpty) {
          currentAdmin.value = profile;
        }
      }
    } catch (_) {
      currentAdmin.value = null;
    } finally {
      isInitializing.value = false;
    }
  }

  /// Authenticate Master Admin directly against the masterAdmin collection
  Future<MasterAdminModel> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final cleanUsername = usernameOrEmail.trim();
    if (cleanUsername.isEmpty) {
      throw Exception('Username is required.');
    }
    if (password.isEmpty) {
      throw Exception('Password is required.');
    }

    try {
      final profile = await _authProvider.authenticateMasterAdmin(
        username: cleanUsername,
        password: password,
      );

      if (profile == null) {
        throw Exception('Master Admin account "$cleanUsername" was not found.');
      }

      currentAdmin.value = profile;
      saveSession(
        'master_admin_session',
        jsonEncode({
          'username': profile.username,
          'masterCode': profile.masterCode,
          'role': profile.role,
        }),
      );

      return profile;
    } catch (e) {
      if (e.toString().contains('INVALID_PASSWORD')) {
        throw Exception('Invalid password for user "$cleanUsername".');
      }
      rethrow;
    }
  }

  /// Secure logout
  Future<void> logout() async {
    try {
      await _authProvider.signOut();
    } catch (_) {}
    clearSession('master_admin_session');
    currentAdmin.value = null;
    Get.offAllNamed('/login');
  }
}
