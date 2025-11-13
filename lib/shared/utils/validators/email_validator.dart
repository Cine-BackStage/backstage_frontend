/// Validates email addresses
class EmailValidator {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates an email string
  static bool isValid(String? email) {
    if (email == null || email.isEmpty) return false;
    return _emailRegex.hasMatch(email);
  }

  /// Returns error message if email is invalid, null otherwise
  static String? validate(String? email) {
    if (email == null || email.isEmpty) {
      return 'E-mail é obrigatório';
    }

    if (!isValid(email)) {
      return 'E-mail inválido';
    }

    return null;
  }
}
