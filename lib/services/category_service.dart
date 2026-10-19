import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../utils/constants.dart';
import '../utils/api_helper.dart';
import 'api_service.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get(AppConstants.categoriesEndpoint);
      if (response['status'] == 'success' && response['data'] != null) {
        final categoriesData = response['data']['categories'] as List;
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load categories');
    } catch (e) {
      throw Exception('Failed to load categories: ${e.toString()}');
    }
  }

  Future<List<Category>> getActiveCategories() async {
    try {
      final response = await _apiService.get('/categories/get_active.php');
      if (response['status'] == 'success' && response['data'] != null) {
        final categoriesData = response['data']['categories'] as List;
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to load active categories');
    } catch (e) {
      throw Exception('Failed to load active categories: ${e.toString()}');
    }
  }

  Future<List<Category>> searchCategories(String query) async {
    try {
      final response = await _apiService.get('/categories/search.php?query=${Uri.encodeComponent(query)}');
      if (response['status'] == 'success' && response['data'] != null) {
        final categoriesData = response['data']['categories'] as List;
        return categoriesData.map((json) => Category.fromJson(json)).toList();
      }
      throw Exception(response['message'] ?? 'Failed to search categories');
    } catch (e) {
      throw Exception('Failed to search categories: ${e.toString()}');
    }
  }

  Future<String> addCategory(Category category) async {
    try {
      final response = await _apiService.post(
        '/categories/add.php',
        {
          'name': category.name,
          'description': category.description,
          'is_active': category.isActive ? 1 : 0,
        },
      );

      if (response['status'] == 'success') {
        return response['data']['id']?.toString() ?? '';
      }
      throw Exception(response['message'] ?? 'Failed to add category');
    } catch (e) {
      throw Exception('Failed to add category: ${e.toString()}');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      final response = await _apiService.post(
        '/categories/update.php',
        {
          'category_id': category.id,
          'name': category.name,
          'description': category.description,
          'is_active': category.isActive ? 1 : 0,
        },
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update category');
      }
    } catch (e) {
      throw Exception('Failed to update category: ${e.toString()}');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final response = await _apiService.post(
        '/categories/delete.php',
        {'category_id': id},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to delete category');
      }
    } catch (e) {
      throw Exception('Failed to delete category: ${e.toString()}');
    }
  }

  Future<String?> uploadCategoryImage(File image, String categoryId) async {
    try {
      final token = await ApiHelper.getToken();
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/categories/upload_image.php');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer ${token ?? ''}';

      request.fields['category_id'] = categoryId;
      request.files.add(
        await http.MultipartFile.fromPath('file', image.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        if (data['status'] == 'success') {
          return data['data']['image_url'];
        } else {
          throw Exception(data['message'] ?? 'Upload failed');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  Future<void> toggleCategoryStatus(String categoryId, bool isActive) async {
    try {
      final response = await _apiService.post(
        '/categories/toggle_status.php',
        {
          'category_id': categoryId,
          'is_active': isActive ? 1 : 0,
        },
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update category status');
      }
    } catch (e) {
      throw Exception('Failed to update category status: ${e.toString()}');
    }
  }

  Future<void> reorderCategories(List<Category> categories) async {
    try {
      final orderData = categories.asMap().entries.map((entry) => {
        'id': entry.value.id,
        'order': entry.key,
      }).toList();

      final response = await _apiService.post(
        '/categories/reorder.php',
        {'categories': json.encode(orderData)},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to reorder categories');
      }
    } catch (e) {
      throw Exception('Failed to reorder categories: ${e.toString()}');
    }
  }

  Future<void> deleteCategoryImage(String categoryId) async {
    try {
      final response = await _apiService.post(
        '/categories/delete_image.php',
        {'category_id': categoryId},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to delete category image');
      }
    } catch (e) {
      throw Exception('Failed to delete category image: ${e.toString()}');
    }
  }
}