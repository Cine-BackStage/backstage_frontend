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

  /// API base URL for the current environment
  static String get apiBaseUrl {
    switch (_environment) {
      case 'production':
        return const String.fromEnvironment(
          'API_URL',
          defaultValue: 'https://backstagebackend-production.up.railway.app',
        );
      case 'development':
      default:
        // Use 10.0.2.2 for Android Emulator (maps to host localhost)
        // For iOS Simulator or web, use localhost
        return const String.fromEnvironment(
          'API_URL',
          defaultValue: 'http://10.0.2.2:3000',
        );
    }
  }

  /// Current environment name
  static String get environmentName => _environment;

  /// Check if running in production
  static bool get isProduction => _environment == 'production';

  /// Check if running in development
  static bool get isDevelopment => _environment == 'development';
}
