import 'package:flutter/services.dart';

/// Formats CPF input with mask XXX.XXX.XXX-XX
class CpfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final numbers = text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 11 digits
    if (numbers.length > 11) {
      return oldValue;
    }

    // Format: XXX.XXX.XXX-XX
    String formatted = '';
    for (var i = 0; i < numbers.length; i++) {
      if (i == 3 || i == 6) {
        formatted += '.';
      } else if (i == 9) {
        formatted += '-';
      }
      formatted += numbers[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Static CPF formatting utilities
class CpfFormat {
  /// Formats a CPF string to XXX.XXX.XXX-XX
  static String format(String cpf) {
    final numbers = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (numbers.length != 11) return cpf;

    return '${numbers.substring(0, 3)}.${numbers.substring(3, 6)}.${numbers.substring(6, 9)}-${numbers.substring(9, 11)}';
  }

  /// Removes formatting from CPF
  static String unformat(String cpf) {
    return cpf.replaceAll(RegExp(r'[^\d]'), '');
  }
}
