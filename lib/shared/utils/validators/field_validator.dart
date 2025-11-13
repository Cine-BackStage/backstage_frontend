/// Generic field validators
class FieldValidator {
  /// Validates required fields
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Campo'} é obrigatório';
    }
    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (value.length < min) {
      return '${fieldName ?? 'Campo'} deve ter no mínimo $min caracteres';
    }
    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (value.length > max) {
      return '${fieldName ?? 'Campo'} deve ter no máximo $max caracteres';
    }
    return null;
  }

  /// Validates that value is a number
  static String? isNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Campo'} deve ser um número';
    }
    return null;
  }

  /// Validates that value is a positive number
  static String? isPositive(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return '${fieldName ?? 'Campo'} deve ser um número positivo';
    }
    return null;
  }

  /// Validates minimum value
  static String? minValue(String? value, double min, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null || number < min) {
      return '${fieldName ?? 'Campo'} deve ser no mínimo $min';
    }
    return null;
  }

  /// Validates maximum value
  static String? maxValue(String? value, double max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null || number > max) {
      return '${fieldName ?? 'Campo'} deve ser no máximo $max';
    }
    return null;
  }

  /// Validates password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (value.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }

    return null;
  }

  /// Combines multiple validators
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
