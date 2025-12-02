import 'dart:io';
import 'package:get/get.dart';
import '../models/delivery_man.dart';
import '../services/delivery_service.dart';
import '../utils/api_helper.dart';
import '../config/app_colors.dart';

class DeliveryController extends GetxController {
  final DeliveryService _deliveryService = DeliveryService();

  final deliveryMen = <DeliveryMan>[].obs;
  final filteredDeliveryMen = <DeliveryMan>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedStatus = 'all'.obs;

  DeliveryMan? selectedDeliveryMan;

  // Track first load
  bool _isFirstLoad = true;
  bool _hasLoaded = false;

  @override
  void onInit() {
    super.onInit();
    // Don't load delivery men immediately - wait until we're authenticated
  }

  Future<void> loadDeliveryMen() async {
    try {
      // Only show loading if we don't have any delivery men
      if (deliveryMen.isEmpty) {
        isLoading.value = true;
      }

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      final data = await _deliveryService.getDeliveryMen();
      deliveryMen.value = data;
      filterByStatus(selectedStatus.value);
      _isFirstLoad = false;
      _hasLoaded = true;
    } catch (e) {
      print('Error in loadDeliveryMen: $e');

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
        print('Delivery load error (first load): $e');
      }

      // Set empty lists on error
      deliveryMen.value = [];
      filteredDeliveryMen.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDeliveryMan(String deliveryManId) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      selectedDeliveryMan = await _deliveryService.getDeliveryMan(deliveryManId);
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

  void searchDeliveryMen(String query) {
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

      final results = await _deliveryService.searchDeliveryMen(query);
      filteredDeliveryMen.value = results;
    } catch (e) {
      // Fallback to local search if backend fails
      filteredDeliveryMen.value = deliveryMen
          .where((dm) =>
      dm.name.toLowerCase().contains(query.toLowerCase()) ||
          dm.email.toLowerCase().contains(query.toLowerCase()) ||
          dm.phone.contains(query) ||
          dm.vehicleNumber.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } finally {
      isLoading.value = false;
    }
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    if (status == 'all') {
      filteredDeliveryMen.value = deliveryMen;
    } else {
      filteredDeliveryMen.value = deliveryMen
          .where((dm) => dm.status == status)
          .toList();
    }
  }

  Future<bool> addDeliveryMan(DeliveryMan deliveryMan, File? image) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      // Debug: Print the data being sent
      final formData = deliveryMan.toFormData();
      print('Adding delivery man with form data: $formData');

      // First add the delivery man without image
      final deliveryManId = await _deliveryService.addDeliveryMan(deliveryMan);

      // Then upload image if any
      if (image != null) {
        await _deliveryService.uploadProfileImage(image, deliveryManId);
      }

      // Reload delivery men to get the complete data including image
      await loadDeliveryMen();

      // Success snackbar
      Get.snackbar(
        'Success',
        'Delivery person added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      return true;
    } catch (e) {
      print('Error adding delivery man: $e');
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

  Future<bool> updateDeliveryMan(DeliveryMan deliveryMan, File? newImage) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      // Debug: Print the data being sent
      final updateData = deliveryMan.toUpdateFormData();
      print('Updating delivery man with form data: $updateData');

      // Update delivery man data
      await _deliveryService.updateDeliveryMan(deliveryMan);

      // Upload new image if any
      if (newImage != null) {
        await _deliveryService.uploadProfileImage(newImage, deliveryMan.id);
      }

      // Reload delivery men
      await loadDeliveryMen();

      // Success snackbar
      Get.snackbar(
        'Success',
        'Delivery person updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
      return true;
    } catch (e) {
      print('Error updating delivery man: $e');
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

  Future<void> deleteDeliveryMan(String deliveryManId) async {
    try {
      isLoading.value = true;

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _deliveryService.deleteDeliveryMan(deliveryManId);
      await loadDeliveryMen();

      Get.snackbar(
        'Success',
        'Delivery person deleted successfully',
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

  Future<void> updateDeliveryManStatus(String deliveryManId, String status) async {
    try {
      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _deliveryService.updateDeliveryManStatus(deliveryManId, status);
      await loadDeliveryMen();

      Get.snackbar(
        'Success',
        'Delivery person status updated',
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

  Future<void> toggleDeliveryManStatus(String deliveryManId, bool isActive) async {
    try {
      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      await _deliveryService.toggleDeliveryManStatus(deliveryManId, isActive);
      await loadDeliveryMen();

      Get.snackbar(
        'Success',
        'Delivery person status updated',
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

  void selectDeliveryMan(DeliveryMan deliveryMan) {
    selectedDeliveryMan = deliveryMan;
  }

  void clearSelectedDeliveryMan() {
    selectedDeliveryMan = null;
  }

  // Statistics
  Map<String, int> getStatusCounts() {
    final counts = <String, int>{
      'total': deliveryMen.length,
      'active': deliveryMen.where((dm) => dm.isActive).length,
      'available': deliveryMen.where((dm) => dm.status == 'available' && dm.isActive).length,
      'busy': deliveryMen.where((dm) => dm.status == 'busy' && dm.isActive).length,
      'offline': deliveryMen.where((dm) => dm.status == 'offline').length,
    };

    return counts;
  }

  // Get available delivery men for assignment
  Future<List<DeliveryMan>> getAvailableDeliveryMen() async {
    try {
      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        return [];
      }

      return await _deliveryService.getAvailableDeliveryMen();
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
      return [];
    }
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        return {};
      }

      return await _deliveryService.getDeliveryStatistics();
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
      return {};
    }
  }

  // Check if delivery men have been loaded
  bool get hasLoaded => _hasLoaded;
}