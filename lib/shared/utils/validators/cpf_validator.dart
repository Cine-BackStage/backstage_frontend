/// Validates Brazilian CPF (Cadastro de Pessoas Físicas)
class CpfValidator {
  /// Validates a CPF string (with or without formatting)
  static bool isValid(String? cpf) {
    if (cpf == null || cpf.isEmpty) return false;

    // Remove formatting
    final numbers = cpf.replaceAll(RegExp(r'[^\d]'), '');

    // Must have 11 digits
    if (numbers.length != 11) return false;

    // Check if all digits are the same (invalid CPF)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(numbers)) return false;

    // Validate first check digit
    var sum = 0;
    for (var i = 0; i < 9; i++) {
      sum += int.parse(numbers[i]) * (10 - i);
    }
    var checkDigit = 11 - (sum % 11);
    if (checkDigit >= 10) checkDigit = 0;
    if (checkDigit != int.parse(numbers[9])) return false;

    // Validate second check digit
    sum = 0;
    for (var i = 0; i < 10; i++) {
      sum += int.parse(numbers[i]) * (11 - i);
    }
    checkDigit = 11 - (sum % 11);
    if (checkDigit >= 10) checkDigit = 0;
    if (checkDigit != int.parse(numbers[10])) return false;

    return true;
  }

  /// Returns error message if CPF is invalid, null otherwise
  static String? validate(String? cpf) {
    if (cpf == null || cpf.isEmpty) {
      return 'CPF é obrigatório';
    }

    if (!isValid(cpf)) {
      return 'CPF inválido';
    }

    return null;
  }

  /// Extracts only numbers from CPF string
  static String cleanCpf(String cpf) {
    return cpf.replaceAll(RegExp(r'[^\d]'), '');
  }
}
