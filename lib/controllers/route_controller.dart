import '../utils/reactive.dart';

/// Global controller to track current route
/// Put this in: lib/controllers/route_controller.dart
class RouteController extends GetxController {
  final RxString currentRoute = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with current route
    currentRoute.value = Get.currentRoute;

    // Listen to route changes
    ever(currentRoute, (route) {
      print('🔄 Route changed to: $route');
    });
  }

  void updateRoute(String route) {
    currentRoute.value = route;
  }

  bool isCurrentRoute(String route) {
    // Normalize both routes for comparison
    final normalizedCurrent = currentRoute.value.startsWith('/')
        ? currentRoute.value.substring(1)
        : currentRoute.value;
    final normalizedRoute = route.startsWith('/')
        ? route.substring(1)
        : route;

    return normalizedCurrent == normalizedRoute;
  }
}