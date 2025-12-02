import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../controllers/store_controller.dart';
import '../../models/store.dart';
import '../../widgets/custom_button.dart';

class StoreDetailsScreen extends StatelessWidget {
  const StoreDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storeController = Get.find<StoreController>();
    final store = storeController.selectedStore!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.toNamed(AppRoutes.storeForm);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Header
            _buildStoreHeader(store, context),
            const SizedBox(height: 24),

            // Store Information Card
            _buildInfoCard(store, context),
            const SizedBox(height: 16),

            // Contact Information Card
            _buildContactCard(store, context),
            const SizedBox(height: 16),

            // Operating Hours Card
            _buildHoursCard(store, context),
            const SizedBox(height: 16),

            // Location Card
            _buildLocationCard(store, context),
            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(storeController, store),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader(Store store, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Store Image
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary.withOpacity(0.1),
                image: store.imageUrl != null
                    ? DecorationImage(
                  image: NetworkImage(store.imageUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: store.imageUrl == null
                  ? const Icon(
                Icons.store,
                size: 60,
                color: AppColors.primary,
              )
                  : null,
            ),
            const SizedBox(height: 16),

            // Store Name and Status
            Text(
              store.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: store.isActive
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: store.isActive ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        store.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: store.isActive ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: store.isCurrentlyOpen
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: store.isCurrentlyOpen ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        store.isCurrentlyOpen ? 'Open Now' : 'Closed',
                        style: TextStyle(
                          color: store.isCurrentlyOpen ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Store store, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, 'Created',
                DateFormat('MMM dd, yyyy').format(store.createdAt)),
            if (store.updatedAt != null)
              _buildInfoRow(Icons.update, 'Last Updated',
                  DateFormat('MMM dd, yyyy').format(store.updatedAt!)),
            _buildInfoRow(Icons.person, 'Manager', store.managerName),
            _buildInfoRow(Icons.phone_android, 'Manager Phone', store.managerPhone),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(Store store, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'Address', store.address),
            _buildInfoRow(Icons.phone, 'Phone', store.phone),
            _buildInfoRow(Icons.email, 'Email', store.email),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursCard(Store store, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operating Hours',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.access_time, 'Hours', store.formattedHours),
            _buildInfoRow(Icons.calendar_month, 'Working Days', store.workingDaysFormatted),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    store.isCurrentlyOpen ? Icons.check_circle : Icons.cancel,
                    color: store.isCurrentlyOpen ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      store.isCurrentlyOpen
                          ? 'Currently Open - Accepting orders and customers'
                          : 'Currently Closed - Not accepting orders',
                      style: TextStyle(
                        color: store.isCurrentlyOpen ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(Store store, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            // Map Placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map,
                    size: 50,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Store Location Map',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${store.latitude.toStringAsFixed(4)}, ${store.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.explore, 'Latitude', store.latitude.toStringAsFixed(6)),
            _buildInfoRow(Icons.explore, 'Longitude', store.longitude.toStringAsFixed(6)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(StoreController controller, Store store) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: store.isActive ? 'Deactivate' : 'Activate',
            isOutlined: true,
            onPressed: () {
              controller.toggleStoreStatus(store.id, !store.isActive);
              Get.back();
            },
            backgroundColor: store.isActive ? AppColors.error : AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'Edit Store',
            onPressed: () {
              Get.toNamed(AppRoutes.storeForm);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}