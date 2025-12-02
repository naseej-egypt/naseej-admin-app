import 'package:get/get.dart';
import '../models/admin_user.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'auth_controller.dart';

class AdminController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final admins = <AdminUser>[].obs;
  final filteredAdmins = <AdminUser>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final selectedRole = ''.obs;
  final selectedStatus = ''.obs;

  AdminUser? selectedAdmin;

  @override
  void onInit() {
    super.onInit();
    loadAdmins();
  }

  Future<void> loadAdmins() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _apiService.get(AppConstants.adminsEndpoint);

      if (response['status'] == 'success' && response['data'] != null) {
        final List<dynamic> adminList = response['data']['admins'];

        // FIXED: Filter out super_admin users from the list
        admins.value = adminList
            .map((admin) => AdminUser.fromListJson(admin))
            .where((admin) => admin.role != 'super_admin') // Exclude super_admin
            .toList();

        print('✅ Loaded ${admins.length} admins (excluding super_admin)');

        applyFilters();
      } else {
        throw Exception(response['message'] ?? 'Failed to load admins');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
      print('Load admins error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchAdmins(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void filterByRole(String? role) {
    selectedRole.value = role ?? '';
    applyFilters();
  }

  void filterByStatus(String? status) {
    selectedStatus.value = status ?? '';
    applyFilters();
  }

  void applyFilters() {
    filteredAdmins.value = admins.where((admin) {
      bool matchesSearch = searchQuery.value.isEmpty ||
          admin.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          admin.email.toLowerCase().contains(searchQuery.value.toLowerCase());

      bool matchesRole = selectedRole.value.isEmpty ||
          admin.role == selectedRole.value;

      bool matchesStatus = selectedStatus.value.isEmpty ||
          (selectedStatus.value == 'active' && admin.isActive) ||
          (selectedStatus.value == 'inactive' && !admin.isActive);

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  Future<bool> addAdmin({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      // FIXED: Prevent creating super_admin from the app
      if (role == 'super_admin') {
        throw Exception('Cannot create super_admin account from the application');
      }

      final response = await _apiService.post(
        AppConstants.addAdminEndpoint,
        {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phone_number': phoneNumber,
        },
      );

      if (response['status'] == 'success') {
        await loadAdmins(); // Reload the list
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to add admin');
      }
    } catch (e) {
      throw Exception('Add admin failed: ${e.toString()}');
    }
  }

  // FIXED: Update admin method with proper error handling and super_admin protection
  Future<bool> updateAdmin(AdminUser admin) async {
    try {
      // FIXED: Prevent updating to super_admin role
      if (admin.role == 'super_admin') {
        throw Exception('Cannot update admin to super_admin role');
      }

      print('🔄 Updating admin: ${admin.id}');
      print('📋 Data: name=${admin.name}, role=${admin.role}, phone=${admin.phoneNumber}, active=${admin.isActive}');

      final response = await _apiService.post(
        AppConstants.updateAdminEndpoint,
        {
          'admin_id': admin.id,
          'name': admin.name,
          'role': admin.role,
          'phone_number': admin.phoneNumber ?? '',
          'is_active': admin.isActive ? '1' : '0',
        },
      );

      print('✅ Update response: ${response['status']}');

      if (response['status'] == 'success') {
        // Update the admin in the local list
        final index = admins.indexWhere((a) => a.id == admin.id);
        if (index != -1) {
          admins[index] = admin;
          applyFilters();
        }

        await loadAdmins(); // Reload to ensure sync
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to update admin');
      }
    } catch (e) {
      print('❌ Update admin error: $e');
      throw Exception('Update admin failed: ${e.toString()}');
    }
  }

  Future<bool> deleteAdmin(String adminId) async {
    try {
      // FIXED: Check if we're trying to delete a super_admin (shouldn't happen due to filtering, but just in case)
      final adminToDelete = admins.firstWhereOrNull((admin) => admin.id == adminId);
      if (adminToDelete?.role == 'super_admin') {
        throw Exception('Cannot delete super_admin account');
      }

      final response = await _apiService.post(
        AppConstants.deleteAdminEndpoint,
        {'admin_id': adminId},
      );

      if (response['status'] == 'success') {
        await loadAdmins(); // Reload the list
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to delete admin');
      }
    } catch (e) {
      throw Exception('Delete admin failed: ${e.toString()}');
    }
  }

  Future<bool> changeAdminPassword(String adminId, String newPassword) async {
    try {
      // FIXED: Check if we're trying to change password for super_admin
      final adminToChange = admins.firstWhereOrNull((admin) => admin.id == adminId);
      if (adminToChange?.role == 'super_admin') {
        throw Exception('Cannot change password for super_admin account');
      }

      final response = await _apiService.post(
        AppConstants.changeAdminPasswordEndpoint,
        {
          'admin_id': adminId,
          'new_password': newPassword,
        },
      );

      if (response['status'] == 'success') {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Change admin password failed: ${e.toString()}');
    }
  }

  void selectAdmin(AdminUser admin) {
    selectedAdmin = admin;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedRole.value = '';
    selectedStatus.value = '';
    applyFilters();
  }

  // Helper method to check if current user is super_admin (useful for UI logic)
  bool get isCurrentUserSuperAdmin {
    final authController = Get.find<AuthController>();
    return authController.admin?.role == 'super_admin';
  }
}