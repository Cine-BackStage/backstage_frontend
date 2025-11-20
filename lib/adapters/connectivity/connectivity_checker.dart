/// Connectivity checker adapter for Backstage Cinema
/// This is a mocked implementation for Phase 1
class ConnectivityChecker {
  static final ConnectivityChecker _instance = ConnectivityChecker._internal();
  factory ConnectivityChecker() => _instance;
  ConnectivityChecker._internal();

  /// Check if device is connected to internet
  Future<bool> isConnected() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return Stream.value(true);
  }

  /// Check specific connectivity type (wifi, mobile, etc)
  Future<ConnectivityType> getConnectivityType() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return ConnectivityType.wifi;
  }
}

/// Connectivity types
enum ConnectivityType {
  wifi,
  mobile,
  ethernet,
  none,
}
