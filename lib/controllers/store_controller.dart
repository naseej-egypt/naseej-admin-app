import 'dart:io';
import 'package:get/get.dart';
import '../models/store.dart';
import '../services/store_service.dart';
import '../utils/api_helper.dart';
import '../config/app_colors.dart';

class StoreController extends GetxController {
  final StoreService _storeService = StoreService();

  final stores = <Store>[].obs;
  final filteredStores = <Store>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedStatus = 'all'.obs;

  Store? selectedStore;

  // Track first load
  bool _isFirstLoad = true;
  bool _hasLoaded = false;

  @override
  void onInit() {
    super.onInit();
    // Don't load stores immediately - wait until we're authenticated
  }

  Future<void> loadStores() async {
    try {
      // Only show loading if we don't have any stores
      if (stores.isEmpty) {
        isLoading.value = true;
      }

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      final data = await _storeService.getStores();
      stores.value = data;
      filterByStatus(selectedStatus.value);
      _isFirstLoad = false;
      _hasLoaded = true;
    } catch (e) {
      print('Error in loadStores: $e');

      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        print('Store load error (first load): $e');
      }

      // Set empty lists on error
      stores.value = [];
      filteredStores.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStore(String storeId) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      selectedStore = await _storeService.getStore(storeId);
    } catch (e) {
      // CRITICAL FIX: Don't show error snackbar on first load during login
      if (!_isFirstLoad) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void searchStores(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filterByStatus(selectedStatus.value);
    } else {
      _performBackendSearch(query);
    }
  }

  void _performBackendSearch(String query) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      final results = await _storeService.searchStores(query);
      filteredStores.value = results;
    } catch (e) {
      // Fallback to local search if backend fails
      filteredStores.value = stores
          .where((store) =>
      store.name.toLowerCase().contains(query.toLowerCase()) ||
          store.address.toLowerCase().contains(query.toLowerCase()) ||
          store.managerName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } finally {
      isLoading.value = false;
    }
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    if (status == 'all') {
      filteredStores.value = stores;
    } else if (status == 'active') {
      filteredStores.value = stores.where((store) => store.isActive).toList();
    } else {
      filteredStores.value = stores.where((store) => !store.isActive).toList();
    }
  }

  Future<bool> addStore(Store store, File? image) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      // Debug: Print the data being sent
      final formData = store.toFormData();
      print('Adding store with form data: $formData');
      print('Working days in list: ${store.workingDays}');
      print('Working days in form data: ${formData['working_days']}');

      // First add the store without image
      final storeId = await _storeService.addStore(store);

      // Then upload image if any
      if (image != null) {
        await _storeService.uploadStoreImage(image, storeId);
      }

      // Reload stores to get the complete data including image
      await loadStores();

      // Success snackbar
      Get.snackbar(
        'Success',
        'Store added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      return true;
    } catch (e) {
      print('Error adding store: $e');
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateStore(Store store, File? newImage) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      // Debug: Print the data being sent
      final updateData = store.toUpdateFormData();
      print('Updating store with form data: $updateData');
      print('Working days in list: ${store.workingDays}');
      print('Working days in form data: ${updateData['working_days']}');

      // Update store data
      await _storeService.updateStore(store);

      // Upload new image if any
      if (newImage != null) {
        await _storeService.uploadStoreImage(newImage, store.id);
      }

      // Reload stores
      await loadStores();

      // Success snackbar
      Get.snackbar(
        'Success',
        'Store updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      return true;
    } catch (e) {
      print('Error updating store: $e');
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStore(String storeId) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _storeService.deleteStore(storeId);
      await loadStores();

      Get.snackbar(
        'Success',
        'Store deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleStoreStatus(String storeId, bool isActive) async {
    try {
      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _storeService.toggleStoreStatus(storeId, isActive);
      await loadStores();

      Get.snackbar(
        'Success',
        'Store status updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void selectStore(Store store) {
    selectedStore = store;
  }

  void clearSelectedStore() {
    selectedStore = null;
  }

  // Statistics
  int get activeStoresCount => stores.where((store) => store.isActive).length;
  int get totalStoresCount => stores.length;
  int get openStoresCount => stores.where((store) => store.isCurrentlyOpen).length;

  Map<String, int> getStatusCounts() {
    return {
      'total': stores.length,
      'active': stores.where((store) => store.isActive).length,
      'inactive': stores.where((store) => !store.isActive).length,
    };
  }

  // Check if stores have been loaded
  bool get hasLoaded => _hasLoaded;
}