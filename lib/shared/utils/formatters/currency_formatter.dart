import 'package:intl/intl.dart';

/// Formats currency values to Brazilian Real (BRL)
class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final NumberFormat _formatterWithoutSymbol = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  /// Formats a double value to BRL currency string with symbol
  /// Example: 123.45 -> "R$ 123,45"
  static String format(double value) {
    return _formatter.format(value);
  }

  /// Formats a double value to BRL currency string without symbol
  /// Example: 123.45 -> "123,45"
  static String formatWithoutSymbol(double value) {
    return _formatterWithoutSymbol.format(value).trim();
  }

  /// Parses a currency string to double
  /// Example: "R$ 123,45" -> 123.45
  static double? parse(String value) {
    try {
      // Remove currency symbol and spaces
      final cleanValue = value
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');

      return double.tryParse(cleanValue);
    } catch (e) {
      return null;
    }
  }

  /// Formats cents to BRL currency
  /// Example: 12345 cents -> "R$ 123,45"
  static String formatCents(int cents) {
    return format(cents / 100);
  }
}
