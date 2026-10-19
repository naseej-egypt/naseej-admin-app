import 'package:flutter/material.dart';
import 'package:naseej_admin_app/utils/internet_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Widget that shows internet connection status and triggers refresh
class InternetCheckerWidget extends StatefulWidget {
  final Widget child;
  final bool showOnlineMessage;
  final VoidCallback? onConnectionRestored;

  const InternetCheckerWidget({
    Key? key,
    required this.child,
    this.showOnlineMessage = false,
    this.onConnectionRestored,
  }) : super(key: key);

  @override
  State<InternetCheckerWidget> createState() => _InternetCheckerWidgetState();
}

class _InternetCheckerWidgetState extends State<InternetCheckerWidget> {
  bool _isOnline = true;
  bool _showBanner = false;
  bool _wasOffline = false;
  bool _isInitialCheck = true;
  DateTime? _lastConnectionChange;
  String? _currentBannerType;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _listenToConnectionChanges();
  }

  void _checkInitialConnection() async {
    bool isConnected = await InternetChecker().hasConnection();
    if (mounted) {
      setState(() {
        _isOnline = isConnected;
        _showBanner = false; // Never show banner on initial check
        _wasOffline = !isConnected;
        _isInitialCheck = false;
      });
    }
  }

  void _listenToConnectionChanges() {
    InternetChecker().connectivityStream.listen((List<ConnectivityResult> results) async {
      bool hasConnectivity = results.any((result) => result != ConnectivityResult.none);

      // Prevent processing duplicate events within 1 second
      final now = DateTime.now();
      if (_lastConnectionChange != null &&
          now.difference(_lastConnectionChange!).inSeconds < 1) {
        return;
      }

      if (hasConnectivity) {
        bool isConnected = await InternetChecker().checkInternet();

        if (mounted) {
          setState(() {
            bool justCameOnline = !_isOnline && isConnected;
            _isOnline = isConnected;
            _lastConnectionChange = now;

            if (justCameOnline && _wasOffline) {
              _wasOffline = false;
              _showBanner = true;
              _currentBannerType = 'online';

              // Call the refresh callback
              if (widget.onConnectionRestored != null) {
                widget.onConnectionRestored!();
              }

              // Auto-hide online banner after 3 seconds
              Future.delayed(Duration(seconds: 3), () {
                if (mounted && _currentBannerType == 'online') {
                  setState(() {
                    _showBanner = false;
                    _currentBannerType = null;
                  });
                }
              });
            } else {
              // If we're already online and stay online, don't show banner
              _showBanner = false;
              _currentBannerType = null;
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            // Only show offline banner if we're coming from online state
            if (_isOnline) {
              _isOnline = false;
              _showBanner = true;
              _wasOffline = true;
              _currentBannerType = 'offline';
              _lastConnectionChange = now;
            }
            // If we're already offline, don't show duplicate banner
          });
        }
      }
    });
  }

  void _hideBanner() {
    if (mounted) {
      setState(() {
        _showBanner = false;
        _currentBannerType = null;
      });
    }
  }

  Future<void> _retryConnection() async {
    bool isConnected = await InternetChecker().checkInternet();
    if (mounted) {
      setState(() {
        if (isConnected && !_isOnline) {
          _isOnline = true;
          _wasOffline = false;
          _showBanner = true;
          _currentBannerType = 'online';
          _lastConnectionChange = DateTime.now();

          if (widget.onConnectionRestored != null) {
            widget.onConnectionRestored!();
          }

          Future.delayed(Duration(seconds: 2), () {
            if (mounted && _currentBannerType == 'online') {
              setState(() {
                _showBanner = false;
                _currentBannerType = null;
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Single connection status banner
        if (_showBanner && !_isInitialCheck)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isOnline
                        ? [Color(0xFF4CAF50), Color(0xFF45a049)]
                        : [Color(0xFFf44336), Color(0xFFd32f2f)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      Icon(
                        _isOnline ? Icons.wifi : Icons.wifi_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isOnline
                              ? 'Connection restored - refreshing content...'
                              : 'No internet connection',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!_isOnline)
                        TextButton(
                          onPressed: _retryConnection,
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (_isOnline)
                        IconButton(
                          onPressed: _hideBanner,
                          icon: Icon(Icons.close, color: Colors.white, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}