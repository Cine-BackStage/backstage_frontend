import 'package:intl/intl.dart';

/// Formats date and time values
class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _dateTimeSecondsFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'pt_BR');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM');

  /// Formats a DateTime to date string (dd/MM/yyyy)
  static String date(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// Formats a DateTime to time string (HH:mm)
  static String time(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Formats a DateTime to date and time string (dd/MM/yyyy HH:mm)
  static String dateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Formats a DateTime to date and time with seconds (dd/MM/yyyy HH:mm:ss)
  static String dateTimeWithSeconds(DateTime dateTime) {
    return _dateTimeSecondsFormat.format(dateTime);
  }

  /// Formats a DateTime to month and year (Janeiro 2024)
  static String monthYear(DateTime dateTime) {
    return _monthYearFormat.format(dateTime);
  }

  /// Formats a DateTime to short date (dd/MM)
  static String shortDate(DateTime dateTime) {
    return _shortDateFormat.format(dateTime);
  }

  /// Parses a date string (dd/MM/yyyy) to DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return _dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parses a datetime string (dd/MM/yyyy HH:mm) to DateTime
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return _dateTimeFormat.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Formats ISO 8601 string to date
  static String? fromIso8601(String? isoString) {
    if (isoString == null) return null;
    try {
      final dateTime = DateTime.parse(isoString);
      return date(dateTime);
    } catch (e) {
      return null;
    }
  }

  /// Formats ISO 8601 string to datetime
  static String? fromIso8601ToDateTime(String? isoString) {
    if (isoString == null) return null;
    try {
      final dt = DateTime.parse(isoString);
      return dateTime(dt);
    } catch (e) {
      return null;
    }
  }

  /// Returns relative time string (hoje, ontem, X dias atrás)
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Agora';
        }
        return '${difference.inMinutes} min atrás';
      }
      return '${difference.inHours}h atrás';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'} atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'} atrás';
    }
  }
}
