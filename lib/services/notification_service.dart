import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<AppNotification>> getNotifications({
    String? type,
    bool? isRead,
    int page = 1,
    int limit = 100, // Fetch all notifications
  }) async {
    try {
      // Build query string manually since ApiService.get doesn't have params
      String queryString = '?page=$page&limit=$limit';
      if (type != null) {
        queryString += '&type=$type';
      }
      if (isRead != null) {
        queryString += '&is_read=${isRead ? '1' : '0'}';
      }

      print('🔔 Fetching notifications from: /notifications/get_all.php$queryString');

      final response = await _apiService.get(
        '/notifications/get_all.php$queryString',
      );

      print('🔔 Notifications API Response: ${response.containsKey('status') ? response['status'] : 'NO STATUS'}');

      if (response['status'] == 'success') {
        if (response['data'] != null && response['data']['notifications'] != null) {
          final notificationsData = response['data']['notifications'] as List;
          print('🔔 Found ${notificationsData.length} notifications in response');

          final notifications = notificationsData
              .map((json) => AppNotification.fromJson(json))
              .toList();

          print('🔔 Successfully parsed ${notifications.length} notifications');
          return notifications;
        } else {
          print('🔔 No notifications data in response: ${response['data']}');
          return [];
        }
      } else {
        print('🔔 API returned error: ${response['message']}');
        throw Exception(response['message'] ?? 'Failed to load notifications');
      }
    } catch (e) {
      print('❌ Error in getNotifications: $e');
      throw Exception('Failed to load notifications: ${e.toString()}');
    }
  }

  // Get only unread notifications (for new notifications after clear)
  Future<List<AppNotification>> getUnreadNotifications() async {
    return getNotifications(isRead: false);
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      print('🔔 Marking notification as read: $notificationId');
      final response = await _apiService.post(
        '/notifications/mark_read.php',
        {'notification_id': notificationId},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to mark as read');
      }
      print('✅ Notification marked as read successfully');
    } catch (e) {
      print('❌ Error marking as read: $e');
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      print('🔔 Marking all notifications as read');
      final response = await _apiService.post(
        '/notifications/mark_all_read.php',
        {},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to mark all as read');
      }
      print('✅ All notifications marked as read successfully');
    } catch (e) {
      print('❌ Error marking all as read: $e');
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      print('🔔 Deleting notification: $notificationId');
      final response = await _apiService.post(
        '/notifications/delete.php',
        {'notification_id': notificationId},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to delete notification');
      }
      print('✅ Notification deleted successfully');
    } catch (e) {
      print('❌ Error deleting notification: $e');
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      print('🔔 Clearing all notifications from backend');
      final response = await _apiService.post(
        '/notifications/clear_all.php',
        {},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to clear all notifications');
      }
      print('✅ All notifications cleared from backend successfully');
    } catch (e) {
      print('❌ Error clearing all notifications: $e');
      throw Exception('Failed to clear all notifications: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      print('🔔 Getting unread count');
      final response = await _apiService.get(
        '/notifications/get_unread_count.php',
      );

      print('🔔 Unread count API Response: ${response.containsKey('status') ? response['status'] : 'NO STATUS'}');

      if (response['status'] == 'success' && response['data'] != null) {
        final unreadCount = response['data']['unread_count'] ?? 0;
        final byType = response['data']['by_type'] ?? {};

        print('🔔 Unread count from API: $unreadCount');
        print('🔔 Unread count by type: $byType');

        return response['data'];
      } else {
        print('🔔 No unread count data, returning default');
        return {'unread_count': 0, 'by_type': {}};
      }
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return {'unread_count': 0, 'by_type': {}};
    }
  }

  // Test method to debug the API
  Future<void> testApiConnection() async {
    try {
      print('🧪 TESTING NOTIFICATIONS API CONNECTION...');

      // Test 1: Direct API call without parameters
      final testResponse = await _apiService.get('/notifications/get_all.php?page=1&limit=100');
      print('🧪 Test Response Status: ${testResponse['status']}');
      print('🧪 Test Response Message: ${testResponse['message']}');
      print('🧪 Test Response Data: ${testResponse['data']}');

      if (testResponse['status'] == 'success') {
        print('✅ API CONNECTION SUCCESSFUL!');
      } else {
        print('❌ API RETURNED ERROR: ${testResponse['message']}');
      }
    } catch (e) {
      print('❌ API TEST FAILED: $e');
    }
  }
}