import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naseej_admin_app/controllers/notification_controller.dart';
import 'package:naseej_admin_app/controllers/profile_controller.dart';
import 'package:naseej_admin_app/utils/internet_checker.dart';
import 'package:naseej_admin_app/widgets/internet_checker_widget.dart';
import 'config/app_theme.dart';
import 'config/routes.dart';
import 'controllers/DashboardController.dart';
import 'controllers/admin_controller.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/customer_controller.dart';
import 'controllers/delivery_controller.dart';
import 'controllers/store_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Service
  Get.put(ApiService(), permanent: true);

  // Initialize Auth Service
  Get.put(AuthService(), permanent: true);

  // Initialize Core Controllers (permanent: true keeps them alive)
  Get.put(AuthController(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  Get.put(NotificationController(), permanent: true);

  // Initialize Feature Controllers - Make them all permanent
  Get.put(ProductController(), permanent: true);
  Get.put(CategoryController(), permanent: true);
  Get.put(OrderController(), permanent: true);
  Get.put(CustomerController(), permanent: true);
  Get.put(DeliveryController(), permanent: true);
  Get.put(DashboardController(), permanent: true);
  Get.put(StoreController(), permanent: true);
  Get.put(AdminController(), permanent: true);


  runApp(const NaseejAdminApp());
}

class NaseejAdminApp extends StatelessWidget {
  const NaseejAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Naseej Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.pages,
      // FIX: Move InternetCheckerWidget INSIDE builder instead of wrapping outside
      builder: (context, child) {
        return InternetCheckerWidget(
          showOnlineMessage: true,
          onConnectionRestored: () {
            _refreshDataOnReconnection();
          },
          child: child!,
        );
      },
    );
  }

  void _refreshDataOnReconnection() {
    // Refresh essential data when internet connection is restored
    try {
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshDashboard();
      }
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().refreshNotifications();
      }
    } catch (e) {
      print('Error refreshing data on reconnection: $e');
    }
  }
}