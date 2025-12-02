import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'internet_checker.dart';
import 'internet_middleware.dart';
import 'alterexitapp.dart';

mixin ScreenBaseMixin<T extends StatefulWidget> on State<T> {
  final InternetChecker _internetChecker = InternetChecker();
  DateTime? _lastBackPressTime;
  bool _isCheckingInternet = false;

  /// Override this to handle back button with exit confirmation
  Future<bool> handleBackButton() async {
    final now = DateTime.now();

    // If back button is pressed twice within 2 seconds, exit app
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;

      // Show snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return false;
    }

    // Show exit confirmation dialog
    return await alertExitApp(context);
  }

  /// Check internet before performing critical actions
  Future<bool> checkInternetBeforeAction() async {
    setState(() {
      _isCheckingInternet = true;
    });

    final hasInternet = await _internetChecker.hasConnection();

    setState(() {
      _isCheckingInternet = false;
    });

    if (!hasInternet) {
      showNoInternetDialog(context);
      return false;
    }
    return true;
  }

  /// Get internet checking state
  bool get isCheckingInternet => _isCheckingInternet;

  /// Show internet checking indicator
  Widget buildInternetCheckingIndicator() {
    if (!_isCheckingInternet) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Checking internet connection...',
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}