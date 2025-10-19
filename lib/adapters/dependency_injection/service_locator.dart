import 'package:get_it/get_it.dart';

/// Service Locator adapter for dependency injection
/// Wraps GetIt for easy access to registered services
///
/// Usage:
/// ```dart
/// // Register a service
/// serviceLocator.registerSingleton<MyService>(MyService());
///
/// // Get a service
/// final myService = serviceLocator<MyService>();
/// ```
final serviceLocator = GetIt.instance;
