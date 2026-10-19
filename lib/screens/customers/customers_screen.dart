import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/reactive.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../controllers/customer_controller.dart';
import '../../widgets/sidebar_menu.dart';
import '../../widgets/custom_text_field.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final customerController = Get.put(CustomerController());
  final searchController = TextEditingController();
  bool? activeFilter;

  @override
  void initState() {
    super.initState();
    // Load customers if not already loaded
    if (customerController.customers.isEmpty) {
      customerController.loadCustomers();
    }
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
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => customerController.loadCustomers(),
          ),
        ],
      ),
      drawer: const SidebarMenu(),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: CustomTextField(
                    controller: searchController,
                    label: 'Search Customers',
                    hint: 'Search by name, email or phone',
                    prefixIcon: const Icon(Icons.search),
                    onChanged: (value) => customerController.searchCustomers(value),
                  ),
                ),
                const SizedBox(width: 16),

                // Filter Button
                PopupMenuButton<bool?>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      activeFilter = value;
                    });
                    customerController.filterByActiveStatus(value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Icons.all_inclusive, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('All Customers'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: true,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          SizedBox(width: 8),
                          Text('Active Only'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: false,
                      child: Row(
                        children: [
                          Icon(Icons.block, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Inactive Only'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Active Filter Chip
          if (activeFilter != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.lightGrey,
              child: Row(
                children: [
                  Text(
                    'Filter: ${activeFilter == true ? 'Active' : 'Inactive'}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        activeFilter = null;
                      });
                      customerController.filterByActiveStatus(null);
                    },
                    child: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),

          // Customers List
          Expanded(
            child: Obx(() {
              if (customerController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (customerController.filteredCustomers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        customerController.searchQuery.value.isNotEmpty || activeFilter != null
                            ? 'No customers found matching your criteria'
                            : 'No customers found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: customerController.filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = customerController.filteredCustomers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: customer.profileImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            customer.profileImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                customer.initials,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        )
                            : Text(
                          customer.initials,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              customer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: customer.isActive
                                  ? AppColors.success.withOpacity(0.2)
                                  : AppColors.error.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              customer.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: customer.isActive
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  customer.email,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                customer.phone,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${customer.totalOrders} orders',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '\$${customer.totalSpent.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          if (customer.lastOrderDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Last order: ${DateFormat('MMM dd, yyyy').format(customer.lastOrderDate!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.visibility, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text('View Details'),
                              ],
                            ),
                            onTap: () {
                              customerController.selectCustomer(customer);
                              Future.delayed(
                                Duration.zero,
                                    () => Get.toNamed(AppRoutes.customerDetails),
                              );
                            },
                          ),
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  customer.isActive
                                      ? Icons.block
                                      : Icons.check_circle,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 8),
                                Text(customer.isActive ? 'Deactivate' : 'Activate'),
                              ],
                            ),
                            onTap: () {
                              customerController.toggleCustomerStatus(
                                customer.id,
                                !customer.isActive,
                              );
                            },
                          ),
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.delete, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                            onTap: () {
                              _showDeleteDialog(customer.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String customerId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text(
          'Are you sure you want to delete this customer? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              customerController.deleteCustomer(customerId);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}