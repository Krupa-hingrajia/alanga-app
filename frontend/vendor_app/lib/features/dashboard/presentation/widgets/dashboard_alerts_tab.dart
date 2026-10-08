import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class AlertItem {
  final String titleKey;
  final String messageKey;
  final DateTime time;
  final IconData icon;
  final Color color;

  const AlertItem({
    required this.titleKey,
    required this.messageKey,
    required this.time,
    required this.icon,
    required this.color,
  });
}

class DashboardAlertsTab extends StatelessWidget {
  const DashboardAlertsTab({super.key});

  String _formatTime(BuildContext context, DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) {
      return context.tr('just_now');
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ${context.tr('m_ago')}';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ${context.tr('h_ago')}';
    } else {
      return '${diff.inDays} ${context.tr('d_ago')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertItems = [
      AlertItem(
        titleKey: 'alert_inventory_sync_title',
        messageKey: 'alert_inventory_sync_msg',
        time: DateTime.now().subtract(const Duration(minutes: 25)),
        icon: Icons.inventory_2_outlined,
        color: AppColors.primaryGreen,
      ),
      AlertItem(
        titleKey: 'alert_category_approved_title',
        messageKey: 'alert_category_approved_msg',
        time: DateTime.now().subtract(const Duration(hours: 1)),
        icon: Icons.check_circle_outline,
        color: AppColors.primaryGreen,
      ),
      AlertItem(
        titleKey: 'alert_brand_reviewing_title',
        messageKey: 'alert_brand_reviewing_msg',
        time: DateTime.now().subtract(const Duration(hours: 4)),
        icon: Icons.hourglass_top,
        color: AppColors.brandOrange,
      ),
      AlertItem(
        titleKey: 'alert_welcome_title',
        messageKey: 'alert_welcome_msg',
        time: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.verified_user_outlined,
        color: Colors.blue,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alertItems.length,
      itemBuilder: (context, index) {
        final alert = alertItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: alert.color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(alert.icon, color: alert.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            context.tr(alert.titleKey),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF11261B),
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(context, alert.time),
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr(alert.messageKey),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

