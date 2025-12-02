import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';
import '../config/routes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({super.key});

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  late AuthController authController;
  late ProfileController profileController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();

    // Find or create the permanent ProfileController
    if (Get.isRegistered<ProfileController>()) {
      profileController = Get.find<ProfileController>();
    } else {
      profileController = Get.put(ProfileController(), permanent: true);
    }

    // CRITICAL FIX: ALWAYS force reload profile when sidebar opens
    print('📂 Sidebar opened - forcing profile reload');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.loadProfile(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header Section with Gradient - UNCHANGED
          Obx(() {
            final profile = profileController.profile.value;
            final isLoading = profileController.isLoading.value;

            // Debug info
            if (profile != null) {
              print('👤 Sidebar showing profile: ${profile.name} (ID: ${profile.id})');
            }

            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Image with Stack
                      GestureDetector(
                        onTap: () {
                          Get.back();
                          Get.toNamed(AppRoutes.profile);
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: isLoading
                                    ? Container(
                                  color: Colors.white.withOpacity(0.2),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                    : (profile?.profileImage != null && profile!.profileImage!.isNotEmpty)
                                    ? Image.network(
                                  profile.profileImage!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar(profile);
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.white.withOpacity(0.2),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                              : null,
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                )
                                    : _buildDefaultAvatar(profile),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // User Name
                      Text(
                        profile?.name ?? (isLoading ? 'Loading...' : 'Admin User'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // User Email
                      Text(
                        profile?.email ?? (isLoading ? 'Loading...' : 'admin@naseej.com'),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          profile?.role.toUpperCase().replaceAll('_', ' ') ?? 'ADMIN',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Menu Items - CHANGED BACKGROUND COLOR
          Expanded(
            child: Container(
              color: AppColors.background, // Warm Beige/Cream background
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    route: AppRoutes.dashboard,
                  ),

                  // Admins menu item (only for super_admin)
                  Obx(() {
                    final currentAdmin = authController.currentAdmin.value ??
                        authController.admin;

                    if (currentAdmin?.role == 'super_admin') {
                      return _buildMenuItem(
                        icon: Icons.admin_panel_settings,
                        title: 'Admins',
                        route: AppRoutes.admins,
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  _buildMenuItem(
                    icon: Icons.inventory_2,
                    title: 'Products',
                    route: AppRoutes.products,
                  ),
                  _buildMenuItem(
                    icon: Icons.category,
                    title: 'Categories',
                    route: AppRoutes.categories,
                  ),
                  _buildMenuItem(
                    icon: Icons.shopping_cart,
                    title: 'Orders',
                    route: AppRoutes.orders,
                  ),
                  _buildMenuItem(
                    icon: Icons.people,
                    title: 'Customers',
                    route: AppRoutes.customers,
                  ),
                  _buildMenuItem(
                    icon: Icons.delivery_dining,
                    title: 'Delivery',
                    route: AppRoutes.delivery,
                  ),
                  _buildMenuItem(
                    icon: Icons.store,
                    title: 'Stores',
                    route: AppRoutes.stores,
                  ),
                  const Divider(),
                  _buildMenuItem(
                    icon: Icons.person,
                    title: 'Profile',
                    route: AppRoutes.profile,
                  ),
                  _buildMenuItem(
                    icon: Icons.info,
                    title: 'About',
                    route: AppRoutes.about,
                  ),
                ],
              ),
            ),
          ),

          // Logout Section - CHANGED BACKGROUND COLOR
          Container(
            color: AppColors.background, // Warm Beige/Cream background
            child: const Column(
              children: [
                Divider(),
                // Logout tile remains here...
              ],
            ),
          ),

          // Logout Tile
          Container(
            color: AppColors.background, // Warm Beige/Cream background
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout'),
              onTap: () {
                Get.back(); // Close drawer
                _showLogoutDialog();
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(profile) {
    return Container(
      color: Colors.transparent,
      child: profile != null
          ? Center(
        child: Text(
          profile.initials,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      )
          : const Icon(
        Icons.person,
        size: 50,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: () {
        Get.back(); // Close drawer
        Get.toNamed(route);
      },
      selected: Get.currentRoute == route,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
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
              Get.back();
              authController.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}