import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('🔍 Testing Naseej Backend Connection...\n');

  final baseUrl = '';

  // Test 1: Check if backend is accessible
  print('1️⃣ Testing backend accessibility...');
  try {
    final response = await http.get(Uri.parse('$baseUrl/auth/test_auth.php'));
    if (response.statusCode == 200) {
      print('✅ Backend is accessible\n');
    } else {
      print('❌ Backend returned status: ${response.statusCode}\n');
    }
  } catch (e) {
    print('❌ Cannot reach backend: $e\n');
    return;
  }

  // Test 2: Try login
  print('2️⃣ Testing login endpoint...');
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'email': 'admin@naseej.com',
        'password': 'password',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}\n');

    final data = json.decode(response.body);
    if (data['status'] == 'success') {
      print('✅ Login successful!');
      print('Token: ${data['data']['token'].substring(0, 20)}...');
      print('Admin: ${data['data']['admin']['name']}');
    } else {
      print('❌ Login failed: ${data['message']}');
    }
  } catch (e) {
    print('❌ Login test failed: $e');
  }

}
