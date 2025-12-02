import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../controllers/delivery_controller.dart';
import '../../models/delivery_man.dart';
import '../../widgets/sidebar_menu.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final DeliveryController deliveryController = Get.find<DeliveryController>(); // CHANGED: Get.find instead of Get.put
  final searchController = TextEditingController();
  bool _isInitialized = false; // ADDED: Track initialization

  @override
  void initState() {
    super.initState();
    // ADDED: Load delivery men when screen initializes if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (deliveryController.deliveryMen.isEmpty &&
          !deliveryController.isLoading.value) {
        deliveryController.loadDeliveryMen();
      }
      _isInitialized = true;
    });
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
        title: const Text('Delivery Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => deliveryController.loadDeliveryMen(),
          ),
        ],
      ),
      drawer: const SidebarMenu(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          deliveryController.clearSelectedDeliveryMan();
          Get.toNamed(AppRoutes.deliveryForm);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: searchController,
                        label: 'Search Delivery Personnel',
                        hint: 'Search by name, phone, or vehicle',
                        prefixIcon: const Icon(Icons.search),
                        onChanged: (value) => deliveryController.searchDeliveryMen(value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Statistics
                Obx(() {
                  final counts = deliveryController.getStatusCounts();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatChip(
                        'Total',
                        counts['total'] ?? 0,
                        AppColors.primary,
                      ),
                      _buildStatChip(
                        'Available',
                        counts['available'] ?? 0,
                        AppColors.success,
                      ),
                      _buildStatChip(
                        'Busy',
                        counts['busy'] ?? 0,
                        AppColors.warning,
                      ),
                      _buildStatChip(
                        'Offline',
                        counts['offline'] ?? 0,
                        AppColors.grey,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          // Status Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                children: [
                  _buildFilterChip(
                    'All',
                    'all',
                    deliveryController.selectedStatus.value == 'all',
                        () => deliveryController.filterByStatus('all'),
                  ),
                  _buildFilterChip(
                    'Available',
                    'available',
                    deliveryController.selectedStatus.value == 'available',
                        () => deliveryController.filterByStatus('available'),
                  ),
                  _buildFilterChip(
                    'Busy',
                    'busy',
                    deliveryController.selectedStatus.value == 'busy',
                        () => deliveryController.filterByStatus('busy'),
                  ),
                  _buildFilterChip(
                    'Offline',
                    'offline',
                    deliveryController.selectedStatus.value == 'offline',
                        () => deliveryController.filterByStatus('offline'),
                  ),
                ],
              )),
            ),
          ),

          // Delivery Men List
          Expanded(
            child: Obx(() {
              // CHANGED: Show loading only if we're actively loading and no delivery men exist
              if (deliveryController.isLoading.value &&
                  deliveryController.deliveryMen.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // CHANGED: Show empty state only after initialization and no delivery men
              if (deliveryController.filteredDeliveryMen.isEmpty && _isInitialized) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        deliveryController.searchQuery.value.isNotEmpty
                            ? 'No delivery personnel found matching your search'
                            : 'No delivery personnel found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (deliveryController.searchQuery.value.isEmpty)
                        Text(
                          'Add your first delivery person to get started',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: deliveryController.filteredDeliveryMen.length,
                itemBuilder: (context, index) {
                  final deliveryMan = deliveryController.filteredDeliveryMen[index];
                  return _buildDeliveryManCard(deliveryMan, context);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryManCard(DeliveryMan deliveryMan, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Man Image/Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withOpacity(0.1),
                image: deliveryMan.profileImage != null
                    ? DecorationImage(
                  image: NetworkImage(deliveryMan.profileImage!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: deliveryMan.profileImage == null
                  ? Icon(
                Icons.person,
                color: AppColors.primary,
                size: 24,
              )
                  : null,
            ),
            const SizedBox(width: 12),

            // Delivery Man Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deliveryMan.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: deliveryMan.isActive ? 'Active' : 'Inactive',
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: deliveryMan.isActive ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.email, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          deliveryMan.email,
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Phone - FIXED: Single line with ellipsis
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          deliveryMan.phone,
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Vehicle Information - FIXED: Better layout for long text
                  Row(
                    children: [
                      const Icon(Icons.directions_car, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${deliveryMan.vehicleType} - ${deliveryMan.vehicleNumber}',
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Rating and Deliveries - FIXED: Better spacing
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        deliveryMan.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.local_shipping, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${deliveryMan.totalDeliveries} deliveries',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: deliveryMan.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      deliveryMan.statusDisplay,
                      style: TextStyle(
                        color: deliveryMan.statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Button
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 20),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.accent, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                  onTap: () {
                    deliveryController.selectDeliveryMan(deliveryMan);
                    Future.delayed(
                      Duration.zero,
                          () => Get.toNamed(AppRoutes.deliveryForm),
                    );
                  },
                ),
                if (deliveryMan.isActive) ...[
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 18),
                        SizedBox(width: 8),
                        Text('Set Available'),
                      ],
                    ),
                    onTap: () {
                      deliveryController.updateDeliveryManStatus(deliveryMan.id, 'available');
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.power_settings_new, color: AppColors.warning, size: 18),
                        SizedBox(width: 8),
                        Text('Set Busy'),
                      ],
                    ),
                    onTap: () {
                      deliveryController.updateDeliveryManStatus(deliveryMan.id, 'busy');
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.offline_bolt, color: AppColors.grey, size: 18),
                        SizedBox(width: 8),
                        Text('Set Offline'),
                      ],
                    ),
                    onTap: () {
                      deliveryController.updateDeliveryManStatus(deliveryMan.id, 'offline');
                    },
                  ),
                ],
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(
                        deliveryMan.isActive ? Icons.block : Icons.check_circle,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(deliveryMan.isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                  onTap: () {
                    deliveryController.toggleDeliveryManStatus(deliveryMan.id, !deliveryMan.isActive);
                  },
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error, size: 18),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(
                      Duration.zero,
                          () => _showDeleteDialog(deliveryMan.id),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for info rows
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper method for stat items
  Widget _buildStatItem(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 90, // Add maximum width constraint
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Reduced horizontal padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // Center content
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4), // Reduced spacing
          Flexible(
            child: Text(
              '$label: $count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11, // Slightly smaller font
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
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

  void _showDeleteDialog(String deliveryManId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Delivery Person'),
        content: const Text(
          'Are you sure you want to delete this delivery person? This action cannot be undone.',
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
              deliveryController.deleteDeliveryMan(deliveryManId);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}