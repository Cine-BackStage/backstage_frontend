import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Environment configuration for different build modes
///
/// This class provides environment-specific configuration values
/// like API base URLs that change between development and production.
class Environment {
  /// The current environment mode
  static const String _environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static String? _cachedBaseUrl;

  /// API base URL for the current environment
  static String get apiBaseUrl {
    if (_cachedBaseUrl != null) {
      return _cachedBaseUrl!;
    }

    switch (_environment) {
      case 'production':
        _cachedBaseUrl = const String.fromEnvironment(
          'API_URL',
          defaultValue: 'https://backstagebackend-production.up.railway.app',
        );
        return _cachedBaseUrl!;
      case 'development':
      default:
        const customUrl = String.fromEnvironment('API_URL');
        if (customUrl.isNotEmpty) {
          _cachedBaseUrl = customUrl;
          return _cachedBaseUrl!;
        }

        // Auto-detect platform and use appropriate localhost address
        if (kIsWeb) {
          _cachedBaseUrl = 'http://localhost:3000';
        } else {
          try {
            if (Platform.isAndroid) {
              // Android Emulator uses 10.0.2.2 to access host machine
              _cachedBaseUrl = 'http://10.0.2.2:3000';
            } else {
              // iOS Simulator, macOS, Linux, Windows use localhost
              _cachedBaseUrl = 'http://localhost:3000';
            }
          } catch (e) {
            // Fallback if Platform check fails
            _cachedBaseUrl = 'http://localhost:3000';
          }
        }
        return _cachedBaseUrl!;
    }
  }

  /// Current environment name
  static String get environmentName => _environment;

  /// Check if running in production
  static bool get isProduction => _environment == 'production';

  /// Check if running in development
  static bool get isDevelopment => _environment == 'development';
}
