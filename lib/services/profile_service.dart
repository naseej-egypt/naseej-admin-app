import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/admin_user.dart';
import '../utils/constants.dart';
import '../utils/api_helper.dart';
import 'api_service.dart';

class ProfileService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<AdminUser?> getProfile() async {
    try {
      final response = await _apiService.get('/admin/get_profile.php');

      if (response['status'] == 'success' && response['data'] != null) {
        return AdminUser.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load profile: ${e.toString()}');
    }
  }

  Future<AdminUser?> updateProfile(String name, String phone) async {
    try {
      final response = await _apiService.post(
        '/admin/update_profile.php',
        {
          'name': name,
          'phone_number': phone,
        },
      );

      if (response['status'] == 'success' && response['data'] != null) {
        return AdminUser.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  Future<String?> uploadProfileImage(File image) async {
    try {
      final token = await ApiHelper.getToken();
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/admin/update_profile_image.php');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer ${token ?? ''}';

      request.files.add(
        await http.MultipartFile.fromPath('file', image.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        if (data['status'] == 'success') {
          return data['data']['profile_image'];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      await _apiService.post('/admin/delete_profile_image.php', {});
    } catch (e) {
      throw Exception('Failed to delete image: ${e.toString()}');
    }
  }
}