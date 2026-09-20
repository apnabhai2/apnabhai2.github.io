import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/admin_scaffold.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/user_card.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Master Admin Dashboard',
      actions: [
        IconButton(
          tooltip: 'Add User',
          onPressed: () => Get.toNamed(Routes.ADD_USER),
          icon: const Icon(Icons.person_add_alt_1_rounded,
              color: AppColors.primaryLight),
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.danger),
                const SizedBox(height: 16),
                Text(
                  'Error loading data: ${controller.errorMessage.value}',
                  style: const TextStyle(color: AppColors.danger),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.onInit(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 650;
            final isTablet = screenWidth >= 650 && screenWidth < 1024;

            final pagePadding = isMobile
                ? const EdgeInsets.all(16)
                : isTablet
                    ? const EdgeInsets.all(20)
                    : const EdgeInsets.all(28);

            return SingleChildScrollView(
              padding: pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Primary Summary Cards (Sections 5.1, 5.2, 5.3)
                  _buildSummaryCards(screenWidth),

                  SizedBox(height: isMobile ? 20 : 28),

                  // 2. Charts Section (Section 6)
                  _buildChartsSection(screenWidth),

                  SizedBox(height: isMobile ? 24 : 32),

                  // 3. Recently Added Users Section
                  _buildRecentUsersSection(screenWidth),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  /// Summary Cards: Total Users, Demo Users, Production Users, Stopped Users
  Widget _buildSummaryCards(double screenWidth) {
    final cards = [
      StatCard(
        title: 'Total Users',
        value: '${controller.totalUsers}',
        icon: Icons.people_alt_rounded,
        accentColor: AppColors.primaryLight,
        subtitle: 'All users under your Master Code',
      ),
      StatCard(
        title: 'Demo Users',
        value: '${controller.demoUsers}',
        icon: Icons.timelapse_rounded,
        accentColor: AppColors.demo,
        subtitle: 'Active 3-day demo period',
      ),
      StatCard(
        title: 'Production Users',
        value: '${controller.productionUsers}',
        icon: Icons.rocket_launch_rounded,
        accentColor: AppColors.production,
        subtitle: 'Active in 30-day production',
      ),
      StatCard(
        title: 'Stopped Users',
        value: '${controller.stoppedUsers}',
        icon: Icons.block_rounded,
        accentColor: AppColors.danger,
        subtitle: 'Access blocked by admin',
      ),
    ];

    if (screenWidth >= 1024) {
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: c,
                  ),
                ))
            .toList(),
      );
    }

    // Responsive 2x2 Grid for Mobile & Tablet
    final spacing = screenWidth < 600 ? 10.0 : 14.0;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            SizedBox(width: spacing),
            Expanded(child: cards[1]),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(child: cards[2]),
            SizedBox(width: spacing),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  /// Dashboard Charts: Status Donut Chart & Breakdown
  Widget _buildChartsSection(double screenWidth) {
    final isDesktop = screenWidth >= 900;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Status Distribution',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Real-time breakdown of Demo vs Production status',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 18 : 24),
          if (controller.totalUsers == 0)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pie_chart_outline_rounded,
                      size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text(
                    'No user data recorded yet.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(Routes.ADD_USER),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add First User'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            )
          else if (isDesktop)
            Row(
              children: [
                // Donut Pie Chart
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              controller.touchedPieIndex.value = -1;
                              return;
                            }
                            controller.touchedPieIndex.value =
                                pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 3,
                        centerSpaceRadius: 55,
                        sections: _generatePieSections(),
                      ),
                    ),
                  ),
                ),
                // Legend & Details
                Expanded(
                  flex: 4,
                  child: _buildChartLegend(),
                ),
              ],
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      sections: _generatePieSections(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildChartLegend(),
              ],
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections() {
    final total = controller.totalUsers;
    if (total == 0) return [];

    final isDemoTouch = controller.touchedPieIndex.value == 0;
    final isProdTouch = controller.touchedPieIndex.value == 1;
    final isExpTouch = controller.touchedPieIndex.value == 2;
    final isStopTouch = controller.touchedPieIndex.value == 3;

    return [
      if (controller.demoUsers > 0)
        PieChartSectionData(
          color: AppColors.demo,
          value: controller.demoUsers.toDouble(),
          title: '${controller.demoUsers}',
          radius: isDemoTouch ? 40 : 34,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (controller.productionUsers > 0)
        PieChartSectionData(
          color: AppColors.production,
          value: controller.productionUsers.toDouble(),
          title: '${controller.productionUsers}',
          radius: isProdTouch ? 40 : 34,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (controller.expiredUsers > 0)
        PieChartSectionData(
          color: AppColors.demoExpired,
          value: controller.expiredUsers.toDouble(),
          title: '${controller.expiredUsers}',
          radius: isExpTouch ? 40 : 34,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (controller.stoppedUsers > 0)
        PieChartSectionData(
          color: AppColors.danger,
          value: controller.stoppedUsers.toDouble(),
          title: '${controller.stoppedUsers}',
          radius: isStopTouch ? 40 : 34,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];
  }

  Widget _buildChartLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem(
          label: 'Active Demo Users (3-day)',
          count: controller.demoUsers,
          percentage: controller.demoPercentage,
          color: AppColors.demo,
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          label: 'Production Users (30-day)',
          count: controller.productionUsers,
          percentage: controller.productionPercentage,
          color: AppColors.production,
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          label: 'Expired Users',
          count: controller.expiredUsers,
          percentage: controller.expiredPercentage,
          color: AppColors.demoExpired,
        ),
        const SizedBox(height: 12),
        _buildLegendItem(
          label: 'Stopped Users',
          count: controller.stoppedUsers,
          percentage: controller.stoppedPercentage,
          color: AppColors.danger,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required String label,
    required int count,
    required double percentage,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '(${percentage.toStringAsFixed(1)}%)',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Recent Users Section
  Widget _buildRecentUsersSection(double screenWidth) {
    final recent = controller.recentUsers;
    final isMobile = screenWidth < 600;
    final isDesktop = screenWidth >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recently Added Users',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (controller.allUsers.isNotEmpty)
              TextButton.icon(
                onPressed: () => Get.toNamed(Routes.ALL_USERS),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('View All Users'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recent.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'No users added yet. Use "Add User" to create your first managed user.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          )
        else if (!isDesktop)
          // Mobile & Tablet: Natural height column prevents any button clipping
          Column(
            children: recent.map((user) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: UserCard(
                  key: ValueKey(user.id),
                  user: user,
                  isLoading: controller.isActionLoading.value,
                  onStartProduction: () => controller.startProduction(user),
                  onResetDeviceId: () => controller.resetDeviceId(user),
                  onToggleStop: () => controller.toggleStopUser(user),
                  onDelete: () => controller.deleteUser(user),
                ),
              );
            }).toList(),
          )
        else
          // Desktop: 2-column grid with generous extent so cards never clip
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 420,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: recent.length,
            itemBuilder: (context, index) {
              final user = recent[index];
              return UserCard(
                key: ValueKey(user.id),
                user: user,
                isLoading: controller.isActionLoading.value,
                onStartProduction: () => controller.startProduction(user),
                onResetDeviceId: () => controller.resetDeviceId(user),
                onToggleStop: () => controller.toggleStopUser(user),
                onDelete: () => controller.deleteUser(user),
              );
            },
          ),
      ],
    );
  }
}
