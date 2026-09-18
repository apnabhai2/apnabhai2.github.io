// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/auth_service.dart';
import '../modules/add_user/bindings/add_user_binding.dart';
import '../modules/add_user/views/add_user_view.dart';
import '../modules/all_users/bindings/all_users_binding.dart';
import '../modules/all_users/views/all_users_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // If AuthService is not yet registered or initializing, allow initial load
    if (!Get.isRegistered<AuthService>()) {
      return null;
    }

    final authService = Get.find<AuthService>();

    // If attempting to access login while already authenticated, go to Home
    if (route == Routes.LOGIN) {
      if (authService.isAuthenticated) {
        return const RouteSettings(name: Routes.HOME);
      }
      return null;
    }

    // Protect all other routes: must be authenticated
    if (!authService.isAuthenticated) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    return null;
  }
}

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ADD_USER,
      page: () => const AddUserView(),
      binding: AddUserBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ALL_USERS,
      page: () => const AllUsersView(),
      binding: AllUsersBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
