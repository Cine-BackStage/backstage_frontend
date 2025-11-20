import 'dart:developer' as developer;

/// Analytics tracker adapter for Backstage Cinema
/// This is a mocked implementation for Phase 1 that logs to console
class AnalyticsTracker {
  static final AnalyticsTracker _instance = AnalyticsTracker._internal();
  factory AnalyticsTracker() => _instance;
  AnalyticsTracker._internal();

  /// Track screen view
  void trackScreen(String screenName) {
    developer.log(
      'Screen View: $screenName',
      name: 'Analytics',
    );
  }

  /// Track event
  void trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) {
    developer.log(
      'Event: $eventName${parameters != null ? ' | Params: $parameters' : ''}',
      name: 'Analytics',
    );
  }

  /// Track error
  void trackError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? parameters,
  }) {
    developer.log(
      'Error: $error${parameters != null ? ' | Params: $parameters' : ''}',
      name: 'Analytics',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Set user ID
  void setUserId(String? userId) {
    developer.log(
      'User ID: ${userId ?? 'null'}',
      name: 'Analytics',
    );
  }

  /// Set user property
  void setUserProperty(String name, String? value) {
    developer.log(
      'User Property: $name = ${value ?? 'null'}',
      name: 'Analytics',
    );
  }

  /// Track login
  void trackLogin(String method) {
    trackEvent('login', parameters: {'method': method});
  }

  /// Track logout
  void trackLogout() {
    trackEvent('logout');
  }

  /// Track sale
  void trackSale({
    required double value,
    required String currency,
    Map<String, dynamic>? items,
  }) {
    trackEvent(
      'sale',
      parameters: {
        'value': value,
        'currency': currency,
        if (items != null) 'items': items,
      },
    );
  }
}
