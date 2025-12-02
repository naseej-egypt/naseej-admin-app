import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../../controllers/order_controller.dart';
import '../../models/order.dart';
import '../../controllers/delivery_controller.dart';
import '../../widgets/custom_button.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late final OrderController orderController;
  late final DeliveryController deliveryController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    orderController = Get.find<OrderController>();
    deliveryController = Get.find<DeliveryController>();

    // Load delivery men when screen opens
    deliveryController.loadDeliveryMen();
  }

  Future<void> _refreshOrder() async {
    final order = orderController.selectedOrder;
    if (order != null) {
      setState(() {
        _isRefreshing = true;
      });

      try {
        await orderController.loadOrder(order.id);
        // Also refresh the orders list to get any updates
        await orderController.loadOrders();
      } catch (e) {
        print('Error refreshing order: $e');
        Get.snackbar(
          'Error',
          'Failed to refresh order: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = orderController.selectedOrder;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
        ),
        body: const Center(
          child: Text('No order selected'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.orderNumber}'),
        actions: [
          // Refresh button with loading indicator
          _isRefreshing
              ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshOrder,
            tooltip: 'Refresh Order',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrder,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Status',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: order.status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.update),
                        ),
                        items: [
                          'pending',
                          'confirmed',
                          'processing',
                          'shipped',
                          'delivered',
                          'cancelled'
                        ].map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(_capitalize(status)),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            orderController.updateOrderStatus(order.id, value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Customer Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.person, 'Name', order.customerName),
                      _buildInfoRow(Icons.email, 'Email', order.customerEmail),
                      _buildInfoRow(Icons.phone, 'Phone', order.customerPhone),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Delivery Address
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Address',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        order.deliveryAddress.fullAddress,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Delivery Man Assignment
              if (order.canAssignDelivery)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Assignment',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (order.deliveryManId != null && order.deliveryManName != null) ...[
                          _buildInfoRow(Icons.person, 'Delivery Man', order.deliveryManName!),
                          const SizedBox(height: 12),
                          CustomButton(
                            text: 'Change Delivery Man',
                            isOutlined: true,
                            onPressed: () => _showDeliveryManSelector(context, order.id),
                          ),
                        ] else ...[
                          const Text(
                            'No delivery man assigned',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            text: 'Assign Delivery Man',
                            onPressed: () => _showDeliveryManSelector(context, order.id),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Order Items - FIXED VERSION
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Order Items',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${order.items.length} items',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Show actual items or empty state
                      if (order.items.isEmpty) ...[
                        Center(
                          child: Column(
                            children: [
                              const Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.grey),
                              const SizedBox(height: 8),
                              const Text(
                                'No items found in this order',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'API shows ${order.itemCount} items but parsing failed',
                                style: const TextStyle(color: AppColors.error, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Column(
                          children: order.items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return _buildOrderItem(item, index, order.items.length);
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
                      _buildSummaryRow('Tax', '\$${order.tax.toStringAsFixed(2)}'),
                      _buildSummaryRow('Delivery Fee', '\$${order.deliveryFee.toStringAsFixed(2)}'),
                      const Divider(),
                      _buildSummaryRow(
                        'Total',
                        '\$${order.total.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Payment Method', _capitalize(order.paymentMethod)),
                      _buildSummaryRow('Payment Status', order.paymentStatusDisplay),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order Dates
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Order Date',
                        DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt),
                      ),
                      if (order.updatedAt != null)
                        _buildInfoRow(
                          Icons.update,
                          'Last Updated',
                          DateFormat('MMM dd, yyyy HH:mm').format(order.updatedAt!),
                        ),
                      if (order.deliveredAt != null)
                        _buildInfoRow(
                          Icons.check_circle,
                          'Delivered Date',
                          DateFormat('MMM dd, yyyy HH:mm').format(order.deliveredAt!),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              if (order.canCancel)
                CustomButton(
                  text: 'Cancel Order',
                  backgroundColor: AppColors.error,
                  onPressed: () => _showCancelDialog(context, order.id, orderController),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, int index, int totalItems) {
    return Container(
      margin: EdgeInsets.only(bottom: index == totalItems - 1 ? 0 : 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: _buildProductImage(item),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName.isNotEmpty ? item.productName : 'Unnamed Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildDetailChip('Qty: ${item.quantity}'),
                    _buildDetailChip('\$${item.price.toStringAsFixed(2)} each'),
                  ],
                ),

                const SizedBox(height: 6),

                // Product ID for debugging
                if (item.productId.isNotEmpty)
                  Text(
                    'Product ID: ${item.productId}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Total Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(OrderItem item) {
    if (item.productImage != null && item.productImage!.isNotEmpty) {
      print('Loading product image: ${item.productImage}'); // Debug log

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: item.productImage!,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          placeholder: (context, url) => Container(
            width: 60,
            height: 60,
            color: AppColors.lightGrey,
            child: const Icon(Icons.image, color: AppColors.grey, size: 24),
          ),
          errorWidget: (context, url, error) {
            print('Error loading image: $error'); // Debug log
            return Container(
              width: 60,
              height: 60,
              color: AppColors.lightGrey,
              child: const Icon(Icons.broken_image, color: AppColors.grey, size: 24),
            );
          },
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        color: AppColors.lightGrey,
        child: const Icon(Icons.shopping_bag, color: AppColors.grey, size: 24),
      );
    }
  }

  Widget _buildDetailChip(String text) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        )
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showDeliveryManSelector(BuildContext context, String orderId) async {
    final deliveryMen = await deliveryController.getAvailableDeliveryMen();
    print('Available delivery men: $deliveryMen');

    if (deliveryMen.isEmpty) {
      Get.snackbar(
        'Info',
        'No available delivery personnel at the moment',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Select Delivery Person'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: deliveryMen.length,
            itemBuilder: (context, index) {
              final dm = deliveryMen[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      dm.name[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                  title: Text(dm.name),
                  subtitle: Text('${dm.vehicleType} - ${dm.vehicleNumber}'),
                  trailing: Text('⭐ ${dm.rating.toStringAsFixed(1)}'),
                  onTap: () {
                    print('Selected delivery man: ${dm.name} (ID: ${dm.id})');
                    orderController.assignDeliveryMan(
                      orderId,
                      dm.id,
                    );
                    Get.back();
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String orderId, OrderController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              controller.cancelOrder(orderId);
              Get.back();
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}