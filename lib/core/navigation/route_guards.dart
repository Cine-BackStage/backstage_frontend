import 'package:flutter/material.dart';

/// Route guard for authentication
class AuthGuard {
  /// Checks if user is authenticated
  static bool isAuthenticated() {
    return false;
  }

  /// Middleware to check authentication before route navigation
  static Widget guard({
    required Widget child,
    required VoidCallback onUnauthenticated,
  }) {
    if (isAuthenticated()) {
      return child;
    } else {
      // Navigate to login if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onUnauthenticated();
      });
      return const SizedBox.shrink();
    }
  }
}

/// Route guard for permissions
class PermissionGuard {
  /// Checks if user has specific permission
  static bool hasPermission(String permission) {
    return true;
  }

  /// Middleware to check permission before route navigation
  static Widget guard({
    required Widget child,
    required String permission,
    required VoidCallback onUnauthorized,
  }) {
    if (hasPermission(permission)) {
      return child;
    } else {
      // Show unauthorized message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onUnauthorized();
      });
      return const SizedBox.shrink();
    }
  }
}
