import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../utils/api_helper.dart';

class ApiService extends GetxController {
  // POST Request - Fixed for form data with special handling for JSON arrays
  Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    try {
      final headers = await ApiHelper.getHeaders();
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

      // Convert data to form URL encoded format
      // CRITICAL FIX: Don't encode working_days if it's already a JSON string
      final encodedData = data.entries.map((entry) {
        // Special handling for working_days field - don't double-encode JSON
        if (entry.key == 'working_days' && entry.value.toString().startsWith('[')) {
          return '${Uri.encodeComponent(entry.key)}=${entry.value}';
        }
        // Normal encoding for other fields
        return '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}';
      }).join('&');

      final response = await http.post(
        url,
        headers: headers,
        body: encodedData,
      ).timeout(
        const Duration(seconds: AppConstants.apiTimeoutSeconds),
      );

      return ApiHelper.parseResponse(response);
    } catch (e) {
      throw Exception('POST request failed: ${e.toString()}');
    }
  }

  // GET Request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await ApiHelper.getHeaders();
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: AppConstants.apiTimeoutSeconds),
      );

      return ApiHelper.parseResponse(response);
    } catch (e) {
      throw Exception('GET request failed: ${e.toString()}');
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    try {
      final headers = await ApiHelper.getHeaders();
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      ).timeout(
        const Duration(seconds: AppConstants.apiTimeoutSeconds),
      );

      return ApiHelper.parseResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: ${e.toString()}');
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await ApiHelper.getHeaders();
      final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

      final response = await http.delete(url, headers: headers).timeout(
        const Duration(seconds: AppConstants.apiTimeoutSeconds),
      );

      return ApiHelper.parseResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: ${e.toString()}');
    }
  }
}