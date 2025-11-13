/// DateTime extension methods
extension DateTimeExtensions on DateTime {
  /// Checks if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Checks if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Returns date at start of day (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Returns date at end of day (23:59:59)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }

  /// Returns date at start of month
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Returns date at end of month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59);
  }

  /// Adds days to date
  DateTime addDays(int days) {
    return add(Duration(days: days));
  }

  /// Subtracts days from date
  DateTime subtractDays(int days) {
    return subtract(Duration(days: days));
  }

  /// Checks if date is in the past
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Checks if date is in the future
  bool get isFuture {
    return isAfter(DateTime.now());
  }

  /// Returns age in years from this date
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Checks if two dates are on the same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Returns the difference in days
  int differenceInDays(DateTime other) {
    final diff = difference(other);
    return diff.inDays.abs();
  }

  /// Formats to ISO 8601 string
  String toIso8601String() {
    return toIso8601String();
  }
}
