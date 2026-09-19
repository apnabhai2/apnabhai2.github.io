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
  String? get adminEmail => currentAdmin.value?.email;

  @override
  void onInit() {
    super.onInit();
    _initSession();
  }

  /// Restore existing session on web page load
  void _initSession() {
    // 1. Listen for active Firebase Auth session
    _authProvider.authStateChanges.listen((user) async {
      if (user != null && currentAdmin.value == null) {
        try {
          final profile = await _authProvider.fetchMasterAdminProfile(user.uid);
          if (profile != null) {
            currentAdmin.value = profile;
            saveSession('master_admin_session', jsonEncode({
              'uid': profile.uid,
              'username': profile.username,
              'masterCode': profile.masterCode,
              'role': profile.role,
              if (profile.email != null) 'email': profile.email,
            }));
          }
        } catch (_) {}
      }
    });

    // 2. Restore cached session
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

  /// Authenticate Master Admin via Firebase Authentication (Email/Pass or Username)
  Future<MasterAdminModel> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final cleanInput = usernameOrEmail.trim();
    if (cleanInput.isEmpty) {
      throw Exception('Username or email is required.');
    }
    if (password.isEmpty) {
      throw Exception('Password is required.');
    }

    try {
      final profile = await _authProvider.authenticateMasterAdmin(
        usernameOrEmail: cleanInput,
        password: password,
      );

      if (profile == null) {
        throw Exception('Master Admin account "$cleanInput" was not found.');
      }

      currentAdmin.value = profile;
      saveSession(
        'master_admin_session',
        jsonEncode({
          'uid': profile.uid,
          'username': profile.username,
          'masterCode': profile.masterCode,
          'role': profile.role,
          if (profile.email != null) 'email': profile.email,
        }),
      );

      return profile;
    } catch (e) {
      final err = e.toString();
      if (err.contains('INVALID_PASSWORD')) {
        throw Exception('Invalid password for account "$cleanInput".');
      }
      if (err.contains('USER_NOT_FOUND')) {
        throw Exception('Master Admin account "$cleanInput" was not found.');
      }
      rethrow;
    }
  }

  /// Secure logout from Firebase Authentication and local session
  Future<void> logout() async {
    try {
      await _authProvider.signOut();
    } catch (_) {}
    clearSession('master_admin_session');
    currentAdmin.value = null;
    Get.offAllNamed('/login');
  }
}
