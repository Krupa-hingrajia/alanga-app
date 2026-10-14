import '../../data/models/notification_model.dart';

abstract class NotificationsRepository {
  Future<List<NotificationModel>> getNotifications({int page = 1, int limit = 30});
  Future<int> getUnreadCount();
  Future<bool> markAsRead(String id);
  Future<bool> markAllAsRead();
  Future<bool> deleteNotification(String id);
}
