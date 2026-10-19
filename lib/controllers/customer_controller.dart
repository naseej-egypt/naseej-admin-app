import '../utils/reactive.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../utils/api_helper.dart';
import '../config/app_colors.dart';

class CustomerController extends GetxController {
  final CustomerService _customerService = CustomerService();

  final customers = <Customer>[].obs;
  final filteredCustomers = <Customer>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  Customer? selectedCustomer;

  // Track first load
  bool _isFirstLoad = true;
  bool _hasLoaded = false;

  @override
  void onInit() {
    super.onInit();
    // Don't load customers immediately - wait until we're authenticated
  }

  Future<void> loadCustomers() async {
    try {
      // Only show loading if we don't have any customers
      if (customers.isEmpty) {
        isLoading.value = true;
      }

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      final data = await _customerService.getCustomers();
      customers.value = data;
      filteredCustomers.value = data;
      _isFirstLoad = false;
      _hasLoaded = true;
    } catch (e) {
      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        print('Customer load error (first load): $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCustomer(String customerId) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      selectedCustomer = await _customerService.getCustomer(customerId);
    } catch (e) {
      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void searchCustomers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredCustomers.value = customers;
    } else {
      // Use backend search for better performance
      _performBackendSearch(query);
    }
  }

  void _performBackendSearch(String query) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      final results = await _customerService.searchCustomers(query);
      filteredCustomers.value = results;
    } catch (e) {
      // Fallback to local search if backend fails
      filteredCustomers.value = customers
          .where((customer) =>
      customer.name.toLowerCase().contains(query.toLowerCase()) ||
          customer.email.toLowerCase().contains(query.toLowerCase()) ||
          customer.phone.contains(query))
          .toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _customerService.updateCustomer(customer);
      await loadCustomers();

      Get.snackbar(
        'Success',
        'Customer updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleCustomerStatus(String customerId, bool isActive) async {
    try {
      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _customerService.toggleCustomerStatus(customerId, isActive);
      await loadCustomers();

      Get.snackbar(
        'Success',
        'Customer status updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _customerService.deleteCustomer(customerId);
      await loadCustomers();

      Get.snackbar(
        'Success',
        'Customer deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Customer>> getTopCustomers() async {
    try {
      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        return [];
      }

      return await _customerService.getTopCustomers();
    } catch (e) {
      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          duration: const Duration(seconds: 4),
        );
      }
      return [];
    }
  }

  Future<Map<String, dynamic>> getCustomerStats() async {
    try {
      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        return {
          'total_customers': 0,
          'active_customers': 0,
          'new_customers': 0,
        };
      }

      return await _customerService.getCustomerStats();
    } catch (e) {
      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          duration: const Duration(seconds: 4),
        );
      }
      return {
        'total_customers': 0,
        'active_customers': 0,
        'new_customers': 0,
      };
    }
  }

  // Filter by active status
  void filterByActiveStatus(bool? isActive) {
    if (isActive == null) {
      filteredCustomers.value = customers;
    } else {
      filteredCustomers.value = customers
          .where((customer) => customer.isActive == isActive)
          .toList();
    }
  }

  // Get active customers only
  List<Customer> get activeCustomers {
    return customers.where((customer) => customer.isActive).toList();
  }

  // Get new customers (last 30 days)
  List<Customer> get newCustomers {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return customers
        .where((customer) => customer.createdAt.isAfter(thirtyDaysAgo))
        .toList();
  }

  void selectCustomer(Customer customer) {
    selectedCustomer = customer;
  }

  void clearSelectedCustomer() {
    selectedCustomer = null;
  }

  // Check if customers have been loaded
  bool get hasLoaded => _hasLoaded;
}