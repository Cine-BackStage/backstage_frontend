import 'package:flutter/material.dart';

/// BuildContext extension methods for easier access to common properties
extension ContextExtensions on BuildContext {
  /// Returns the current theme
  ThemeData get theme => Theme.of(this);

  /// Returns the current color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Returns the current text theme
  TextTheme get textTheme => theme.textTheme;

  /// Returns the media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Returns the screen size
  Size get screenSize => mediaQuery.size;

  /// Returns the screen width
  double get screenWidth => screenSize.width;

  /// Returns the screen height
  double get screenHeight => screenSize.height;

  /// Returns the device pixel ratio
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// Returns the top padding (status bar height)
  double get topPadding => mediaQuery.padding.top;

  /// Returns the bottom padding (bottom navigation bar height)
  double get bottomPadding => mediaQuery.padding.bottom;

  /// Returns true if keyboard is visible
  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;

  /// Returns the keyboard height
  double get keyboardHeight => mediaQuery.viewInsets.bottom;

  /// Checks if device is in portrait mode
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Checks if device is in landscape mode
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Returns true if screen is small (< 600dp)
  bool get isSmallScreen => screenWidth < 600;

  /// Returns true if screen is medium (>= 600dp and < 1200dp)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;

  /// Returns true if screen is large (>= 1200dp)
  bool get isLargeScreen => screenWidth >= 1200;

  /// Shows a snackbar
  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Shows an error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Shows a success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Pops the current route
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Pushes a new route
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Pushes a named route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  /// Pops until the first route
  void popToFirst() {
    Navigator.of(this).popUntil((route) => route.isFirst);
  }

  /// Pushes a route and removes all previous routes
  Future<T?> pushAndRemoveAll<T>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  /// Unfocuses any focused text field
  void unfocus() {
    FocusScope.of(this).unfocus();
  }

  /// Requests focus
  void requestFocus(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
  }
}
