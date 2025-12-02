import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Check internet connection using multiple methods
class InternetChecker {
  static final InternetChecker _instance = InternetChecker._internal();
  factory InternetChecker() => _instance;
  InternetChecker._internal();

  /// Check internet connection by DNS lookup
  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
    return false;
  }

  /// Check internet using connectivity_plus package
  Future<bool> hasConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      // FIXED: Check if list contains 'none'
      if (connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty) {
        return false;
      }

      // Even if connected to WiFi/Mobile, verify actual internet access
      return await checkInternet();
    } catch (_) {
      return false;
    }
  }

  /// Get connection type
  Future<String> getConnectionType() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();

      // FIXED: Handle List<ConnectivityResult>
      if (connectivityResults.isEmpty || connectivityResults.contains(ConnectivityResult.none)) {
        return 'No Connection';
      }

      // Return first non-none connection type
      for (var result in connectivityResults) {
        switch (result) {
          case ConnectivityResult.wifi:
            return 'WiFi';
          case ConnectivityResult.mobile:
            return 'Mobile Data';
          case ConnectivityResult.ethernet:
            return 'Ethernet';
          case ConnectivityResult.vpn:
            return 'VPN';
          case ConnectivityResult.bluetooth:
            return 'Bluetooth';
          case ConnectivityResult.other:
            return 'Other';
          case ConnectivityResult.none:
            continue;
        }
      }

      return 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  /// Stream of connectivity changes - FIXED: Returns List<ConnectivityResult>
  Stream<List<ConnectivityResult>> get connectivityStream {
    return Connectivity().onConnectivityChanged;
  }
}

/// Quick function for checking internet (backwards compatible)
Future<bool> checkInternet() async {
  return await InternetChecker().checkInternet();
}