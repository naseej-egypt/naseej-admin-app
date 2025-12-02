import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/store.dart';
import '../utils/constants.dart';
import '../utils/api_helper.dart';
import 'api_service.dart';

class StoreService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<Store>> getStores() async {
    try {
      final response = await _apiService.get('/stores/get_all.php');

      print('Stores API Response: $response');

      if (response['status'] == 'success') {
        dynamic data = response['data'];

        if (data is List) {
          return data.map((json) => Store.fromJson(json)).toList();
        } else if (data is Map) {
          if (data['stores'] is List) {
            return (data['stores'] as List).map((json) => Store.fromJson(json)).toList();
          } else if (data['data'] is List) {
            return (data['data'] as List).map((json) => Store.fromJson(json)).toList();
          } else {
            for (var key in data.keys) {
              if (data[key] is List) {
                return (data[key] as List).map((json) => Store.fromJson(json)).toList();
              }
            }
            return [];
          }
        } else {
          throw Exception('Invalid data format in response');
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to load stores');
      }
    } catch (e) {
      print('Error loading stores: $e');
      throw Exception('Failed to load stores: ${e.toString()}');
    }
  }

  Future<Store?> getStore(String id) async {
    try {
      final response = await _apiService.post(
        '/stores/get_by_id.php',
        {'store_id': id},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return Store.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load store: ${e.toString()}');
    }
  }

  Future<String> addStore(Store store) async {
    try {
      print('=== StoreService.addStore() ===');
      final formData = store.toFormData();
      print('Form data to send: $formData');

      final response = await _apiService.post(
        '/stores/add.php',
        formData,
      );

      print('Add store response: $response');

      if (response['status'] == 'success') {
        return response['data']['id']?.toString() ?? '';
      }
      throw Exception(response['message'] ?? 'Failed to add store');
    } catch (e) {
      print('Error in addStore: $e');
      throw Exception('Failed to add store: ${e.toString()}');
    }
  }

  Future<void> updateStore(Store store) async {
    try {
      print('=== StoreService.updateStore() ===');
      final formData = store.toUpdateFormData();
      print('Form data to send: $formData');

      final response = await _apiService.post(
        '/stores/update.php',
        formData,
      );

      print('Update store response: $response');

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update store');
      }
    } catch (e) {
      print('Error in updateStore: $e');
      throw Exception('Failed to update store: ${e.toString()}');
    }
  }

  Future<void> deleteStore(String id) async {
    try {
      final response = await _apiService.post(
        '/stores/delete.php',
        {'store_id': id},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to delete store');
      }
    } catch (e) {
      throw Exception('Failed to delete store: ${e.toString()}');
    }
  }

  Future<String?> uploadStoreImage(File image, String storeId) async {
    try {
      final token = await ApiHelper.getToken();
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/stores/upload_image.php');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer ${token ?? ''}';

      request.fields['store_id'] = storeId;
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

  Future<List<Store>> searchStores(String query) async {
    try {
      final response = await _apiService.post(
        '/stores/search.php',
        {'query': query},
      );

      if (response['status'] == 'success') {
        dynamic data = response['data'];

        if (data is List) {
          return data.map((json) => Store.fromJson(json)).toList();
        } else if (data is Map && data['stores'] is List) {
          return (data['stores'] as List).map((json) => Store.fromJson(json)).toList();
        } else {
          return [];
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search stores: ${e.toString()}');
    }
  }

  Future<List<Store>> getActiveStores() async {
    try {
      final response = await _apiService.get('/stores/get_all.php?active=true');
      if (response['status'] == 'success') {
        dynamic data = response['data'];

        if (data is List) {
          return data.map((json) => Store.fromJson(json)).toList();
        } else if (data is Map && data['stores'] is List) {
          return (data['stores'] as List).map((json) => Store.fromJson(json)).toList();
        } else {
          return [];
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load active stores: ${e.toString()}');
    }
  }

  Future<void> toggleStoreStatus(String storeId, bool isActive) async {
    try {
      final response = await _apiService.post(
        '/stores/toggle_status.php',
        {
          'store_id': storeId,
          'is_active': isActive ? 1 : 0,
        },
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update store status');
      }
    } catch (e) {
      throw Exception('Failed to update store status: ${e.toString()}');
    }
  }
}