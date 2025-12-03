import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Naseej Admin';
  static const String appVersion = '1.0.0';

  // ⭐ DISABLE MOCK MODE - Use real backend
  static const bool useMockData = false;

  // API Configuration - YOUR HOSTING URL
  static const String baseUrl = '';
  static const String apiVersion = '';
  static const String apiBaseUrl = '$baseUrl$apiVersion';

  // API Endpoints
  static const String loginEndpoint = '/auth/login.php';
  static const String logoutEndpoint = '/auth/logout.php';
  static const String validateSessionEndpoint = '/auth/validate_session.php';
  static const String changePasswordEndpoint = '/auth/change_password.php';

  static const String productsEndpoint = '/products/get_all.php';
  static const String productByIdEndpoint = '/products/get_by_id.php';

  static const String categoriesEndpoint = '/categories/get_all.php';
  static const String ordersEndpoint = '/orders/get_all.php';
  static const String customersEndpoint = '/customers/get_all.php';
  static const String deliveryMenEndpoint = '/delivery/get_all.php';
  static const String storesEndpoint = '/stores/get_all.php';
  static const String notificationsEndpoint = '/notifications/get_all.php';
  static const String dashboardEndpoint = '/dashboard/stats.php';
  static const String uploadEndpoint = '/upload.php';

  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderProcessing = 'processing';
  static const String orderShipped = 'shipped';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // Add these to your AppConstants class:
  static const String notificationsGetAll = '/notifications/get_all.php';
  static const String notificationsMarkRead = '/notifications/mark_read.php';
  static const String notificationsMarkAllRead = '/notifications/mark_all_read.php';
  static const String notificationsDelete = '/notifications/delete.php';
  static const String notificationsClearAll = '/notifications/clear_all.php';
  static const String notificationsUnreadCount = '/notifications/get_unread_count.php';

  static List<String> get orderStatuses => [
    orderPending,
    orderConfirmed,
    orderProcessing,
    orderShipped,
    orderDelivered,
    orderCancelled,
  ];

  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentPaid = 'paid';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';

  // Delivery Status
  static const String deliveryAvailable = 'available';
  static const String deliveryBusy = 'busy';
  static const String deliveryOffline = 'offline';

  // Store Status
  static const String storeActive = 'active';
  static const String storeInactive = 'inactive';
  static const String storeOpen = 'open';
  static const String storeClosed = 'closed';

  // Store Working Days
  static const List<String> defaultWorkingDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  // Store Operating Hours
  static const TimeOfDay defaultOpeningTime = TimeOfDay(hour: 9, minute: 0);
  static const TimeOfDay defaultClosingTime = TimeOfDay(hour: 22, minute: 0);

  // Notification Types
  static const String notificationOrder = 'order';
  static const String notificationSystem = 'system';
  static const String notificationPromotion = 'promotion';
  static const String notificationDelivery = 'delivery';

  // Pagination
  static const int itemsPerPage = 20;
  static const int storesPerPage = 10;
  static const int notificationsPerPage = 15;

  // Image
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Validation
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxDescriptionLength = 1000;

  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String unknownError = 'An unknown error occurred.';
  static const String authError = 'Authentication failed.';
  static const String serverError = 'Server error. Please try again later.';

  // Timeouts
  static const int apiTimeoutSeconds = 30;

  // Add to AppConstants class
  static const String adminsEndpoint = '/admin/get_all.php';
  static const String addAdminEndpoint = '/admin/add.php';
  static const String updateAdminEndpoint = '/admin/update.php';
  static const String deleteAdminEndpoint = '/admin/delete.php';
  static const String changeAdminPasswordEndpoint = '/admin/change_admin_password.php';

// Admin Roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';

  static List<String> get adminRoles => [roleAdmin, roleManager];

}
