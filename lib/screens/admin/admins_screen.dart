import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../controllers/admin_controller.dart';
import '../../models/admin_user.dart';
import '../../widgets/sidebar_menu.dart';
import '../../widgets/custom_text_field.dart';

class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key});

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  final adminController = Get.put(AdminController());
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (adminController.admins.isEmpty) {
      adminController.loadAdmins();
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
        title: const Text('Admins Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminController.loadAdmins(),
          ),
        ],
      ),
      drawer: const SidebarMenu(),
      // ADDED: Floating Action Button instead of appbar button
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addAdmin),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
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
                    label: 'Search Admins',
                    hint: 'Search by name or email',
                    prefixIcon: const Icon(Icons.search),
                    onChanged: (value) => adminController.searchAdmins(value),
                  ),
                ),
                const SizedBox(width: 16),

                // Role Filter
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) => adminController.filterByRole(value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: '',
                      child: Row(
                        children: [
                          Icon(Icons.all_inclusive, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('All Roles'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'admin',
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Admin'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'manager',
                      child: Row(
                        children: [
                          Icon(Icons.manage_accounts, color: AppColors.accent),
                          SizedBox(width: 8),
                          Text('Manager'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),

                // Status Filter
                PopupMenuButton<String>(
                  icon: const Icon(Icons.toggle_on),
                  onSelected: (value) => adminController.filterByStatus(value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: '',
                      child: Row(
                        children: [
                          Icon(Icons.all_inclusive, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('All Status'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'active',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          SizedBox(width: 8),
                          Text('Active Only'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'inactive',
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

          // Active Filters
          Obx(() {
            final hasFilters = adminController.selectedRole.isNotEmpty ||
                adminController.selectedStatus.isNotEmpty;

            if (!hasFilters) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.lightGrey,
              child: Row(
                children: [
                  const Text('Filters:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  if (adminController.selectedRole.isNotEmpty)
                    _buildFilterChip(
                      'Role: ${adminController.selectedRole.value}',
                      onDelete: () => adminController.filterByRole(null),
                    ),
                  if (adminController.selectedStatus.isNotEmpty)
                    _buildFilterChip(
                      'Status: ${adminController.selectedStatus.value}',
                      onDelete: () => adminController.filterByStatus(null),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: adminController.clearFilters,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            );
          }),

          // Admins List
          Expanded(
            child: Obx(() {
              if (adminController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (adminController.filteredAdmins.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        adminController.searchQuery.value.isNotEmpty ||
                            adminController.selectedRole.isNotEmpty ||
                            adminController.selectedStatus.isNotEmpty
                            ? 'No admins found matching your criteria'
                            : 'No admins found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (adminController.searchQuery.value.isEmpty &&
                          adminController.selectedRole.isEmpty &&
                          adminController.selectedStatus.isEmpty)
                        ElevatedButton(
                          onPressed: () => Get.toNamed(AppRoutes.addAdmin),
                          child: const Text('Add First Admin'),
                        ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: adminController.filteredAdmins.length,
                itemBuilder: (context, index) {
                  final admin = adminController.filteredAdmins[index];
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
                        child: admin.profileImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            admin.profileImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                admin.initials,
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
                          admin.initials,
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
                              admin.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: admin.statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              admin.statusText,
                              style: TextStyle(
                                color: admin.statusColor,
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
                          // FIXED: Better layout for email with ellipsis
                          Row(
                            children: [
                              const Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  admin.email,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // FIXED: Better layout for phone and role
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  admin.phoneNumber ?? 'No phone',
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  admin.roleDisplayName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Joined: ${_formatDate(admin.createdAt)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (admin.lastLogin != null)
                                Expanded(
                                  child: Text(
                                    'Last login: ${_formatDate(admin.lastLogin!)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                            ],
                          ),
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
                              adminController.selectAdmin(admin);
                              Future.delayed(
                                Duration.zero,
                                    () => Get.toNamed(AppRoutes.adminDetails),
                              );
                            },
                          ),
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  admin.isActive ? Icons.block : Icons.check_circle,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 8),
                                Text(admin.isActive ? 'Deactivate' : 'Activate'),
                              ],
                            ),
                            onTap: () {
                              _toggleAdminStatus(admin);
                            },
                          ),
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.lock_reset, color: AppColors.warning),
                                SizedBox(width: 8),
                                Text('Change Password'),
                              ],
                            ),
                            onTap: () {
                              adminController.selectAdmin(admin);
                              Future.delayed(
                                Duration.zero,
                                    () => Get.toNamed(AppRoutes.changeAdminPassword),
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
                              _showDeleteDialog(admin);
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

  Widget _buildFilterChip(String label, {required VoidCallback onDelete}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 14),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _toggleAdminStatus(AdminUser admin) {
    final newStatus = !admin.isActive;
    final action = newStatus ? 'activate' : 'deactivate';

    Get.dialog(
      AlertDialog(
        title: Text('$action Admin'),
        content: Text('Are you sure you want to $action ${admin.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? AppColors.success : AppColors.warning,
            ),
            onPressed: () async {
              Get.back();
              try {
                final updatedAdmin = admin.copyWith(isActive: newStatus);
                await adminController.updateAdmin(updatedAdmin);

                Get.snackbar(
                  'Success',
                  'Admin ${newStatus ? 'activated' : 'deactivated'} successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: AppColors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update admin: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error,
                  colorText: AppColors.white,
                );
              }
            },
            child: Text(action.capitalizeFirst!),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AdminUser admin) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Admin'),
        content: Text(
          'Are you sure you want to delete ${admin.name}? This action cannot be undone.',
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
            onPressed: () async {
              Get.back();
              try {
                await adminController.deleteAdmin(admin.id);

                Get.snackbar(
                  'Success',
                  'Admin deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: AppColors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete admin: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error,
                  colorText: AppColors.white,
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}