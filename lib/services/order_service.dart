import 'package:get/get.dart';
import '../models/order.dart';
import '../utils/api_helper.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Order>> getOrders() async {
    try {
      print('=== OrderService.getOrders() ===');
      // Add get_all parameter to fetch all orders
      final response = await _apiService.post(
        '/orders/get_all.php',
        {'get_all': 'true'}, // This will fetch all orders without pagination
      );

      print('Orders API Response: $response');

      if (response['status'] == 'success') {
        dynamic data = response['data'];

        if (data is Map && data['orders'] is List) {
          final orders = (data['orders'] as List).map((json) => Order.fromJson(json)).toList();
          print('Successfully parsed ${orders.length} orders');
          return orders;
        } else {
          print('Unexpected data format: $data');
          return [];
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to load orders');
      }
    } catch (e) {
      print('Error loading orders: $e');
      throw Exception('Failed to load orders: ${e.toString()}');
    }
  }

  Future<Order?> getOrder(String id) async {
    try {
      print('=== OrderService.getOrder() ===');
      print('Order ID: $id');

      final response = await _apiService.post(
        '/orders/get_by_id.php',
        {'order_id': id},
      );

      print('Get order response status: ${response['status']}');
      print('Get order response data keys: ${response['data']?.keys?.toList()}');

      if (response['status'] == 'success' && response['data'] != null) {
        final orderData = response['data'];
        print('Order data items: ${orderData['items']}');
        print('Order data items count: ${orderData['items']?.length}');
        print('Order data items type: ${orderData['items']?.runtimeType}');

        return Order.fromJson(orderData);
      } else {
        print('Failed to get order: ${response['message']}');
        return null;
      }
    } catch (e) {
      print('Error loading order: $e');
      throw Exception('Failed to load order: ${e.toString()}');
    }
  }

  Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final response = await _apiService.post(
        '/orders/get_by_status.php',
        {'status': status},
      );

      if (response['status'] == 'success') {
        dynamic data = response['data'];

        if (data is Map && data['orders'] is List) {
          return (data['orders'] as List).map((json) => Order.fromJson(json)).toList();
        } else if (data is List) {
          return data.map((json) => Order.fromJson(json)).toList();
        } else {
          return [];
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load orders by status: ${e.toString()}');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      print('=== OrderService.updateOrderStatus() ===');
      print('Order ID: $orderId, Status: $status');

      final response = await _apiService.post(
        '/orders/update_status.php',
        {
          'order_id': orderId,
          'status': status,
        },
      );

      print('Update order status response: $response');

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update order status');
      }
    } catch (e) {
      print('Error in updateOrderStatus: $e');
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  Future<void> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      print('=== OrderService.updatePaymentStatus() ===');
      print('Order ID: $orderId, Payment Status: $paymentStatus');

      final response = await _apiService.post(
        '/orders/update_payment_status.php',
        {
          'order_id': orderId,
          'payment_status': paymentStatus,
        },
      );

      print('Update payment status response: $response');

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update payment status');
      }
    } catch (e) {
      print('Error in updatePaymentStatus: $e');
      throw Exception('Failed to update payment status: ${e.toString()}');
    }
  }

  Future<void> assignDeliveryMan(String orderId, String deliveryManId) async {
    try {
      print('=== OrderService.assignDeliveryMan() ===');
      print('Order ID: $orderId, Delivery Man ID: $deliveryManId');

      final response = await _apiService.post(
        '/orders/assign_delivery.php',
        {
          'order_id': orderId,
          'delivery_man_id': deliveryManId,
        },
      );

      print('Assign delivery man response: $response');

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to assign delivery man');
      }
    } catch (e) {
      print('Error in assignDeliveryMan: $e');
      throw Exception('Failed to assign delivery man: ${e.toString()}');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      print('=== OrderService.cancelOrder() ===');
      print('Order ID: $orderId');

      // Use update_status.php to cancel the order
      final response = await _apiService.post(
        '/orders/update_status.php',
        {
          'order_id': orderId,
          'status': 'cancelled',
        },
      );

      print('Cancel order response: $response');

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      print('Error in cancelOrder: $e');
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }

  Future<List<Order>> searchOrders(String query) async {
    try {
      print('=== OrderService.searchOrders() ===');
      print('Search query: $query');

      final response = await _apiService.post(
        '/orders/search.php',
        {'query': query},
      );

      print('Search response: $response');

      if (response['status'] == 'success') {
        dynamic data = response['data'];

        if (data is Map && data['orders'] is List) {
          final orders = (data['orders'] as List)
              .where((json) => json != null)
              .map((json) => Order.fromJson(json))
              .toList();
          print('Successfully parsed ${orders.length} search results');
          return orders;
        } else {
          print('Unexpected search data format: $data');
          return [];
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to search orders');
      }
    } catch (e) {
      print('Error searching orders: $e');
      throw Exception('Failed to search orders: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      final response = await _apiService.get('/orders/get_pending_count.php');

      if (response['status'] == 'success' && response['data'] != null) {
        return response['data'];
      }

      // Fallback: Calculate from orders list
      final orders = await getOrders();
      final pending = orders.where((o) => o.status == 'pending').length;
      final confirmed = orders.where((o) => o.status == 'confirmed').length;
      final processing = orders.where((o) => o.status == 'processing').length;
      final shipped = orders.where((o) => o.status == 'shipped').length;
      final delivered = orders.where((o) => o.status == 'delivered').length;
      final cancelled = orders.where((o) => o.status == 'cancelled').length;
      final total = orders.length;

      return {
        'pending': pending,
        'confirmed': confirmed,
        'processing': processing,
        'shipped': shipped,
        'delivered': delivered,
        'cancelled': cancelled,
        'total': total,
        'today_orders': orders.where((o) =>
            o.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 1)))
        ).length,
      };
    } catch (e) {
      throw Exception('Failed to load order statistics: ${e.toString()}');
    }
  }

  Future<int> getPendingOrdersCount() async {
    try {
      final stats = await getOrderStatistics();
      return stats['pending'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Order>> getOrdersByCustomer(String customerId) async {
    try {
      final response = await _apiService.post(
        '/orders/get_by_customer.php',
        {'customer_id': customerId},
      );

      if (response['status'] == 'success') {
        dynamic data = response['data'];

        if (data is Map && data['orders'] is List) {
          return (data['orders'] as List).map((json) => Order.fromJson(json)).toList();
        } else {
          return [];
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load customer orders: ${e.toString()}');
    }
  }
}