// In config/routes.dart
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../screens/admin/add_admin_screen.dart';
import '../screens/admin/admin_details_screen.dart';
import '../screens/admin/admins_screen.dart';
import '../screens/admin/change_admin_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/products/ProductDetailsScreen.dart';
import '../screens/products/products_screen.dart';
import '../screens/products/add_product_screen.dart';
import '../screens/products/edit_product_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/categories/category_form_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_details_screen.dart';
import '../screens/customers/customers_screen.dart';
import '../screens/customers/customer_details_screen.dart';
import '../screens/delivery/delivery_screen.dart';
import '../screens/delivery/delivery_form_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/stores/stores_screen.dart';
import '../screens/stores/store_form_screen.dart';
import '../screens/stores/store_details_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String addProduct = '/products/add';
  static const String editProduct = '/products/edit';
  static const String categories = '/categories';
  static const String categoryForm = '/categories/form';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/details';
  static const String customers = '/customers';
  static const String customerDetails = '/customers/details';
  static const String delivery = '/delivery';
  static const String deliveryForm = '/delivery/form';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String about = '/about';
  static const String notifications = '/notifications';

  static const String stores = '/stores';
  static const String storeForm = '/stores/form';
  static const String storeDetails = '/stores/details';

  static const String admins = '/admins';
  static const String adminDetails = '/admin-details';
  static const String addAdmin = '/add-admin';
  static const String changeAdminPassword = '/change-admin-password';
  static const productDetails = '/products/details';

  static List<GetPage> pages = [
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
    ),
    GetPage(
      name: products,
      page: () => const ProductsScreen(),
    ),
    GetPage(
      name: addProduct,
      page: () => const AddProductScreen(),
    ),
    GetPage(
      name: editProduct,
      page: () => const EditProductScreen(),
    ),
    GetPage(
      name: categories,
      page: () => const CategoriesScreen(),
    ),
    GetPage(
      name: categoryForm,
      page: () => const CategoryFormScreen(),
    ),
    GetPage(
      name: orders,
      page: () => const OrdersScreen(),
    ),
    GetPage(
      name: orderDetails,
      page: () => const OrderDetailsScreen(),
    ),
    GetPage(
      name: customers,
      page: () => const CustomersScreen(),
    ),
    GetPage(
      name: customerDetails,
      page: () => const CustomerDetailsScreen(),
    ),
    GetPage(
      name: delivery,
      page: () => const DeliveryScreen(),
    ),
    GetPage(
      name: deliveryForm,
      page: () => const DeliveryFormScreen(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: changePassword,
      page: () => const ChangePasswordScreen(),
    ),
    GetPage(
      name: about,
      page: () => const AboutScreen(),
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
    ),
    GetPage(
      name: stores,
      page: () => const StoresScreen(),
    ),
    GetPage(
      name: storeForm,
      page: () => const StoreFormScreen(),
    ),
    GetPage(
      name: storeDetails,
      page: () => const StoreDetailsScreen(),
    ),

    GetPage(
      name: admins,
      page: () => const AdminsScreen(),
      binding: BindingsBuilder(() {
        Get.put(AdminController());
      }),
    ),
    GetPage(
      name: adminDetails,
      page: () => const AdminDetailsScreen(),
    ),
    GetPage(
      name: addAdmin,
      page: () => const AddAdminScreen(),
    ),
    GetPage(
      name: changeAdminPassword,
      page: () => const ChangeAdminPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.productDetails,
      page: () => const ProductDetailsScreen(),
    ),
  ];
}