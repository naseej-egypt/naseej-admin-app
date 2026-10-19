import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/reactive.dart';
import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../controllers/store_controller.dart';
import '../../models/store.dart';
import '../../widgets/sidebar_menu.dart';
import '../../widgets/custom_text_field.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final StoreController storeController = Get.find<StoreController>(); // FIX: Use Get.find instead of Get.put
  final searchController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load stores when screen initializes if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (storeController.stores.isEmpty &&
          !storeController.isLoading.value) {
        storeController.loadStores();
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
        title: const Text('Store Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => storeController.loadStores(),
          ),
        ],
      ),
      drawer: const SidebarMenu(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          storeController.clearSelectedStore();
          Get.toNamed(AppRoutes.storeForm);
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
                        label: 'Search Stores',
                        hint: 'Search by name, address, or manager',
                        prefixIcon: const Icon(Icons.search),
                        onChanged: (value) => storeController.searchStores(value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list),
                      onSelected: (value) => storeController.filterByStatus(value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'all',
                          child: Text('All Stores'),
                        ),
                        const PopupMenuItem(
                          value: 'active',
                          child: Text('Active Only'),
                        ),
                        const PopupMenuItem(
                          value: 'inactive',
                          child: Text('Inactive Only'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Statistics
                Obx(() {
                  final counts = storeController.getStatusCounts();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatChip(
                        'Total',
                        counts['total'] ?? 0,
                        AppColors.primary,
                      ),
                      _buildStatChip(
                        'Active',
                        counts['active'] ?? 0,
                        AppColors.success,
                      ),
                      _buildStatChip(
                        'Inactive',
                        counts['inactive'] ?? 0,
                        AppColors.grey,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          // Stores List
          Expanded(
            child: Obx(() {
              // Show loading only if we're actively loading and no stores exist
              if (storeController.isLoading.value &&
                  storeController.stores.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show empty state only after initialization and no stores
              if (storeController.filteredStores.isEmpty && _isInitialized) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store_mall_directory,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        storeController.searchQuery.value.isNotEmpty
                            ? 'No stores found matching your search'
                            : 'No stores found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (storeController.searchQuery.value.isEmpty)
                        Text(
                          'Add your first store to get started',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: storeController.filteredStores.length,
                itemBuilder: (context, index) {
                  final store = storeController.filteredStores[index];
                  return _buildStoreCard(store, context);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(Store store, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Image/Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primary.withOpacity(0.1),
                image: store.imageUrl != null
                    ? DecorationImage(
                  image: NetworkImage(store.imageUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: store.imageUrl == null
                  ? Icon(
                Icons.store,
                color: AppColors.primary,
                size: 24,
              )
                  : null,
            ),
            const SizedBox(width: 12),

            // Store Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
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
                        message: store.isActive ? 'Active Store' : 'Inactive Store',
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: store.isActive ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          store.address,
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Manager
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        store.managerName,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Operating Hours and Status
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          store.formattedHours,
                          style: TextStyle(
                            fontSize: 13,
                            color: store.isCurrentlyOpen ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: store.isCurrentlyOpen ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          store.isCurrentlyOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 10,
                            color: store.isCurrentlyOpen ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
                      Icon(Icons.visibility, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                  onTap: () {
                    storeController.selectStore(store);
                    Future.delayed(
                      Duration.zero,
                          () => Get.toNamed(AppRoutes.storeDetails),
                    );
                  },
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.accent, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                  onTap: () {
                    storeController.selectStore(store);
                    Future.delayed(
                      Duration.zero,
                          () => Get.toNamed(AppRoutes.storeForm),
                    );
                  },
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(
                        store.isActive ? Icons.block : Icons.check_circle,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(store.isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                  onTap: () {
                    storeController.toggleStoreStatus(
                      store.id,
                      !store.isActive,
                    );
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
                          () => _showDeleteDialog(store.id),
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

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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

  void _showDeleteDialog(String storeId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Store'),
        content: const Text(
          'Are you sure you want to delete this store? This action cannot be undone.',
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
              storeController.deleteStore(storeId);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}