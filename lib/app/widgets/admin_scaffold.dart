import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/auth_service.dart';
import '../theme/app_colors.dart';
import 'admin_sidebar.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              title: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                ...?actions,
                Obx(() {
                  final code = authService.masterCode ?? '';
                  if (code.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Chip(
                      label: Text(
                        code,
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      backgroundColor: AppColors.primarySubtle,
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }),
              ],
            ),
      drawer: isDesktop ? null : const AdminSidebar(isDrawer: true),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Persistent Sidebar on Desktop
          if (isDesktop) const AdminSidebar(isDrawer: false),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header on Desktop
                if (isDesktop)
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        bottom: BorderSide(color: AppColors.border, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            ...?actions,
                            const SizedBox(width: 12),
                            Obx(() {
                              final admin = authService.currentAdmin.value;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.verified_user_rounded,
                                      size: 16,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Master Admin: ${admin?.masterCode ?? "---"}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Main body content
                Expanded(
                  child: SelectionArea(
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
