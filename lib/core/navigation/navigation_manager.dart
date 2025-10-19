import 'package:flutter/material.dart';

/// Navigation manager for Backstage Cinema
/// Provides centralized navigation with stack protection
class NavigationManager {
  static final NavigationManager _instance = NavigationManager._internal();
  factory NavigationManager() => _instance;
  NavigationManager._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current context
  BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to a named route
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Replace current route with a new one
  Future<T?> replaceTo<T extends Object?>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to route and remove all previous routes
  Future<T?> navigateAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Go back to previous route
  void goBack<T>([T? result]) {
    if (canGoBack()) {
      navigatorKey.currentState!.pop<T>(result);
    }
  }

  /// Check if can go back
  bool canGoBack() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  /// Pop until specific route
  void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(
      ModalRoute.withName(routeName),
    );
  }

  /// Get current route name
  String? get currentRouteName {
    String? currentPath;
    navigatorKey.currentState?.popUntil((route) {
      currentPath = route.settings.name;
      return true;
    });
    return currentPath;
  }

  /// Stack protection: Prevent duplicate navigation
  Future<T?> navigateToSafe<T>(String routeName, {Object? arguments}) {
    if (currentRouteName == routeName) {
      return Future.value(null);
    }
    return navigateTo<T>(routeName, arguments: arguments);
  }

  /// Clear navigation stack and go to route
  Future<T?> resetAndNavigateTo<T>(String routeName, {Object? arguments}) {
    return navigateAndRemoveUntil<T>(
      routeName,
      arguments: arguments,
    );
  }
}
