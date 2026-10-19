import 'dart:collection';
import 'package:flutter/material.dart';
import 'app_navigator.dart';

export 'package:flutter/material.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';
export '../core/providers.dart';
export 'app_navigator.dart' show SnackPosition;

/// Observer registry to capture active reactive reads inside Obx builders
class RxObserver {
  RxObserver._();

  static _ObxState? current;

  static void register(Listenable listenable) {
    current?._register(listenable);
  }
}

/// Reactive wrapper for primitive and object values
class Rx<T> extends ChangeNotifier {
  T _value;

  Rx(this._value);

  T get value {
    RxObserver.register(this);
    return _value;
  }

  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  void call(T newValue) => value = newValue;

  @override
  String toString() {
    RxObserver.register(this);
    return _value.toString();
  }
}

/// Nullable reactive wrapper
class Rxn<T> extends Rx<T?> {
  Rxn([T? initial]) : super(initial);
}

typedef RxString = Rx<String>;
typedef RxBool = Rx<bool>;
typedef RxInt = Rx<int>;
typedef RxDouble = Rx<double>;

/// Reactive List wrapper
class RxList<E> extends ChangeNotifier with ListMixin<E> {
  final List<E> _inner;

  RxList([List<E>? initial]) : _inner = initial ?? <E>[];

  List<E> get value {
    RxObserver.register(this);
    return this;
  }

  set value(List<E> newList) {
    _inner.clear();
    _inner.addAll(newList);
    notifyListeners();
  }

  @override
  int get length {
    RxObserver.register(this);
    return _inner.length;
  }

  @override
  set length(int newLength) {
    _inner.length = newLength;
    notifyListeners();
  }

  @override
  E operator [](int index) {
    RxObserver.register(this);
    return _inner[index];
  }

  @override
  void operator []=(int index, E value) {
    _inner[index] = value;
    notifyListeners();
  }

  @override
  void add(E element) {
    _inner.add(element);
    notifyListeners();
  }

  @override
  void addAll(Iterable<E> iterable) {
    _inner.addAll(iterable);
    notifyListeners();
  }

  @override
  bool remove(Object? element) {
    final result = _inner.remove(element);
    if (result) notifyListeners();
    return result;
  }

  @override
  void clear() {
    _inner.clear();
    notifyListeners();
  }

  void assignAll(Iterable<E> iterable) {
    _inner.clear();
    _inner.addAll(iterable);
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}

/// Reactive Map wrapper
class RxMap<K, V> extends ChangeNotifier with MapMixin<K, V> {
  final Map<K, V> _inner;

  RxMap([Map<K, V>? initial]) : _inner = initial ?? <K, V>{};

  Map<K, V> get value {
    RxObserver.register(this);
    return this;
  }

  set value(Map<K, V> newMap) {
    _inner.clear();
    _inner.addAll(newMap);
    notifyListeners();
  }

  @override
  V? operator [](Object? key) {
    RxObserver.register(this);
    return _inner[key];
  }

  @override
  void operator []=(K key, V value) {
    _inner[key] = value;
    notifyListeners();
  }

  @override
  void clear() {
    _inner.clear();
    notifyListeners();
  }

  @override
  Iterable<K> get keys {
    RxObserver.register(this);
    return _inner.keys;
  }

  @override
  V? remove(Object? key) {
    final result = _inner.remove(key);
    notifyListeners();
    return result;
  }
}

/// Extension methods to convert any type to reactive
extension ReactiveExtension<T> on T {
  Rx<T> get obs => Rx<T>(this);
}

extension ReactiveListExtension<E> on List<E> {
  RxList<E> get obs => RxList<E>(this);
}

extension ReactiveMapExtension<K, V> on Map<K, V> {
  RxMap<K, V> get obs => RxMap<K, V>(this);
}

/// Obx widget that rebuilds whenever any observed Rx variable changes
class Obx extends StatefulWidget {
  final Widget Function() builder;

  const Obx(this.builder, {super.key});

  @override
  State<Obx> createState() => _ObxState();
}

class _ObxState extends State<Obx> {
  final Set<Listenable> _subscribed = <Listenable>{};

  void _register(Listenable listenable) {
    if (_subscribed.add(listenable)) {
      listenable.addListener(_handleChange);
    }
  }

  void _handleChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final listenable in _subscribed) {
      listenable.removeListener(_handleChange);
    }
    _subscribed.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prevObserver = RxObserver.current;
    RxObserver.current = this;
    try {
      return widget.builder();
    } finally {
      RxObserver.current = prevObserver;
    }
  }
}

/// Base controller class extending ChangeNotifier
abstract class GetxController extends ChangeNotifier {
  void onInit() {}
  void onClose() {}
}

/// Drop-in compatibility facade for GetX calls, delegating to AppNavigator and registered dependencies
class Get {
  Get._();

  static final Map<Type, dynamic> _dependencies = <Type, dynamic>{};

  static T put<T>(T dependency, {bool permanent = false}) {
    _dependencies[T] = dependency;
    if (dependency is GetxController) {
      dependency.onInit();
    }
    return dependency;
  }

  static T find<T>() {
    final dep = _dependencies[T];
    if (dep == null) {
      throw StateError('Dependency of type $T is not registered.');
    }
    return dep as T;
  }

  static bool isRegistered<T>() => _dependencies.containsKey(T);

  static void delete<T>() {
    final dep = _dependencies.remove(T);
    if (dep is GetxController) {
      dep.onClose();
    }
  }

  // Navigation delegations
  static Future<T?>? toNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return AppNavigator.toNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?>? offNamed<T extends Object?, TO extends Object?>(String routeName, {Object? arguments, TO? result}) {
    return AppNavigator.offNamed<T, TO>(routeName, arguments: arguments, result: result);
  }

  static Future<T?>? offAllNamed<T extends Object?>(String routeName, {Object? arguments, RoutePredicate? predicate}) {
    return AppNavigator.offAllNamed<T>(routeName, arguments: arguments, predicate: predicate);
  }

  static void back<T extends Object?>({T? result}) {
    AppNavigator.back(result: result);
  }

  static BuildContext? get context => AppNavigator.context;
  static String get currentRoute => AppNavigator.currentRoute;

  static TextTheme get textTheme {
    final ctx = AppNavigator.context;
    if (ctx != null) {
      return Theme.of(ctx).textTheme;
    }
    return Typography.material2021().black;
  }

  static bool get isDialogOpen => AppNavigator.isDialogOpen;
  static bool get isSnackbarOpen => AppNavigator.isSnackbarOpen;

  static void until(RoutePredicate predicate) {
    AppNavigator.until(predicate);
  }

  static Future<T?>? bottomSheet<T>(
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
    return AppNavigator.bottomSheet<T>(
      bottomsheet,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      ignoreSafeArea: ignoreSafeArea,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      settings: settings,
      enterBottomSheetDuration: enterBottomSheetDuration,
      exitBottomSheetDuration: exitBottomSheetDuration,
    );
  }

  // Snackbar delegation
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
    AppNavigator.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: colorText,
      textColor: textColor,
      icon: icon,
      duration: duration,
      snackPosition: snackPosition,
      margin: margin,
      padding: padding,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      mainButton: mainButton,
    );
  }

  // Dialog delegation
  static Future<T?> dialog<T>(
    Widget widget, {
    bool barrierDismissible = true,
  }) {
    return AppNavigator.dialog<T>(widget, barrierDismissible: barrierDismissible);
  }

  static Future<T?> defaultDialog<T>({
    String title = "Alert",
    TextStyle? titleStyle,
    Widget? content,
    String? middleText,
    Color? backgroundColor,
    double radius = 20.0,
    List<Widget>? actions,
  }) {
    final ctx = AppNavigator.context;
    if (ctx == null) return Future.value(null);
    return showDialog<T>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(title, style: titleStyle),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        content: content ?? (middleText != null ? Text(middleText) : null),
        actions: actions,
      ),
    );
  }
}

/// Helper extension for nullable firstWhere
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

/// Worker helper for watching reactive changes
void ever<T>(Rx<T> listener, void Function(T val) callback) {
  listener.addListener(() {
    callback(listener.value);
  });
}

/// Reactive String convenience getters
extension RxStringExtension on Rx<String> {
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;
  int get length => value.length;
}

/// Reactive Number operators
extension RxNumExtension<T extends num> on Rx<T> {
  bool operator >(num other) => value > other;
  bool operator <(num other) => value < other;
  bool operator >=(num other) => value >= other;
  bool operator <=(num other) => value <= other;
}

/// String capitalization extension
extension StringCapitalizeExtension on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

/// Utility validators matching GetUtils
class GetUtils {
  GetUtils._();

  static bool isEmail(String s) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(s);
  }

  static bool isPhoneNumber(String s) {
    if (s.length > 16 || s.length < 9) return false;
    return RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(s);
  }

  static bool isURL(String s) => Uri.tryParse(s)?.hasAbsolutePath ?? false;
}
