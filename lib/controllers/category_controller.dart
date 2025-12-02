import 'dart:io';
import 'package:get/get.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../config/app_colors.dart';
import 'package:flutter/material.dart';

class CategoryController extends GetxController {
  final CategoryService _categoryService = CategoryService();

  final categories = <Category>[].obs;
  final filteredCategories = <Category>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  Category? selectedCategory;

  // Track first load
  bool _isFirstLoad = true;
  bool _hasLoaded = false;

  @override
  void onInit() {
    super.onInit();
    // Load categories immediately when controller is created
    loadCategories();
  }

  // Load all categories
  Future<void> loadCategories() async {
    try {
      // Only show loading if we don't have any categories
      if (categories.isEmpty) {
        isLoading.value = true;
      }

      final data = await _categoryService.getCategories();
      categories.value = data;
      filteredCategories.value = data;
      searchQuery.value = '';
      _isFirstLoad = false;
      _hasLoaded = true;
    } catch (e) {
      // CRITICAL FIX: Don't show error snackbar on first load
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
        print('Category load error (first load): $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Load active categories
  Future<void> loadActiveCategories() async {
    try {
      isLoading.value = true;
      final data = await _categoryService.getActiveCategories();
      categories.value = data;
      filteredCategories.value = data;
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

  // Search categories
  Future<void> searchCategories(String query) async {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredCategories.value = categories;
      return;
    }

    if (query.length < 2) {
      return;
    }

    try {
      isLoading.value = true;
      final results = await _categoryService.searchCategories(query);
      filteredCategories.value = results;
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

  // Add category and return the new category ID
  Future<String?> addCategory(Category category) async {
    try {
      isLoading.value = true;
      final newCategoryId = await _categoryService.addCategory(category);
      await loadCategories();

      Get.snackbar(
        'Success',
        'Category added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );

      return newCategoryId;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Update category
  Future<bool> updateCategory(Category category) async {
    try {
      isLoading.value = true;
      await _categoryService.updateCategory(category);
      await loadCategories();

      Get.snackbar(
        'Success',
        'Category updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );

      return true;
    } catch (e) {
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

  // Delete category
  Future<void> deleteCategory(String id) async {
    try {
      isLoading.value = true;
      await _categoryService.deleteCategory(id);
      await loadCategories();
      Get.snackbar(
        'Success',
        'Category deleted successfully',
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

  // Upload category image
  Future<String?> uploadCategoryImage(File image, String categoryId) async {
    try {
      final url = await _categoryService.uploadCategoryImage(image, categoryId);
      return url;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 4),
      );
      return null;
    }
  }

  // Delete category image
  Future<void> deleteCategoryImage(String categoryId) async {
    try {
      await _categoryService.deleteCategoryImage(categoryId);
      await loadCategories();
      Get.snackbar(
        'Success',
        'Category image deleted successfully',
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

  // Toggle category status
  Future<void> toggleCategoryStatus(String categoryId, bool isActive) async {
    try {
      await _categoryService.toggleCategoryStatus(categoryId, isActive);
      await loadCategories();
      Get.snackbar(
        'Success',
        'Category status updated',
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

  // Reorder categories
  Future<void> reorderCategories(List<Category> reorderedCategories) async {
    try {
      await _categoryService.reorderCategories(reorderedCategories);
      categories.value = reorderedCategories;
      filteredCategories.value = reorderedCategories;
      Get.snackbar(
        'Success',
        'Categories reordered successfully',
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

  // Set selected category
  void selectCategory(Category category) {
    selectedCategory = category;
  }

  // Clear selected category
  void clearSelectedCategory() {
    selectedCategory = null;
  }

  // Check if categories have been loaded
  bool get hasLoaded => _hasLoaded;
}