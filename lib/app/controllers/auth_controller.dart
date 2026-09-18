import 'package:get/get.dart';
import '../data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  bool get isAuthenticated => _authService.isAuthenticated;
  String? get masterCode => _authService.masterCode;
  String? get username => _authService.adminUsername;
}
