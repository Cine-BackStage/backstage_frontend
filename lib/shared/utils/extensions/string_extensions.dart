/// String extension methods
extension StringExtensions on String {
  /// Capitalizes the first letter of the string
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Checks if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Checks if string is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Removes all whitespace
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Checks if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }

  /// Checks if string contains only numbers
  bool get isNumeric {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  /// Truncates string with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  /// Extracts only numbers from string
  String get numbersOnly {
    return replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Checks if string is a valid CPF (11 digits)
  bool get isValidCpfFormat {
    final numbers = numbersOnly;
    return numbers.length == 11;
  }
}

/// Nullable string extensions
extension NullableStringExtensions on String? {
  /// Returns true if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if string is not null and not empty
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Returns the string or a default value if null
  String orDefault(String defaultValue) => this ?? defaultValue;

  /// Returns the string or empty string if null
  String get orEmpty => this ?? '';
}
