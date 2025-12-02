import 'dart:convert';
import 'package:get/get.dart';
import '../models/customer.dart';
import '../utils/constants.dart';
import '../utils/api_helper.dart';
import 'api_service.dart';

class CustomerService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Customer>> getCustomers() async {
    try {
      final response = await _apiService.get(AppConstants.customersEndpoint);
      if (response['status'] == 'success' && response['data'] != null) {
        final customersData = response['data']['customers'] as List;
        return customersData.map((json) => Customer.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load customers');
    } catch (e) {
      throw Exception('Failed to load customers: ${e.toString()}');
    }
  }

  Future<Customer?> getCustomer(String id) async {
    try {
      final response = await _apiService.post(
        '/customers/get_by_id.php',
        {'customer_id': id},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return Customer.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load customer: ${e.toString()}');
    }
  }

  Future<List<Customer>> getCustomerOrders(String customerId) async {
    try {
      final response = await _apiService.post(
        '/customers/get_orders.php',
        {'customer_id': customerId},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        // This endpoint returns orders, not customers
        // We'll handle this separately in the order service
        return [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load customer orders: ${e.toString()}');
    }
  }

  Future<List<Customer>> getTopCustomers({int limit = 10}) async {
    try {
      final response = await _apiService.post(
        '/customers/get_top.php',
        {'limit': limit.toString()},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final customersData = response['data']['customers'] as List;
        return customersData.map((json) => Customer.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load top customers: ${e.toString()}');
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      final data = customer.toFormData();
      data['customer_id'] = customer.id;

      final response = await _apiService.post(
        '/customers/update.php',
        data,
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update customer');
      }
    } catch (e) {
      throw Exception('Failed to update customer: ${e.toString()}');
    }
  }

  Future<void> toggleCustomerStatus(String customerId, bool isActive) async {
    try {
      final response = await _apiService.post(
        '/customers/toggle_status.php',
        {
          'customer_id': customerId,
          'is_active': isActive ? 1 : 0,
        },
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update customer status');
      }
    } catch (e) {
      throw Exception('Failed to update customer status: ${e.toString()}');
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      final response = await _apiService.post(
        '/customers/delete.php',
        {'customer_id': customerId},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to delete customer');
      }
    } catch (e) {
      throw Exception('Failed to delete customer: ${e.toString()}');
    }
  }

  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final response = await _apiService.post(
        '/customers/search.php',
        {'query': query},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        final customersData = response['data']['customers'] as List;
        return customersData.map((json) => Customer.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search customers: ${e.toString()}');
    }
  }

  // Get customer statistics for dashboard
  Future<Map<String, dynamic>> getCustomerStats() async {
    try {
      final customers = await getCustomers();
      final totalCustomers = customers.length;
      final activeCustomers = customers.where((c) => c.isActive).length;
      final newCustomers = customers
          .where((c) => c.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30))))
          .length;

      return {
        'total_customers': totalCustomers,
        'active_customers': activeCustomers,
        'new_customers': newCustomers,
      };
    } catch (e) {
      throw Exception('Failed to load customer statistics: ${e.toString()}');
    }
  }
}