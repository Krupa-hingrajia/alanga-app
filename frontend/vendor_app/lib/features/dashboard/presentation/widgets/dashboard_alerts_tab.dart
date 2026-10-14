import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/domain/repositories/notifications_repository.dart';

class DashboardAlertsTab extends StatefulWidget {
  const DashboardAlertsTab({super.key});

  @override
  State<DashboardAlertsTab> createState() => _DashboardAlertsTabState();
}

class _DashboardAlertsTabState extends State<DashboardAlertsTab> {
  final NotificationsRepository _repository = sl<NotificationsRepository>();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _repository.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load notifications. Please pull to refresh.';
        });
      }
    }
  }

  Future<void> _markAsRead(NotificationModel item) async {
    if (item.isRead) return;

    // Optimistically mark as read in local UI
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == item.id);
      if (index != -1) {
        _notifications[index] = item.copyWith(isRead: true);
      }
    });

    try {
      await _repository.markAsRead(item.id);
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });

    try {
      await _repository.markAllAsRead();
    } catch (_) {}
  }

  Future<void> _deleteNotification(String id) async {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });

    try {
      await _repository.deleteNotification(id);
    } catch (_) {}
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'ORDER':
      case 'ORDER_STATUS':
        return Icons.shopping_bag_outlined;
      case 'PRODUCT_APPROVAL':
        return Icons.check_circle_outline;
      case 'PRODUCT_REJECTION':
        return Icons.error_outline;
      case 'KYC_VERIFIED':
        return Icons.verified_user_outlined;
      case 'KYC_REJECTED':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'ORDER':
      case 'ORDER_STATUS':
        return AppColors.primaryGreen;
      case 'PRODUCT_APPROVAL':
      case 'KYC_VERIFIED':
        return const Color(0xFF1B8755);
      case 'PRODUCT_REJECTION':
      case 'KYC_REJECTED':
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF2A5B3D);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
      );
    }

    if (_errorMessage != null && _notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final hasUnread = _notifications.any((n) => !n.isRead);

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: _loadNotifications,
      child: Column(
        children: [
          // Subheader with Quick Action
          if (_notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_notifications.length} Alerts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF11261B).withValues(alpha: 0.6),
                    ),
                  ),
                  if (hasUnread)
                    GestureDetector(
                      onTap: _markAllAsRead,
                      child: const Text(
                        'Mark all as read',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Main list or Empty state
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      return _buildNotificationCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 40,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'No Notifications Yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF11261B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You\'re all caught up! When you receive new customer orders, product approval updates, or KYC status changes, they\'ll appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF11261B).withValues(alpha: 0.55),
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    final iconColor = _getColorForType(item.type);
    final icon = _getIconForType(item.type);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => _deleteNotification(item.id),
      child: GestureDetector(
        onTap: () {
          _markAsRead(item);
          // Tap action: route based on type
          final data = item.data ?? {'type': item.type};
          PushNotificationService().handleNotificationTap(data);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : const Color(0xFFF7FAF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead
                  ? Colors.black.withValues(alpha: 0.04)
                  : AppColors.primaryGreen.withValues(alpha: 0.25),
              width: item.isRead ? 1 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                              color: const Color(0xFF11261B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(item.createdAt),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: const Color(0xFF11261B).withValues(alpha: 0.45),
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.body,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF11261B).withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
