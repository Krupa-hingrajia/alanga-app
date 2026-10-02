import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AlertItem {
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;
  final Color color;

  const AlertItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
  });
}

class DashboardAlertsTab extends StatelessWidget {
  const DashboardAlertsTab({super.key});

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertItems = [
      AlertItem(
        title: 'Inventory Sync Complete',
        message: 'Your multi-variant warehouse stocks are updated across customer shopping channels.',
        time: DateTime.now().subtract(const Duration(minutes: 25)),
        icon: Icons.inventory_2_outlined,
        color: AppColors.primaryGreen,
      ),
      AlertItem(
        title: 'Category Approval Successful',
        message: 'Your category submission "Fashion Wear" has been reviewed and approved by administrator.',
        time: DateTime.now().subtract(const Duration(hours: 1)),
        icon: Icons.check_circle_outline,
        color: AppColors.primaryGreen,
      ),
      AlertItem(
        title: 'New Brand Request Reviewing',
        message: 'Your registration request for brand "Alanga Apparel" is under priority verification.',
        time: DateTime.now().subtract(const Duration(hours: 4)),
        icon: Icons.hourglass_top,
        color: AppColors.brandOrange,
      ),
      AlertItem(
        title: 'Seller Panel Welcome',
        message: 'Welcome to Alanga Seller Central Panel! Let\'s catalog products to drive shop orders.',
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
                            alert.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF11261B),
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(alert.time),
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      alert.message,
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
