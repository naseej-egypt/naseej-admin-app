import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/reactive.dart';
import '../../config/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';
import '../../controllers/auth_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security Icon with Info
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.security_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'For security reasons, you will be logged out\nafter changing your password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Current Password
              CustomTextField(
                controller: currentPasswordController,
                label: 'Current Password',
                hint: 'Enter your current password',
                prefixIcon: const Icon(Icons.lock),
                obscureText: !showCurrentPassword,
                validator: (value) => Validators.validateRequired(value, 'Current password'),
                suffixIcon: IconButton(
                  icon: Icon(
                    showCurrentPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      showCurrentPassword = !showCurrentPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // New Password
              CustomTextField(
                controller: newPasswordController,
                label: 'New Password',
                hint: 'Enter new password',
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: !showNewPassword,
                validator: Validators.validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    showNewPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      showNewPassword = !showNewPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              CustomTextField(
                controller: confirmPasswordController,
                label: 'Confirm New Password',
                hint: 'Confirm your new password',
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: !showConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You will be automatically logged out after password change for security purposes.',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Password Requirements
              Card(
                color: AppColors.background,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('• At least 6 characters long'),
                      Text('• Include uppercase and lowercase letters'),
                      Text('• Include numbers and special characters'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Update Button
              Obx(() => CustomButton(
                text: 'Update Password & Logout',
                onPressed: _authController.isLoading.value ? null : _updatePassword,
                isLoading: _authController.isLoading.value,
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      await _authController.changePassword(
        currentPasswordController.text,
        newPasswordController.text,
        confirmPasswordController.text,
      );
      // Note: No need to clear controllers or navigate back here
      // because the logout will handle navigation automatically
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}