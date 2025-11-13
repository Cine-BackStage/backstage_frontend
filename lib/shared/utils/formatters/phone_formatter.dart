import 'package:flutter/services.dart';

/// Formats phone number input with mask (XX) XXXXX-XXXX
class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final numbers = text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 11 digits (with 9th digit for mobile)
    if (numbers.length > 11) {
      return oldValue;
    }

    // Format: (XX) XXXXX-XXXX or (XX) XXXX-XXXX
    String formatted = '';
    for (var i = 0; i < numbers.length; i++) {
      if (i == 0) {
        formatted += '(';
      } else if (i == 2) {
        formatted += ') ';
      } else if ((numbers.length == 11 && i == 7) || (numbers.length == 10 && i == 6)) {
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

/// Static phone formatting utilities
class PhoneFormat {
  /// Formats a phone string to (XX) XXXXX-XXXX or (XX) XXXX-XXXX
  static String format(String phone) {
    final numbers = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (numbers.length < 10 || numbers.length > 11) return phone;

    if (numbers.length == 11) {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 7)}-${numbers.substring(7, 11)}';
    } else {
      return '(${numbers.substring(0, 2)}) ${numbers.substring(2, 6)}-${numbers.substring(6, 10)}';
    }
  }

  /// Removes formatting from phone
  static String unformat(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }
}
