import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/reactive.dart';
import '../../config/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/internet_checker.dart';
import 'package:naseej_admin_app/utils/internet_middleware.dart';
import '../../utils/alterexitapp.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.put(AuthController());
  final _internetChecker = InternetChecker();
  bool _obscurePassword = true;
  bool _checkingInternet = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _checkInternetBeforeLogin() async {
    setState(() {
      _checkingInternet = true;
    });

    final hasInternet = await _internetChecker.hasConnection();

    setState(() {
      _checkingInternet = false;
    });

    if (!hasInternet) {
      showNoInternetDialog(context);
      return false;
    }
    return true;
  }

  void _handleLogin() async {
    // Check internet before attempting login
    final hasInternet = await _checkInternetBeforeLogin();
    if (!hasInternet) return;

    if (_formKey.currentState!.validate()) {
      await _authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  // Add WillPopScope for exit confirmation
  Future<bool> _onWillPop() async {
    // For login screen, we can use simple exit or custom dialog
    return await alertExitApp(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo/Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            size: 60,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Naseej Admin',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Internet Check Status (only show when checking)
                        if (_checkingInternet)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Checking internet connection...',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!GetUtils.isEmail(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        Obx(() => CustomButton(
                          text: 'Sign In',
                          onPressed: (_authController.isLoading.value || _checkingInternet)
                              ? null
                              : _handleLogin,
                          isLoading: _authController.isLoading.value,
                        )),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}