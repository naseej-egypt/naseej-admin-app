import 'package:flutter/material.dart';

enum SnackPosition { TOP, BOTTOM }

/// Clean navigation and dialog utility replacing GetX context-free navigation.
/// Uses standard Flutter Navigator and ScaffoldMessenger keys.
class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static String? _currentRouteName;
  static String get currentRoute => _currentRouteName ?? '';
  static void setCurrentRoute(String? route) => _currentRouteName = route;

  /// Navigate to named route (like Get.toNamed)
  static Future<T?> toNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    _currentRouteName = routeName;
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Replace current route with named route (like Get.offNamed)
  static Future<T?> offNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    _currentRouteName = routeName;
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Clear stack and push named route (like Get.offAllNamed)
  static Future<T?> offAllNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
    RoutePredicate? predicate,
  }) {
    _currentRouteName = routeName;
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route (like Get.back)
  static void back<T extends Object?>({T? result}) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop<T>(result);
    }
  }

  /// Check if can pop
  static bool canPop() => navigatorKey.currentState?.canPop() ?? false;

  static bool get isDialogOpen => false;
  static bool get isSnackbarOpen => false;

  /// Pop until predicate is satisfied (like Get.until)
  static void until(RoutePredicate predicate) {
    navigatorKey.currentState?.popUntil(predicate);
  }

  /// Display a snackbar with standard Material ScaffoldMessenger
  static void showSnackBar(
    String message, {
    String? title,
    Color? backgroundColor,
    Color? textColor,
    Color? colorText,
    Widget? icon,
    Duration duration = const Duration(seconds: 3),
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Widget? mainButton,
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    final resolvedTextColor = colorText ?? textColor ?? Colors.white;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null && title.isNotEmpty) ...[
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: resolvedTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    message,
                    style: TextStyle(
                      color: resolvedTextColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (mainButton != null) mainButton,
          ],
        ),
        backgroundColor: backgroundColor ?? const Color(0xFF323232),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: margin,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: borderWidth ?? 1)
              : BorderSide.none,
        ),
      ),
    );
  }

  /// Drop-in compatible snackbar method matching Get.snackbar(...)
  static void snackbar(
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
    Color? textColor,
    Widget? icon,
    Duration duration = const Duration(seconds: 3),
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Widget? mainButton,
  }) {
    showSnackBar(
      message,
      title: title,
      backgroundColor: backgroundColor,
      textColor: textColor,
      colorText: colorText,
      icon: icon,
      duration: duration,
      margin: margin,
      padding: padding,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      mainButton: mainButton,
    );
  }

  /// Drop-in compatible dialog method matching Get.dialog(...)
  static Future<T?> dialog<T>(
    Widget widget, {
    bool barrierDismissible = true,
  }) {
    final ctx = context;
    if (ctx == null) return Future.value(null);
    return showDialog<T>(
      context: ctx,
      barrierDismissible: barrierDismissible,
      builder: (_) => widget,
    );
  }

  /// Drop-in compatible bottomSheet method matching Get.bottomSheet(...)
  static Future<T?> bottomSheet<T>(
    Widget bottomsheet, {
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    bool ignoreSafeArea = false,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? settings,
    Duration? enterBottomSheetDuration,
    Duration? exitBottomSheetDuration,
  }) {
    final ctx = context;
    if (ctx == null) return Future.value(null);
    return showModalBottomSheet<T>(
      context: ctx,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      routeSettings: settings,
      builder: (_) => bottomsheet,
    );
  }
}
