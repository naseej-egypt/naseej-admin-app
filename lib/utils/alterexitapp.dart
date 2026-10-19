import 'dart:io';
import 'package:naseej_admin_app/config/app_colors.dart';
import 'reactive.dart';

/// Show exit confirmation dialog with app theme styling
Future<bool> alertExitApp(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  bool? shouldExit = await showDialog<bool>(
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: isDark ? Color(0xFF2C2520) : AppColors.background, // CHANGED: Replaced gradient with solid color
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with solid background
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2), // CHANGED: Replaced gradient with solid color
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.exit_to_app_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(height: 20),

              // Title
              Text(
                "Exit App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),

              SizedBox(height: 12),

              // Message
              Text(
                "Are you sure you want to exit?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.background : Colors.grey,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 30),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Exit Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary, // CHANGED: Replaced gradient with solid color
                        borderRadius: BorderRadius.circular(16),
                        // REMOVED: boxShadow
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  if (shouldExit == true) {
    exit(0);
  }

  return Future.value(false);
}

/// Show exit confirmation dialog using GetX (Alternative method)
Future<bool> alertExitAppGetX() {
  return Get.defaultDialog<bool>(
    title: "Exit App",
    titleStyle: TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    middleText: "Are you sure you want to exit?",
    backgroundColor: AppColors.background,
    radius: 20,
    actions: [
      OutlinedButton(
        onPressed: () {
          Get.back(result: false);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Cancel",
          style: TextStyle(color: AppColors.primary),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          Get.back(result: true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text("Exit"),
      ),
    ],
  ).then((value) {
    if (value == true) {
      exit(0);
    }
    return Future.value(false);
  });
}