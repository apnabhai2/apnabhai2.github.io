import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/user_provider.dart';
import '../data/services/auth_service.dart';
import '../data/services/firestore_service.dart';
import '../data/services/time_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TimeService>(TimeService(), permanent: true);
    Get.put<AppAuthProvider>(AppAuthProvider(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<UserProvider>(UserProvider(), permanent: true);
    Get.put<FirestoreService>(FirestoreService(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
