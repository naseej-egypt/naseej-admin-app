import 'package:flutter/material.dart';
import 'package:naseej_admin_app/config/app_colors.dart';
import 'package:naseej_admin_app/utils/internet_checker.dart';

/// Middleware / Observer to check internet before navigating
class InternetMiddleware extends NavigatorObserver {}

/// Show no internet dialog
void showNoInternetDialog(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: isDark ? Color(0xFF2C2520) : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // WiFi off icon with animation
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: AppColors.warning,
                ),
              ),

              SizedBox(height: 20),

              Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(height: 12),

              Text(
                'Please check your internet connection and try again',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.grey,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        bool hasInternet = await checkInternet();
                        if (!hasInternet) {
                          showNoInternetDialog(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Retry'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Show no internet snackbar
void showNoInternetSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'No internet connection',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.warning,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      action: SnackBarAction(
        label: 'Retry',
        textColor: Colors.white,
        onPressed: () async {
          bool hasInternet = await checkInternet();
          if (hasInternet) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.wifi, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Connected to internet'),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    ),
  );
}