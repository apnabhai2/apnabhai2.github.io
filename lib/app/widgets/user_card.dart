import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../data/models/user_model.dart';
import '../theme/app_colors.dart';
import 'confirmation_dialog.dart';

class UserCard extends StatefulWidget {
  final UserModel user;
  final VoidCallback onStartProduction;
  final VoidCallback onResetDeviceId;
  final VoidCallback onDelete;
  final VoidCallback? onToggleStop;
  final bool isLoading;

  const UserCard({
    super.key,
    required this.user,
    required this.onStartProduction,
    required this.onResetDeviceId,
    required this.onDelete,
    this.onToggleStop,
    this.isLoading = false,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool _isPasswordVisible = false;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied to Clipboard',
      '$label copied successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final statusLabel = user.statusLabel;

    final Color statusColor;
    final Color statusBg;

    if (user.stop) {
      statusColor = AppColors.danger;
      statusBg = AppColors.dangerBg;
    } else if (user.isExpired) {
      statusColor = AppColors.demoExpired;
      statusBg = AppColors.demoExpiredBg;
    } else if (user.isDemo) {
      statusColor = AppColors.demo;
      statusBg = AppColors.demoBg;
    } else {
      statusColor = AppColors.production;
      statusBg = AppColors.productionBg;
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: ID & Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primarySubtle,
                      child: Text(
                        user.id.isNotEmpty ? user.id[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.id,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: isMobile ? 16 : 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded,
                                    size: 15, color: AppColors.textMuted),
                                tooltip: 'Copy ID',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () =>
                                    _copyToClipboard(user.id, 'User ID'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.remainingTimeFormatted,
                            style: TextStyle(
                              color: user.isExpired
                                  ? AppColors.danger
                                  : AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Credentials Row: Password with hide/reveal & copy
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 15, color: AppColors.textMuted),
              const SizedBox(width: 8),
              const Text(
                'Password: ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  _isPasswordVisible
                      ? user.pass
                      : '•' * (user.pass.isEmpty ? 8 : user.pass.length),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                tooltip: _isPasswordVisible ? 'Hide' : 'Show',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy_rounded,
                    size: 15, color: AppColors.textMuted),
                tooltip: 'Copy Password',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _copyToClipboard(user.pass, 'Password'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Device ID Row
          Row(
            children: [
              const Icon(Icons.computer_rounded,
                  size: 15, color: AppColors.textMuted),
              const SizedBox(width: 8),
              const Text(
                'Device ID: ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  user.deviceId.isNotEmpty ? user.deviceId : 'Not Bound (Empty)',
                  style: TextStyle(
                    color: user.deviceId.isNotEmpty
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                    fontSize: 12,
                    fontFamily: user.deviceId.isNotEmpty ? 'monospace' : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (user.deviceId.isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.copy_rounded,
                      size: 15, color: AppColors.textMuted),
                  tooltip: 'Copy Device ID',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () =>
                      _copyToClipboard(user.deviceId, 'Device ID'),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Start Date
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 8),
              const Text(
                'Started: ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  user.formattedCurrentDate,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Expiry Date
          Row(
            children: [
              const Icon(Icons.event_busy_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 8),
              const Text(
                'Expires: ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  user.formattedExpiryDate,
                  style: TextStyle(
                    color: user.isExpired ? AppColors.danger : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Builder(
            builder: (context) {
              final btnPadding = EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 13,
                vertical: isMobile ? 8 : 10,
              );
              final btnTextStyle = TextStyle(
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.w600,
              );

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!user.isProduction || user.isExpired)
                    ElevatedButton.icon(
                      onPressed: widget.isLoading
                          ? null
                          : () {
                              ConfirmationDialog.show(
                                title: user.isDemo
                                    ? 'Start Production'
                                    : 'Extend Validity',
                                message: user.isDemo
                                    ? 'Transition "${user.id}" to production for 30 days starting now?'
                                    : 'Extend access for "${user.id}" by 30 days starting now?',
                                confirmText: user.isDemo
                                    ? 'Activate (30 Days)'
                                    : 'Extend (30 Days)',
                                confirmColor: AppColors.production,
                                onConfirm: widget.onStartProduction,
                              );
                            },
                      icon: Icon(
                        user.isDemo
                            ? Icons.rocket_launch_rounded
                            : Icons.more_time_rounded,
                        size: isMobile ? 15 : 16,
                      ),
                      label: Text(
                        user.isDemo ? 'Start Production (30d)' : 'Extend 30d',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.production,
                        foregroundColor: Colors.white,
                        padding: btnPadding,
                        textStyle: btnTextStyle,
                      ),
                    ),
                  if (user.deviceId.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: widget.isLoading
                          ? null
                          : () {
                              ConfirmationDialog.show(
                                title: 'Reset Hardware ID',
                                message:
                                    'Clear hardware binding for "${user.id}"? User can then open the software on another computer.',
                                confirmText: 'Reset Hardware',
                                confirmColor: const Color(0xFF3B82F6),
                                onConfirm: widget.onResetDeviceId,
                              );
                            },
                      icon: Icon(Icons.phonelink_erase_rounded,
                          size: isMobile ? 15 : 16,
                          color: const Color(0xFF3B82F6)),
                      label: const Text(
                        'Reset Device',
                        style: TextStyle(color: Color(0xFF3B82F6)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color:
                                const Color(0xFF3B82F6).withValues(alpha: 0.5)),
                        padding: btnPadding,
                        textStyle: btnTextStyle,
                      ),
                    ),
                  if (widget.onToggleStop != null)
                    OutlinedButton.icon(
                      onPressed: widget.isLoading
                          ? null
                          : () {
                              if (user.stop) {
                                ConfirmationDialog.show(
                                  title: 'Resume User Access',
                                  message:
                                      'Restore software access for "${user.id}"?',
                                  confirmText: 'Resume Access',
                                  confirmColor: AppColors.success,
                                  onConfirm: widget.onToggleStop!,
                                );
                              } else {
                                ConfirmationDialog.show(
                                  title: 'Stop User Access',
                                  message:
                                      'Stop access for "${user.id}"? Software will block access with stop=true.',
                                  confirmText: 'Stop User',
                                  confirmColor: AppColors.danger,
                                  onConfirm: widget.onToggleStop!,
                                );
                              }
                            },
                      icon: Icon(
                        user.stop
                            ? Icons.play_arrow_rounded
                            : Icons.stop_circle_outlined,
                        size: isMobile ? 15 : 16,
                        color: user.stop ? AppColors.success : AppColors.danger,
                      ),
                      label: Text(
                        user.stop ? 'Resume' : 'Stop',
                        style: TextStyle(
                          color:
                              user.stop ? AppColors.success : AppColors.danger,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: (user.stop
                                  ? AppColors.success
                                  : AppColors.danger)
                              .withValues(alpha: 0.5),
                        ),
                        padding: btnPadding,
                        textStyle: btnTextStyle,
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: widget.isLoading
                        ? null
                        : () {
                            ConfirmationDialog.show(
                              title: 'Delete User',
                              message:
                                  'Are you sure you want to delete "${user.id}"? This will terminate their access immediately.',
                              confirmText: 'Delete',
                              confirmColor: AppColors.danger,
                              onConfirm: widget.onDelete,
                            );
                          },
                    icon: Icon(Icons.delete_outline_rounded,
                        size: isMobile ? 15 : 16, color: AppColors.danger),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: AppColors.danger),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.danger.withValues(alpha: 0.5)),
                      padding: btnPadding,
                      textStyle: btnTextStyle,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
