import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/admin_scaffold.dart';
import '../../../widgets/user_card.dart';
import '../controllers/all_users_controller.dart';

class AllUsersView extends GetView<AllUsersController> {
  const AllUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'All Users',
      actions: [
        ElevatedButton.icon(
          onPressed: () => Get.toNamed(Routes.ADD_USER),
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
          label: const Text('Add User'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search and Filter Bar (Maintains focus and internal reactivity)
                _buildFilterBar(),

                const SizedBox(height: 24),

                // Live Reactive Users Grid
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    );
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 48, color: AppColors.danger),
                            const SizedBox(height: 16),
                            Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: AppColors.danger),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => controller.onInit(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final users = controller.filteredUsers;

                  if (users.isEmpty) {
                    return _buildEmptyState();
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 2 : 1,
                      mainAxisExtent: 370,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return Obx(() {
                        final isUpdating = controller.isUserUpdating(user.id);

                        return UserCard(
                          key: ValueKey(user.id),
                          user: user,
                          isLoading: isUpdating,
                          onStartProduction: () =>
                              controller.startProduction(user),
                          onResetDeviceId: () =>
                              controller.resetDeviceId(user),
                          onToggleStop: () => controller.toggleStopUser(user),
                          onDelete: () => controller.deleteUser(user),
                        );
                      });
                    },
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input with stable controller
          TextField(
            controller: controller.searchController,
            onChanged: controller.updateSearch,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search user by ID, password, or device ID...',
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.textMuted),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink()),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          // Granular Reactive Filter Pills
          Obx(() {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(
                  'ALL',
                  'All Users (${controller.totalCount})',
                ),
                _buildFilterChip(
                  'DEMO',
                  'Demo (${controller.demoCount})',
                  color: AppColors.demo,
                ),
                _buildFilterChip(
                  'PRODUCTION',
                  'Production (${controller.productionCount})',
                  color: AppColors.production,
                ),
                _buildFilterChip(
                  'EXPIRED',
                  'Expired (${controller.expiredCount})',
                  color: AppColors.demoExpired,
                ),
                _buildFilterChip(
                  'STOPPED',
                  'Stopped (${controller.stoppedCount})',
                  color: AppColors.danger,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, {Color? color}) {
    final isSelected = controller.selectedFilter.value == filterKey;
    final chipColor = color ?? AppColors.primary;

    return InkWell(
      onTap: () => controller.setFilter(filterKey),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.2)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? chipColor : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            final hasFilter = controller.selectedFilter.value != 'ALL' ||
                controller.searchQuery.value.isNotEmpty;

            return Icon(
              hasFilter
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,
              size: 56,
              color: AppColors.textMuted,
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final hasFilter = controller.selectedFilter.value != 'ALL' ||
                controller.searchQuery.value.isNotEmpty;

            return Text(
              hasFilter ? 'No matching users found' : 'No users found',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            );
          }),
          const SizedBox(height: 8),
          Obx(() {
            final hasFilter = controller.selectedFilter.value != 'ALL' ||
                controller.searchQuery.value.isNotEmpty;

            return Text(
              hasFilter
                  ? 'Try adjusting your search criteria or status filter.'
                  : 'Get started by creating your first managed user under your Master Code.',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            );
          }),
          const SizedBox(height: 20),
          Obx(() {
            final hasFilter = controller.selectedFilter.value != 'ALL' ||
                controller.searchQuery.value.isNotEmpty;

            if (hasFilter) {
              return OutlinedButton(
                onPressed: controller.clearSearch,
                child: const Text('Reset Filters'),
              );
            }
            return ElevatedButton.icon(
              onPressed: () => Get.toNamed(Routes.ADD_USER),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add User'),
            );
          }),
        ],
      ),
    );
  }
}
