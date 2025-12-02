import 'package:get/get.dart';
import '../models/admin_user.dart';
import '../services/auth_service.dart';
import '../config/routes.dart';
import '../config/app_colors.dart';
import 'package:flutter/material.dart';
import 'profile_controller.dart';
import 'notification_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final currentAdmin = Rxn<AdminUser>(); // Observable admin

  // Get current admin (for synchronous access)
  AdminUser? get admin => currentAdmin.value ?? _authService.currentAdmin;

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final hasSession = await _authService.hasValidSession();
      if (hasSession) {
        // Load current admin info
        currentAdmin.value = _authService.currentAdmin;
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      print('Session check error: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // CRITICAL FIX: Clear any existing profile data before login
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().clearProfile();
      }

      final adminUser = await _authService.signIn(email, password);

      if (adminUser != null) {
        // Set current admin
        currentAdmin.value = adminUser;

        print('✅ Login successful for: ${adminUser.name} (ID: ${adminUser.id})');

        // Wait to ensure token is fully saved
        await Future.delayed(const Duration(milliseconds: 500));

        // Show success message
        Get.snackbar(
          'Welcome Back',
          'Hello, ${adminUser.name}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle, color: AppColors.white),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        // Navigate to dashboard
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      String displayMessage = _getCleanErrorMessage(e.toString());
      errorMessage.value = displayMessage;

      if (!displayMessage.contains('dashboard') &&
          !displayMessage.contains('products') &&
          !displayMessage.contains('categories') &&
          !displayMessage.contains('orders') &&
          !displayMessage.contains('customers') &&
          !displayMessage.contains('delivery') &&
          !displayMessage.contains('notifications') &&
          !displayMessage.contains('stores') &&
          !displayMessage.contains('Unauthorized access')) {
        Get.snackbar(
          'Login Failed',
          displayMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error_outline, color: AppColors.white),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

// CRITICAL FIX: Enhanced logout with complete data cleanup
  Future<void> logout() async {
    try {
      isLoading.value = true;

      print('🚪 Logging out admin: ${currentAdmin.value?.name}');

      // Call backend logout
      await _authService.signOut();

      // CRITICAL FIX: Clear all user-specific data
      print('🧹 Cleaning up user data...');

      // Clear current admin
      currentAdmin.value = null;

      // Clear profile controller if exists
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        profileController.clearProfile();
        print('✅ Profile data cleared');
      }

      // CRITICAL FIX: Clear notification controller data on logout
      if (Get.isRegistered<NotificationController>()) {
        final notificationController = Get.find<NotificationController>();
        await notificationController.clearAllDataOnLogout();
        print('✅ Notification data cleared for logout');
      }

      // Navigate to login
      Get.offAllNamed(AppRoutes.login);

      // Show success message
      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
        duration: const Duration(seconds: 2),
      );

      print('✅ Logout complete');
    } catch (e) {
      print('❌ Logout error: $e');

      // Even if logout fails, still clear local data and go to login
      currentAdmin.value = null;
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().clearProfile();
      }
      if (Get.isRegistered<NotificationController>()) {
        await Get.find<NotificationController>().clearAllDataOnLogout();
      }

      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Error',
        'Logout encountered an issue but you have been logged out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;

      await _authService.resetPassword(email);

      Get.snackbar(
        'Success',
        'Password reset instructions sent to your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        _getCleanErrorMessage(e.toString()),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _getCleanErrorMessage(String error) {
    error = error.replaceAll('Exception:', '').trim();

    if (error.contains('Failed to load dashboard') ||
        error.contains('Failed to load products') ||
        error.contains('Failed to load categories')) {
      return 'Login successful, redirecting...';
    }

    if (error.contains('Failed host lookup') || error.contains('SocketException')) {
      return 'Network error. Please check your internet connection.';
    }

    if (error.contains('TimeoutException') || error.contains('timed out')) {
      return 'Connection timeout. Please try again.';
    }

    if (error.contains('Invalid email or password')) {
      return 'Invalid email or password';
    }

    if (error.contains('Unauthorized') || error.contains('Unauthorized access')) {
      return 'Invalid credentials. Please try again.';
    }

    if (error.contains('Sign in failed')) {
      return 'Login failed. Please check your credentials.';
    }

    return error.isNotEmpty ? error : 'An error occurred. Please try again.';
  }

  Future<bool> changePassword(
      String currentPassword,
      String newPassword,
      String confirmPassword,
      ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _authService.changePassword(
        currentPassword,
        newPassword,
        confirmPassword,
      );

      if (response) {
        Get.snackbar(
          'Success',
          'Password changed successfully. Please login again with your new password.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check_circle, color: AppColors.white),
        );

        await Future.delayed(const Duration(seconds: 2));
        await logout();

        return true;
      } else {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      String displayMessage = _getCleanErrorMessage(e.toString());
      errorMessage.value = displayMessage;

      Get.snackbar(
        'Change Password Failed',
        displayMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: AppColors.white),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}