import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../controllers/notification_controller.dart';
import '../../models/notification_model.dart';
import '../../widgets/custom_button.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationController = Get.find<NotificationController>();

    // CRITICAL FIX: Load notifications immediately when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!notificationController.hasLoaded && !notificationController.isLoading.value) {
        print('🚀 Loading notifications immediately for screen...');
        notificationController.loadNotifications();
        notificationController.loadUnreadCount();
      }
    });

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          bottom: TabBar(
            onTap: notificationController.changeTab,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(
                child: Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('All'),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        notificationController.notifications.length.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )),
              ),
              Tab(
                child: Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unread'),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        notificationController.unreadCount.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )),
              ),
              const Tab(text: 'Read'),
            ],
          ),
          actions: [
            // Refresh Button
            Obx(() => IconButton(
              icon: notificationController.isLoading.value
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.refresh),
              tooltip: 'Refresh notifications',
              onPressed: notificationController.isLoading.value
                  ? null
                  : () => notificationController.refreshNotifications(),
            )),
            // Mark All as Read
            Obx(() => notificationController.unreadCount > 0
                ? IconButton(
              icon: const Icon(Icons.mark_email_read),
              tooltip: 'Mark all as read',
              onPressed: () => _showMarkAllAsReadDialog(notificationController),
            )
                : const SizedBox.shrink()),
            // Clear All
            Obx(() => notificationController.notifications.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all',
              onPressed: () => _showClearAllDialog(notificationController),
            )
                : const SizedBox.shrink()),
          ],
        ),
        body: Column(
          children: [
            // Summary Card
            Obx(() => _buildSummaryCard(notificationController)),

            // Loading Indicator
            Obx(() => notificationController.isLoading.value
                ? const LinearProgressIndicator()
                : const SizedBox.shrink()),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                children: [
                  // All Tab
                  _buildNotificationsList(notificationController),
                  // Unread Tab
                  _buildNotificationsList(notificationController),
                  // Read Tab
                  _buildNotificationsList(notificationController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... rest of the methods remain exactly the same ...
  Widget _buildSummaryCard(NotificationController controller) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Unread Count
            Expanded(
              child: Column(
                children: [
                  Text(
                    controller.unreadCount.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    'Unread',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Total Count
            Expanded(
              child: Column(
                children: [
                  Text(
                    controller.notifications.length.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Mark All Read',
                      onPressed: controller.unreadCount > 0
                          ? () => _showMarkAllAsReadDialog(controller)
                          : null,
                      isOutlined: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(NotificationController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.notifications.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredNotifications.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshNotifications(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredNotifications.length,
          itemBuilder: (context, index) {
            final notification = controller.filteredNotifications[index];
            return _buildNotificationItem(notification, controller);
          },
        ),
      );
    });
  }

  Widget _buildNotificationItem(AppNotification notification, NotificationController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? AppColors.white : AppColors.primary.withOpacity(0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: notification.type.color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification.type.icon,
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(notification.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  notification.type.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: notification.type.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            if (!notification.isRead)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.mark_email_read, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Mark as Read'),
                  ],
                ),
                onTap: () => controller.markAsRead(notification.id),
              ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
              onTap: () => _showDeleteDialog(notification, controller),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            controller.markAsRead(notification.id);
          }
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(time);
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    // Handle navigation based on notification type and data
    switch (notification.type) {
      case NotificationType.order:
        if (notification.data != null && notification.data!['order_id'] != null) {
          Get.snackbar(
            'Order Notification',
            'Order ID: ${notification.data!['order_id']}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        break;
      case NotificationType.delivery:
        Get.snackbar(
          'Delivery Update',
          'Delivery status updated',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      default:
      // Show notification details
        Get.snackbar(
          notification.title,
          notification.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }
  }

  void _showMarkAllAsReadDialog(NotificationController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Mark All as Read'),
        content: const Text('Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.markAllAsRead();
            },
            child: const Text('Mark All Read'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(NotificationController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'This will permanently remove all notifications from your device.\n\n'
              'Only new unread notifications will appear after this action.\n\n'
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Get.back();
              controller.clearAllNotifications();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AppNotification notification, NotificationController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Get.back();
              controller.deleteNotification(notification.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}