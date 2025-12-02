import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../utils/api_helper.dart';

class OrderController extends GetxController {
  final OrderService _orderService = OrderService();

  final orders = <Order>[].obs;
  final filteredOrders = <Order>[].obs;
  final isLoading = false.obs;
  final selectedStatus = 'all'.obs;

  Order? selectedOrder;

  // Track first load
  bool _isFirstLoad = true;
  bool _hasLoaded = false;

  @override
  void onInit() {
    super.onInit();
    // Don't load orders immediately - wait until we're authenticated
  }

  Future<void> loadOrders() async {
    try {
      // Only show loading if we don't have any orders
      if (orders.isEmpty) {
        isLoading.value = true;
      }

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      final data = await _orderService.getOrders();
      orders.value = data;
      filterOrdersByStatus(selectedStatus.value);
      _isFirstLoad = false;
      _hasLoaded = true;
      print('Successfully loaded ${orders.length} orders');
    } catch (e) {
      print('Error in loadOrders: $e');

      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          'Failed to load orders: ${e.toString().replaceAll("Exception: ", "")}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      } else {
        print('Order load error (first load): $e');
      }

      // Set empty lists on error
      orders.value = [];
      filteredOrders.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void filterOrdersByStatus(String status) {
    selectedStatus.value = status;
    if (status == 'all') {
      filteredOrders.value = List.from(orders);
    } else {
      filteredOrders.value = orders.where((order) => order.status == status).toList();
    }
    print('Filtered orders by status "$status": ${filteredOrders.length} orders');
  }

  Future<void> loadOrder(String orderId) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      selectedOrder = await _orderService.getOrder(orderId);
      if (selectedOrder != null) {
        print('Successfully loaded order: ${selectedOrder!.orderNumber}');
        print('Order items count: ${selectedOrder!.items.length}');
        if (selectedOrder!.items.isNotEmpty) {
          print('First item: ${selectedOrder!.items.first.productName}');
        }
      } else {
        print('Order not found: $orderId');
      }
    } catch (e) {
      print('Error loading order: $e');

      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          'Failed to load order: ${e.toString().replaceAll("Exception: ", "")}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _orderService.updateOrderStatus(orderId, status);
      await loadOrders();

      // Reload the selected order if it's the one being updated
      if (selectedOrder?.id == orderId) {
        await loadOrder(orderId);
      }

      Get.snackbar(
        'Success',
        'Order status updated to ${_capitalize(status)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('Error updating order status: $e');

      // Improved error messages for better UX
      String errorMessage;
      if (e.toString().contains('Cannot assign delivery person')) {
        errorMessage = 'Please assign a delivery person before marking as shipped/delivered';
      } else if (e.toString().contains('Cannot change status of cancelled orders')) {
        errorMessage = 'Cannot change status of cancelled orders';
      } else if (e.toString().contains('Cannot change status of delivered orders')) {
        errorMessage = 'Cannot change status of delivered orders';
      } else if (e.toString().contains('Cannot mark order as')) {
        errorMessage = 'Please assign a delivery person first';
      } else {
        errorMessage = 'Failed to update order status: ${e.toString().replaceAll("Exception: ", "")}';
      }

      Get.snackbar(
        'Cannot Update Status',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _orderService.updatePaymentStatus(orderId, paymentStatus);
      await loadOrders();

      // Reload the selected order if it's the one being updated
      if (selectedOrder?.id == orderId) {
        await loadOrder(orderId);
      }

      Get.snackbar(
        'Success',
        'Payment status updated to ${_capitalize(paymentStatus)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('Error updating payment status: $e');
      Get.snackbar(
        'Error',
        'Failed to update payment status: ${e.toString().replaceAll("Exception: ", "")}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> assignDeliveryMan(String orderId, String deliveryManId) async {
    try {
      print('=== OrderController.assignDeliveryMan() ===');
      print('Order ID: $orderId');
      print('Delivery Man ID: $deliveryManId');

      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _orderService.assignDeliveryMan(orderId, deliveryManId);
      await loadOrders();

      // Reload the selected order if it's the one being updated
      if (selectedOrder?.id == orderId) {
        await loadOrder(orderId);
      }

      Get.snackbar(
        'Success',
        'Delivery person assigned successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('Error in assignDeliveryMan: $e');
      Get.snackbar(
        'Error',
        'Failed to assign delivery person: ${e.toString().replaceAll("Exception: ", "")}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _orderService.cancelOrder(orderId);
      await loadOrders();

      Get.snackbar(
        'Success',
        'Order cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('Error cancelling order: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel order: ${e.toString().replaceAll("Exception: ", "")}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchOrders(String query) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      if (query.isEmpty) {
        filterOrdersByStatus(selectedStatus.value);
      } else {
        final results = await _orderService.searchOrders(query);
        filteredOrders.value = results;
      }
    } catch (e) {
      print('Error searching orders: $e');
      // Fallback to local search
      filteredOrders.value = orders
          .where((order) =>
      order.orderNumber.toLowerCase().contains(query.toLowerCase()) ||
          order.customerName.toLowerCase().contains(query.toLowerCase()) ||
          order.customerEmail.toLowerCase().contains(query.toLowerCase()) ||
          order.customerPhone.contains(query))
          .toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> getPendingOrdersCount() async {
    try {
      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        return 0;
      }

      return await _orderService.getPendingOrdersCount();
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        return {};
      }

      return await _orderService.getOrderStatistics();
    } catch (e) {
      print('Error getting order statistics: $e');

      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          'Failed to load order statistics',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
      return {};
    }
  }

  void selectOrder(Order order) {
    selectedOrder = order;
    print('Selected order: ${order.orderNumber}');
    print('Order items count: ${order.items.length}');
  }

  void clearSelectedOrder() {
    selectedOrder = null;
  }

  // Statistics
  Map<String, int> getStatusCounts() {
    return {
      'total': orders.length,
      'pending': orders.where((order) => order.status == 'pending').length,
      'confirmed': orders.where((order) => order.status == 'confirmed').length,
      'processing': orders.where((order) => order.status == 'processing').length,
      'shipped': orders.where((order) => order.status == 'shipped').length,
      'delivered': orders.where((order) => order.status == 'delivered').length,
      'cancelled': orders.where((order) => order.status == 'cancelled').length,
    };
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Check if orders have been loaded
  bool get hasLoaded => _hasLoaded;
}