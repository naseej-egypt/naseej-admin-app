import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/reactive.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../controllers/order_controller.dart';
import '../../models/order.dart';
import '../../widgets/sidebar_menu.dart';
import '../../widgets/custom_text_field.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final orderController = Get.put(OrderController());
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load orders when screen initializes
    orderController.loadOrders();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => orderController.loadOrders(),
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      drawer: const SidebarMenu(),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: CustomTextField(
              controller: searchController,
              label: 'Search Orders',
              hint: 'Search by order number, customer name, or phone',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) => orderController.searchOrders(value),
            ),
          ),

          // Statistics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.lightGrey,
            child: Obx(() {
              final counts = orderController.getStatusCounts();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatChip(
                      'Total',
                      counts['total'] ?? 0,
                      AppColors.primary,
                    ),
                    _buildStatChip(
                      'Pending',
                      counts['pending'] ?? 0,
                      Colors.orange,
                    ),
                    _buildStatChip(
                      'Confirmed',
                      counts['confirmed'] ?? 0,
                      Colors.blue,
                    ),
                    _buildStatChip(
                      'Processing',
                      counts['processing'] ?? 0,
                      Colors.purple,
                    ),
                    _buildStatChip(
                      'Shipped',
                      counts['shipped'] ?? 0,
                      Colors.indigo,
                    ),
                    _buildStatChip(
                      'Delivered',
                      counts['delivered'] ?? 0,
                      AppColors.success,
                    ),
                    _buildStatChip(
                      'Cancelled',
                      counts['cancelled'] ?? 0,
                      AppColors.error,
                    ),
                  ],
                ),
              );
            }),
          ),

          // Status Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                children: [
                  _buildFilterChip(
                    'All',
                    'all',
                    orderController.selectedStatus.value == 'all',
                        () => orderController.filterOrdersByStatus('all'),
                  ),
                  _buildFilterChip(
                    'Pending',
                    'pending',
                    orderController.selectedStatus.value == 'pending',
                        () => orderController.filterOrdersByStatus('pending'),
                  ),
                  _buildFilterChip(
                    'Confirmed',
                    'confirmed',
                    orderController.selectedStatus.value == 'confirmed',
                        () => orderController.filterOrdersByStatus('confirmed'),
                  ),
                  _buildFilterChip(
                    'Processing',
                    'processing',
                    orderController.selectedStatus.value == 'processing',
                        () => orderController.filterOrdersByStatus('processing'),
                  ),
                  _buildFilterChip(
                    'Shipped',
                    'shipped',
                    orderController.selectedStatus.value == 'shipped',
                        () => orderController.filterOrdersByStatus('shipped'),
                  ),
                  _buildFilterChip(
                    'Delivered',
                    'delivered',
                    orderController.selectedStatus.value == 'delivered',
                        () => orderController.filterOrdersByStatus('delivered'),
                  ),
                  _buildFilterChip(
                    'Cancelled',
                    'cancelled',
                    orderController.selectedStatus.value == 'cancelled',
                        () => orderController.filterOrdersByStatus('cancelled'),
                  ),
                ],
              )),
            ),
          ),

          // Orders List
          Expanded(
            child: Obx(() {
              if (orderController.isLoading.value && orderController.orders.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading orders...'),
                    ],
                  ),
                );
              }

              if (orderController.filteredOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No orders found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        searchController.text.isEmpty
                            ? 'No orders available for the selected filter'
                            : 'No orders found for "${searchController.text}"',
                        style: TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => orderController.loadOrders(),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => orderController.loadOrders(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderController.filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = orderController.filteredOrders[index];
                    return _buildOrderCard(order, context);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          orderController.selectOrder(order);
          Get.toNamed(AppRoutes.orderDetails);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Icon with Status
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: order.statusColor.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: order.statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Order Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Number and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Order #${order.orderNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: order.statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.statusDisplay,
                            style: TextStyle(
                              color: order.statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Customer Information
                    _buildInfoRow(Icons.person, order.customerName),
                    _buildInfoRow(Icons.phone, order.customerPhone),
                    _buildInfoRow(Icons.email, order.customerEmail),

                    const SizedBox(height: 8),

                    // Order Summary
                    Row(
                      children: [
                        Icon(Icons.shopping_cart, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${order.itemCount} items',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.attach_money, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '\$${order.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Delivery and Date Information
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt),
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                        if (order.deliveryManName != null) ...[
                          Icon(Icons.delivery_dining, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            order.deliveryManName!,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Payment Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.paymentStatusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Payment: ${order.paymentStatusDisplay}',
                        style: TextStyle(
                          color: order.paymentStatusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // View Details Arrow
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        checkmarkColor: AppColors.white,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}