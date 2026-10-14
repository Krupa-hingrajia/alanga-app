import '../../domain/repositories/notifications_repository.dart';
import '../datasource/notifications_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationModel>> getNotifications({int page = 1, int limit = 30}) {
    return remoteDataSource.getNotifications(page: page, limit: limit);
  }

  @override
  Future<int> getUnreadCount() {
    return remoteDataSource.getUnreadCount();
  }

  @override
  Future<bool> markAsRead(String id) {
    return remoteDataSource.markAsRead(id);
  }

  @override
  Future<bool> markAllAsRead() {
    return remoteDataSource.markAllAsRead();
  }

  @override
  Future<bool> deleteNotification(String id) {
    return remoteDataSource.deleteNotification(id);
  }
}
