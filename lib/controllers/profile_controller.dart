import 'dart:io';
import 'package:get/get.dart';
import '../models/admin_user.dart';
import '../services/profile_service.dart';
import '../config/app_colors.dart';
import 'package:flutter/material.dart';
import '../utils/api_helper.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();

  final profile = Rx<AdminUser?>(null);
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Track last load time to avoid excessive API calls
  DateTime? _lastLoadTime;
  String? _lastLoadedAdminId; // CRITICAL FIX: Track which admin's profile was loaded

  @override
  void onInit() {
    super.onInit();
    // Don't load automatically - wait for explicit call
  }

  // CRITICAL FIX: Always force refresh when loading profile
  Future<void> loadProfile({bool forceRefresh = true}) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Verify token exists
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      print('🔄 Loading profile with token: ${token.substring(0, 20)}...');

      final data = await _profileService.getProfile();

      if (data != null) {
        // CRITICAL FIX: Check if this is a different admin
        if (_lastLoadedAdminId != null && _lastLoadedAdminId != data.id) {
          print('⚠️ Different admin detected! Clearing old profile data');
          print('   Previous: $_lastLoadedAdminId');
          print('   New: ${data.id}');
        }

        profile.value = data;
        _lastLoadTime = DateTime.now();
        _lastLoadedAdminId = data.id; // Store which admin's profile this is

        print('✅ Profile loaded successfully: ${data.name} (ID: ${data.id})');
      } else {
        throw Exception('No profile data returned');
      }
    } catch (e) {
      hasError.value = true;

      String cleanError = e.toString().replaceAll('Exception:', '').trim();
      errorMessage.value = cleanError;

      print('❌ Profile load error: $cleanError');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(String name, String phone) async {
    try {
      isLoading.value = true;

      final updatedProfile = await _profileService.updateProfile(name, phone);

      if (updatedProfile != null) {
        profile.value = updatedProfile;
        _lastLoadTime = DateTime.now();
        _lastLoadedAdminId = updatedProfile.id;

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          icon: const Icon(Icons.check_circle, color: AppColors.white),
        );

        return true;
      }

      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadProfileImage(File image) async {
    try {
      isLoading.value = true;

      final imageUrl = await _profileService.uploadProfileImage(image);

      if (imageUrl != null) {
        // Force refresh to get updated image
        await loadProfile(forceRefresh: true);

        Get.snackbar(
          'Success',
          'Profile image updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          icon: const Icon(Icons.check_circle, color: AppColors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      isLoading.value = true;

      await _profileService.deleteProfileImage();

      // Force refresh
      await loadProfile(forceRefresh: true);

      Get.snackbar(
        'Success',
        'Profile image deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Manual refresh (always forces refresh)
  Future<void> refreshProfile() async {
    print('🔄 Manual profile refresh requested');
    await loadProfile(forceRefresh: true);
  }

  // CRITICAL FIX: Clear ALL profile data (for logout)
  void clearProfile() {
    print('🧹 Clearing profile data');
    profile.value = null;
    _lastLoadTime = null;
    _lastLoadedAdminId = null; // Clear admin ID tracking
    hasError.value = false;
    errorMessage.value = '';
  }
}