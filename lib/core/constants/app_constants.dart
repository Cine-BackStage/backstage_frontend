/// General app-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Backstage Cinema';
  static const String appVersion = '1.0.0';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int cpfLength = 11;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;

  // Currency
  static const String currencySymbol = 'R\$';
  static const String currencyCode = 'BRL';
  static const String locale = 'pt_BR';

  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Error messages
  static const String genericErrorMessage = 'Ocorreu um erro. Tente novamente.';
  static const String networkErrorMessage = 'Sem conexão com a internet.';
  static const String timeoutErrorMessage = 'A requisição demorou muito. Tente novamente.';
  static const String unauthorizedErrorMessage = 'Sessão expirada. Faça login novamente.';
}
