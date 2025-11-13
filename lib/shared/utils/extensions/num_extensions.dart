import '../formatters/currency_formatter.dart';

/// Number extension methods
extension NumExtensions on num {
  /// Formats number as Brazilian currency
  String toCurrency() {
    return CurrencyFormatter.format(toDouble());
  }

  /// Formats number as currency without symbol
  String toCurrencyWithoutSymbol() {
    return CurrencyFormatter.formatWithoutSymbol(toDouble());
  }

  /// Checks if number is positive
  bool get isPositive => this > 0;

  /// Checks if number is negative
  bool get isNegative => this < 0;

  /// Checks if number is zero
  bool get isZero => this == 0;

  /// Clamps number between min and max
  num clampValue(num min, num max) {
    return clamp(min, max);
  }

  /// Returns percentage string (e.g., 0.85 -> "85%")
  String toPercentage({int decimals = 0}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }

  /// Rounds to specified decimal places
  double roundToDecimals(int decimals) {
    final multiplier = 10.0 * decimals;
    return (this * multiplier).roundToDouble() / multiplier;
  }
}

/// Int extension methods
extension IntExtensions on int {
  /// Formats as ordinal (1st, 2nd, 3rd, etc.)
  String toOrdinal() {
    if (this % 100 >= 11 && this % 100 <= 13) {
      return '$thisº';
    }

    switch (this % 10) {
      case 1:
        return '$thisº';
      case 2:
        return '$thisº';
      case 3:
        return '$thisº';
      default:
        return '$thisº';
    }
  }

  /// Checks if number is even
  bool get isEven => this % 2 == 0;

  /// Checks if number is odd
  bool get isOdd => this % 2 != 0;

  /// Formats number with leading zeros
  String padLeft(int width) {
    return toString().padLeft(width, '0');
  }
}

/// Double extension methods
extension DoubleExtensions on double {
  /// Formats to fixed decimal places
  String toFixed(int decimals) {
    return toStringAsFixed(decimals);
  }

  /// Rounds to nearest int
  int roundToInt() {
    return round();
  }
}
