import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({int page = 1, int limit = 30});
  Future<int> getUnreadCount();
  Future<bool> markAsRead(String id);
  Future<bool> markAllAsRead();
  Future<bool> deleteNotification(String id);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiService apiService;

  NotificationsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<NotificationModel>> getNotifications({int page = 1, int limit = 30}) async {
    final response = await apiService.get(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.data != null && response.data['success'] == true) {
      final listData = response.data['data']?['notifications'] as List? ?? [];
      return listData.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await apiService.get(ApiEndpoints.notificationsUnreadCount);
    if (response.data != null && response.data['success'] == true) {
      return (response.data['data']?['unreadCount'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  @override
  Future<bool> markAsRead(String id) async {
    final response = await apiService.patch(ApiEndpoints.notificationRead(id));
    return response.data?['success'] == true;
  }

  @override
  Future<bool> markAllAsRead() async {
    final response = await apiService.patch(ApiEndpoints.notificationsReadAll);
    return response.data?['success'] == true;
  }

  @override
  Future<bool> deleteNotification(String id) async {
    final response = await apiService.delete('${ApiEndpoints.notifications}/$id');
    return response.data?['success'] == true;
  }
}
