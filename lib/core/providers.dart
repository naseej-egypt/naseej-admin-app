import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/customer_controller.dart';
import '../controllers/delivery_controller.dart';
import '../controllers/DashboardController.dart';
import '../controllers/store_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/route_controller.dart';
import '../utils/reactive.dart';

// ── Services ─────────────────────────────────────────────────────────────────
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Controllers ──────────────────────────────────────────────────────────────
// Each provider creates the controller and registers it with the Get facade
// so that controllers can cross-reference each other (e.g., AuthController
// accessing ProfileController via Get.find).

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return Get.put(AuthController(), permanent: true);
});

final profileControllerProvider = ChangeNotifierProvider<ProfileController>((ref) {
  return Get.put(ProfileController(), permanent: true);
});

final notificationControllerProvider = ChangeNotifierProvider<NotificationController>((ref) {
  return Get.put(NotificationController(), permanent: true);
});

final productControllerProvider = ChangeNotifierProvider<ProductController>((ref) {
  return Get.put(ProductController(), permanent: true);
});

final categoryControllerProvider = ChangeNotifierProvider<CategoryController>((ref) {
  return Get.put(CategoryController(), permanent: true);
});

final orderControllerProvider = ChangeNotifierProvider<OrderController>((ref) {
  return Get.put(OrderController(), permanent: true);
});

final customerControllerProvider = ChangeNotifierProvider<CustomerController>((ref) {
  return Get.put(CustomerController(), permanent: true);
});

final deliveryControllerProvider = ChangeNotifierProvider<DeliveryController>((ref) {
  return Get.put(DeliveryController(), permanent: true);
});

final dashboardControllerProvider = ChangeNotifierProvider<DashboardController>((ref) {
  return Get.put(DashboardController(), permanent: true);
});

final storeControllerProvider = ChangeNotifierProvider<StoreController>((ref) {
  return Get.put(StoreController(), permanent: true);
});

final adminControllerProvider = ChangeNotifierProvider<AdminController>((ref) {
  return Get.put(AdminController(), permanent: true);
});

final routeControllerProvider = ChangeNotifierProvider<RouteController>((ref) {
  return Get.put(RouteController(), permanent: true);
});

// ── Concise Aliases ──────────────────────────────────────────────────────────
final authProvider = authControllerProvider;
final profileProvider = profileControllerProvider;
final notificationProvider = notificationControllerProvider;
final productProvider = productControllerProvider;
final categoryProvider = categoryControllerProvider;
final orderProvider = orderControllerProvider;
final customerProvider = customerControllerProvider;
final deliveryProvider = deliveryControllerProvider;
final dashboardProvider = dashboardControllerProvider;
final storeProvider = storeControllerProvider;
final adminProvider = adminControllerProvider;
final routeProvider = routeControllerProvider;
