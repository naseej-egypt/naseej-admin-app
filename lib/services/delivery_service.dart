import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/delivery_man.dart';
import '../utils/constants.dart';
import '../utils/api_helper.dart';
import 'api_service.dart';

class DeliveryService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<DeliveryMan>> getDeliveryMen() async {
    try {
      final response = await _apiService.get('/delivery/get_all.php');

      print('Delivery Men API Response: $response');

      if (response['status'] == 'success') {
        dynamic data = response['data'];

        if (data is Map && data['delivery_men'] is List) {
          return (data['delivery_men'] as List).map((json) => DeliveryMan.fromJson(json)).toList();
        } else if (data is List) {
          return data.map((json) => DeliveryMan.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to load delivery men');
      }
    } catch (e) {
      print('Error loading delivery men: $e');
      throw Exception('Failed to load delivery men: ${e.toString()}');
    }
  }

  Future<DeliveryMan?> getDeliveryMan(String id) async {
    try {
      final response = await _apiService.post(
        '/delivery/get_by_id.php',
        {'delivery_man_id': id},
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return DeliveryMan.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load delivery man: ${e.toString()}');
    }
  }

  Future<String> addDeliveryMan(DeliveryMan deliveryMan) async {
    try {
      print('=== DeliveryService.addDeliveryMan() ===');
      final formData = deliveryMan.toFormData();
      print('Form data to send: $formData');

      final response = await _apiService.post(
        '/delivery/add.php',
        formData,
      );

      print('Add delivery man response: $response');

      if (response['status'] == 'success') {
        return response['data']['id']?.toString() ?? '';
      }
      throw Exception(response['message'] ?? 'Failed to add delivery man');
    } catch (e) {
      print('Error in addDeliveryMan: $e');
      throw Exception('Failed to add delivery man: ${e.toString()}');
    }
  }

  Future<void> updateDeliveryMan(DeliveryMan deliveryMan) async {
    try {
      print('=== DeliveryService.updateDeliveryMan() ===');
      final formData = deliveryMan.toUpdateFormData();
      print('Form data to send: $formData');

      final response = await _apiService.post(
        '/delivery/update.php',
        formData,
      );

      print('Update delivery man response: $response');

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update delivery man');
      }
    } catch (e) {
      print('Error in updateDeliveryMan: $e');
      throw Exception('Failed to update delivery man: ${e.toString()}');
    }
  }

  Future<void> deleteDeliveryMan(String id) async {
    try {
      final response = await _apiService.post(
        '/delivery/delete.php',
        {'delivery_man_id': id},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to delete delivery man');
      }
    } catch (e) {
      throw Exception('Failed to delete delivery man: ${e.toString()}');
    }
  }

  Future<String?> uploadProfileImage(File image, String deliveryManId) async {
    try {
      final token = await ApiHelper.getToken();
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/delivery/upload_image.php');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer ${token ?? ''}';

      request.fields['delivery_man_id'] = deliveryManId;
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

  Future<List<DeliveryMan>> searchDeliveryMen(String query) async {
    try {
      final response = await _apiService.post(
        '/delivery/search.php',
        {'query': query},
      );

      if (response['status'] == 'success') {
        dynamic data = response['data'];

        if (data is List) {
          return data.map((json) => DeliveryMan.fromJson(json)).toList();
        } else if (data is Map && data['delivery_men'] is List) {
          return (data['delivery_men'] as List).map((json) => DeliveryMan.fromJson(json)).toList();
        } else {
          return [];
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search delivery men: ${e.toString()}');
    }
  }

  Future<List<DeliveryMan>> getAvailableDeliveryMen() async {
    try {
      final response = await _apiService.get('/delivery/get_available.php');
      if (response['status'] == 'success') {
        dynamic data = response['data'];

        if (data is List) {
          return data.map((json) => DeliveryMan.fromJson(json)).toList();
        } else if (data is Map && data['delivery_men'] is List) {
          return (data['delivery_men'] as List).map((json) => DeliveryMan.fromJson(json)).toList();
        } else {
          return [];
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load available delivery men: ${e.toString()}');
    }
  }

  Future<void> updateDeliveryManStatus(String deliveryManId, String status) async {
    try {
      final response = await _apiService.post(
        '/delivery/update_status.php',
        {
          'delivery_man_id': deliveryManId,
          'status': status,
        },
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update delivery man status');
      }
    } catch (e) {
      throw Exception('Failed to update delivery man status: ${e.toString()}');
    }
  }

  Future<void> toggleDeliveryManStatus(String deliveryManId, bool isActive) async {
    try {
      final response = await _apiService.post(
        '/delivery/toggle_active.php',
        {
          'delivery_man_id': deliveryManId,
          'is_active': isActive ? 1 : 0,
        },
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update delivery man status');
      }
    } catch (e) {
      throw Exception('Failed to update delivery man status: ${e.toString()}');
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getDeliveryStatistics() async {
    try {
      final response = await _apiService.get('/delivery/get_all.php');

      if (response['status'] == 'success') {
        dynamic data = response['data'];

        if (data is Map && data['statistics'] != null) {
          return data['statistics'];
        }

        // Calculate statistics from delivery men list
        List<DeliveryMan> deliveryMen = [];
        if (data is Map && data['delivery_men'] is List) {
          deliveryMen = (data['delivery_men'] as List).map((json) => DeliveryMan.fromJson(json)).toList();
        } else if (data is List) {
          deliveryMen = data.map((json) => DeliveryMan.fromJson(json)).toList();
        }

        final activeCount = deliveryMen.where((dm) => dm.isActive).length;
        final availableCount = deliveryMen.where((dm) => dm.status == 'available' && dm.isActive).length;
        final busyCount = deliveryMen.where((dm) => dm.status == 'busy' && dm.isActive).length;
        final offlineCount = deliveryMen.where((dm) => dm.status == 'offline').length;
        final totalDeliveries = deliveryMen.fold(0, (sum, dm) => sum + dm.totalDeliveries);
        final averageRating = deliveryMen.isNotEmpty
            ? deliveryMen.map((dm) => dm.rating).reduce((a, b) => a + b) / deliveryMen.length
            : 0.0;

        return {
          'total': deliveryMen.length,
          'active': activeCount,
          'available': availableCount,
          'busy': busyCount,
          'offline': offlineCount,
          'total_deliveries': totalDeliveries,
          'average_rating': averageRating,
        };
      }
      return {};
    } catch (e) {
      throw Exception('Failed to load delivery statistics: ${e.toString()}');
    }
  }
}