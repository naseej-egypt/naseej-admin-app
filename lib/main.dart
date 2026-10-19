import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naseej_admin_app/widgets/internet_checker_widget.dart';
import 'config/app_theme.dart';
import 'config/routes.dart';
import 'core/providers.dart';
import 'utils/app_navigator.dart';
import 'utils/reactive.dart';
import 'controllers/DashboardController.dart';
import 'controllers/notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: const _EagerInitializer(
        child: NaseejAdminApp(),
      ),
    ),
  );
}

/// Eagerly initializes all controller providers on first build.
/// This ensures every controller is registered in the [Get] facade
/// before any screen tries to call [Get.find].
class _EagerInitializer extends ConsumerWidget {
  final Widget child;
  const _EagerInitializer({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force-read every provider so the underlying Get.put() executes once.
    ref.read(authControllerProvider);
    ref.read(profileControllerProvider);
    ref.read(notificationControllerProvider);
    ref.read(productControllerProvider);
    ref.read(categoryControllerProvider);
    ref.read(orderControllerProvider);
    ref.read(customerControllerProvider);
    ref.read(deliveryControllerProvider);
    ref.read(dashboardControllerProvider);
    ref.read(storeControllerProvider);
    ref.read(adminControllerProvider);
    ref.read(routeControllerProvider);

    return child;
  }
}

class NaseejAdminApp extends StatelessWidget {
  const NaseejAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naseej Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: AppNavigator.navigatorKey,
      scaffoldMessengerKey: AppNavigator.messengerKey,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) {
        return InternetCheckerWidget(
          showOnlineMessage: true,
          onConnectionRestored: () {
            _refreshDataOnReconnection();
          },
          child: child ?? const SizedBox.shrink(),
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
      debugPrint('Error refreshing data on reconnection: $e');
    }
  }
}