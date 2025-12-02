import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../utils/api_helper.dart';
import '../config/app_colors.dart';
import 'auth_controller.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  final notifications = <AppNotification>[].obs;
  final filteredNotifications = <AppNotification>[].obs;
  final isLoading = false.obs;
  final selectedTab = 0.obs; // 0: All, 1: Unread, 2: Read
  final unreadCount = 0.obs;
  final unreadCountByType = <String, int>{}.obs;

  // Track first load
  bool _isFirstLoad = true;
  bool _hasLoaded = false;

  // CRITICAL FIX: Make keys admin-specific
  String get _clearedNotificationsKey => 'cleared_notifications_${_currentAdminId}';
  String get _lastClearAllKey => 'last_clear_all_timestamp_${_currentAdminId}';

  // Get current admin ID
  String get _currentAdminId {
    final authController = Get.find<AuthController>();
    return authController.admin?.id ?? 'unknown';
  }

  @override
  void onInit() {
    super.onInit();
    print('🔔 NotificationController initialized');
  }

  // CRITICAL FIX: Auto-load notifications when admin navigates to notifications page
  Future<void> initializeForCurrentAdmin() async {
    final adminId = _currentAdminId;
    print('🔔 Initializing notifications for admin: $adminId');

    // Reset state for new admin
    _isFirstLoad = false; // Allow error messages to show

    // Load notifications immediately
    await Future.wait([
      loadNotifications(),
      loadUnreadCount(),
    ]);
  }

  Future<void> _testApiConnection() async {
    print('🔔 Testing API connection...');

    // CRITICAL FIX: Verify we have a token before making the request
    final token = await ApiHelper.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized access. Please login.');
    }

    await _notificationService.testApiConnection();
  }

  Future<void> loadNotifications() async {
    try {
      print('🔔 Starting to load notifications for admin: $_currentAdminId');

      // Only show loading if we don't have any notifications
      if (notifications.isEmpty) {
        isLoading.value = true;
      }

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      // CRITICAL FIX: Get admin-specific cleared notification IDs
      final prefs = await SharedPreferences.getInstance();
      final clearedIdsJson = prefs.getStringList(_clearedNotificationsKey) ?? [];
      final clearedIds = Set<String>.from(clearedIdsJson);
      print('🔔 Cleared notification IDs for admin $_currentAdminId: $clearedIds');

      // Load ALL notifications from API
      final data = await _notificationService.getNotifications();
      print('🔔 Loaded ${data.length} notifications from service');

      // Filter out cleared notifications (admin-specific)
      final filteredData = data.where((notification) => !clearedIds.contains(notification.id)).toList();
      print('🔔 After filtering cleared: ${filteredData.length} notifications');

      notifications.value = filteredData;
      _filterNotifications();
      _hasLoaded = true;

      print('🔔 Notifications loaded successfully. Total: ${notifications.length}');
    } catch (e) {
      print('❌ Error loading notifications: $e');

      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          'Failed to load notifications: ${e.toString().replaceAll("Exception: ", "")}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        print('Notification load error (first load): $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      print('🔔 Loading unread count for admin: $_currentAdminId');

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        unreadCount.value = 0;
        unreadCountByType.value = {};
        return;
      }

      final data = await _notificationService.getUnreadCount();

      // CRITICAL FIX: Calculate unread count based on visible notifications only
      // (exclude cleared notifications for this admin)
      final prefs = await SharedPreferences.getInstance();
      final clearedIdsJson = prefs.getStringList(_clearedNotificationsKey) ?? [];
      final clearedIds = Set<String>.from(clearedIdsJson);

      // Get actual unread count from API
      final apiUnreadCount = data['unread_count'] ?? 0;

      // If we have notifications loaded, calculate based on visible ones
      if (notifications.isNotEmpty) {
        final visibleUnreadCount = notifications.where((n) => !n.isRead).length;
        unreadCount.value = visibleUnreadCount;
      } else {
        unreadCount.value = apiUnreadCount;
      }

      unreadCountByType.value = Map<String, int>.from(data['by_type'] ?? {});
      print('🔔 Unread count loaded for admin $_currentAdminId: $unreadCount');
    } catch (e) {
      print('❌ Error loading unread count: $e');
      unreadCount.value = 0;
      unreadCountByType.value = {};
    }
  }

  void _filterNotifications() {
    print('🔔 Filtering notifications for tab: ${selectedTab.value}');
    switch (selectedTab.value) {
      case 0: // All
        filteredNotifications.value = notifications;
        break;
      case 1: // Unread
        filteredNotifications.value = notifications.where((n) => !n.isRead).toList();
        break;
      case 2: // Read
        filteredNotifications.value = notifications.where((n) => n.isRead).toList();
        break;
    }
    print('🔔 Filtered to ${filteredNotifications.length} notifications');
  }

  void changeTab(int index) {
    print('🔔 Changing tab to: $index');
    selectedTab.value = index;
    _filterNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      print('🔔 Marking notification $notificationId as read');

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _notificationService.markAsRead(notificationId);

      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        await loadUnreadCount();
        _filterNotifications();
        print('✅ Notification marked as read successfully');
      }
    } catch (e) {
      print('❌ Error marking as read: $e');

      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          'Failed to mark as read: ${e.toString().replaceAll("Exception: ", "")}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
      }
    }
  }

  Future<void> markAllAsRead() async {
    try {
      print('🔔 Marking all notifications as read');

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _notificationService.markAllAsRead();

      // Update all notifications to read
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = notifications[i].copyWith(isRead: true);
        }
      }

      await loadUnreadCount();
      _filterNotifications();

      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      print('✅ All notifications marked as read successfully');
    } catch (e) {
      print('❌ Error marking all as read: $e');

      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          'Failed to mark all as read: ${e.toString().replaceAll("Exception: ", "")}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
      }
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      print('🔔 Deleting notification: $notificationId for admin: $_currentAdminId');

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _notificationService.deleteNotification(notificationId);

      // CRITICAL FIX: Add to admin-specific cleared notifications list
      final prefs = await SharedPreferences.getInstance();
      final clearedIds = prefs.getStringList(_clearedNotificationsKey) ?? [];
      if (!clearedIds.contains(notificationId)) {
        clearedIds.add(notificationId);
        await prefs.setStringList(_clearedNotificationsKey, clearedIds);
        print('🔔 Added notification $notificationId to cleared list for admin $_currentAdminId');
      }

      notifications.removeWhere((n) => n.id == notificationId);
      await loadUnreadCount();
      _filterNotifications();

      Get.snackbar(
        'Success',
        'Notification deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      print('✅ Notification deleted successfully');
    } catch (e) {
      print('❌ Error deleting notification: $e');

      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          'Failed to delete notification: ${e.toString().replaceAll("Exception: ", "")}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
      }
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      print('🔔 Clearing all notifications from device for admin: $_currentAdminId');

      // Get all current notification IDs
      final currentIds = notifications.map((n) => n.id).toList();
      print('🔔 Current notification IDs to clear: $currentIds');

      // CRITICAL FIX: Store all current IDs in admin-specific cleared notifications list
      final prefs = await SharedPreferences.getInstance();
      final clearedIds = prefs.getStringList(_clearedNotificationsKey) ?? [];
      clearedIds.addAll(currentIds);

      // Remove duplicates and save
      final uniqueClearedIds = clearedIds.toSet().toList();
      await prefs.setStringList(_clearedNotificationsKey, uniqueClearedIds);

      // Store clear timestamp for this admin
      await prefs.setInt(_lastClearAllKey, DateTime.now().millisecondsSinceEpoch);

      print('🔔 Saved ${uniqueClearedIds.length} cleared notification IDs for admin $_currentAdminId');

      // Clear ALL notifications from local state
      notifications.clear();
      await loadUnreadCount();
      _filterNotifications();

      Get.snackbar(
        'Success',
        'All notifications cleared from device',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      print('✅ All notifications cleared from device successfully for admin $_currentAdminId');
    } catch (e) {
      print('❌ Error clearing all notifications: $e');

      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          'Failed to clear all notifications: ${e.toString().replaceAll("Exception: ", "")}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
      }
    }
  }

  Future<void> refreshNotifications() async {
    print('🔔 Refreshing notifications for admin: $_currentAdminId');
    await loadNotifications();
    await loadUnreadCount();
  }

  // Get only unread notifications (for new notifications)
  List<AppNotification> get unreadNotifications {
    return notifications.where((n) => !n.isRead).toList();
  }

  // Check if there are any notifications
  bool get hasNotifications => notifications.isNotEmpty;

  // Get notification count by type
  int getNotificationCountByType(NotificationType type) {
    return notifications.where((n) => n.type == type).length;
  }

  // CRITICAL FIX: Clear only current admin's stored data
  Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clearedNotificationsKey);
    await prefs.remove(_lastClearAllKey);
    print('🔔 Cleared stored notification data for admin: $_currentAdminId');
  }

  // CRITICAL FIX: Clear all data when logging out
  Future<void> clearAllDataOnLogout() async {
    print('🔔 Clearing all notification data on logout');
    notifications.clear();
    filteredNotifications.clear();
    unreadCount.value = 0;
    unreadCountByType.value = {};
    _hasLoaded = false;
    _isFirstLoad = true;
  }

  // Check if notifications have been loaded
  bool get hasLoaded => _hasLoaded;
}