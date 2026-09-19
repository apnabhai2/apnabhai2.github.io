import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/auth_service.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import 'confirmation_dialog.dart';

class AdminSidebar extends StatelessWidget {
  final bool isDrawer;

  const AdminSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final currentRoute = Get.currentRoute;

    final content = Container(
      width: 260,
      color: AppColors.sidebar,
      child: Column(
        children: [
          // Logo / Brand Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MASTER ADMIN',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Control Center',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),
          const SizedBox(height: 16),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  route: Routes.HOME,
                  isActive: currentRoute == Routes.HOME,
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Add User',
                  route: Routes.ADD_USER,
                  isActive: currentRoute == Routes.ADD_USER,
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  icon: Icons.people_alt_rounded,
                  title: 'All Users',
                  route: Routes.ALL_USERS,
                  isActive: currentRoute == Routes.ALL_USERS,
                ),
              ],
            ),
          ),

          // Admin Profile & Logout section at bottom
          Obx(() {
            final admin = authService.currentAdmin.value;
            final username = admin?.username ?? 'Admin';
            final masterCode = admin?.masterCode ?? '---';

            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                masterCode,
                                style: const TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (isDrawer) Get.back();
                        ConfirmationDialog.show(
                          title: 'Confirm Logout',
                          message:
                              'Are you sure you want to log out of Master Admin?',
                          confirmText: 'Logout',
                          confirmColor: AppColors.danger,
                          onConfirm: () => authService.logout(),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded,
                          size: 15, color: AppColors.textSecondary),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );

    if (isDrawer) {
      return Drawer(
        backgroundColor: AppColors.sidebar,
        child: SafeArea(child: content),
      );
    }

    return content;
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () {
        if (isDrawer) Get.back();
        if (!isActive) {
          Get.offAllNamed(route);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
