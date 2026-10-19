import 'package:flutter/material.dart';
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
  static const String productDetails = '/products/details';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    products: (context) => const ProductsScreen(),
    addProduct: (context) => const AddProductScreen(),
    editProduct: (context) => const EditProductScreen(),
    categories: (context) => const CategoriesScreen(),
    categoryForm: (context) => const CategoryFormScreen(),
    orders: (context) => const OrdersScreen(),
    orderDetails: (context) => const OrderDetailsScreen(),
    customers: (context) => const CustomersScreen(),
    customerDetails: (context) => const CustomerDetailsScreen(),
    delivery: (context) => const DeliveryScreen(),
    deliveryForm: (context) => const DeliveryFormScreen(),
    profile: (context) => const ProfileScreen(),
    changePassword: (context) => const ChangePasswordScreen(),
    about: (context) => const AboutScreen(),
    notifications: (context) => const NotificationsScreen(),
    stores: (context) => const StoresScreen(),
    storeForm: (context) => const StoreFormScreen(),
    storeDetails: (context) => const StoreDetailsScreen(),
    admins: (context) => const AdminsScreen(),
    adminDetails: (context) => const AdminDetailsScreen(),
    addAdmin: (context) => const AddAdminScreen(),
    changeAdminPassword: (context) => const ChangeAdminPasswordScreen(),
    productDetails: (context) => const ProductDetailsScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    return null;
  }
}