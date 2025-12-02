import 'package:get/get.dart';
import '../models/admin_user.dart';
import '../utils/api_helper.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  AdminUser? _currentAdmin;

  AdminUser? get currentAdmin => _currentAdmin;
  bool get isAuthenticated => _currentAdmin != null;

  // Sign in with email and password
  Future<AdminUser?> signIn(String email, String password) async {
    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );

      if (response['status'] == 'success' && response['data'] != null) {
        // CRITICAL FIX: Save token FIRST before creating admin object
        final token = response['data']['token'];
        if (token == null || token.isEmpty) {
          throw Exception('No authentication token received');
        }

        await ApiHelper.saveToken(token);

        // Verify token was saved
        final savedToken = await ApiHelper.getToken();
        if (savedToken == null) {
          throw Exception('Failed to save authentication token');
        }

        // Create admin user object
        _currentAdmin = AdminUser.fromJson(response['data']['admin']);

        return _currentAdmin;
      } else {
        throw Exception(response['message'] ?? 'Invalid email or password');
      }
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Try to call logout endpoint (optional, continue even if fails)
      await _apiService.post(AppConstants.logoutEndpoint, {});
    } catch (e) {
      // Ignore logout endpoint errors
    } finally {
      // Always clear local session
      await ApiHelper.removeToken();
      _currentAdmin = null;
    }
  }

  // Get admin profile
  Future<AdminUser?> getAdminProfile() async {
    try {
      final response = await _apiService.get('/admin/get_profile.php');

      if (response['status'] == 'success' && response['data'] != null) {
        _currentAdmin = AdminUser.fromJson(response['data']);
        return _currentAdmin;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if session exists and is valid - FIXED VERSION
  Future<bool> hasValidSession() async {
    try {
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      // Simply check if token exists - don't validate via API since endpoint doesn't exist
      // The dashboard will validate the token when it makes its first request
      return true;
    } catch (e) {
      return false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _apiService.post('/auth/reset_password.php', {'email': email});
    } catch (e) {
      throw Exception('Failed to send reset email');
    }
  }

  Future<bool> changePassword(
      String currentPassword,
      String newPassword,
      String confirmPassword,
      ) async {
    try {
      final response = await _apiService.post(
        AppConstants.changePasswordEndpoint,
        {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      if (response['status'] == 'success') {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Change password failed: ${e.toString()}');
    }
  }
}