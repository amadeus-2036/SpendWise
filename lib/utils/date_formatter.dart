import 'package:intl/intl.dart';

/// Helper methods for user-friendly date and month formatting.
class DateFormatter {
  /// Format as "Today", "Yesterday", or "Nov 12, 2026"
  static String formatFriendly(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) {
      return 'Today';
    } else if (diff == 1) {
      return 'Yesterday';
    } else if (diff == -1) {
      return 'Tomorrow';
    } else if (date.year == now.year) {
      return DateFormat('MMM d').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  /// Format as "12 Nov 2026, 04:30 PM"
  static String formatFull(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  /// Format as "November 2026"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Format as "Nov 26"
  static String formatShortMonthYear(DateTime date) {
    return DateFormat('MMM yy').format(date);
  }

  /// Short month name like "Jan", "Feb", etc.
  static String formatMonthShort(int month) {
    return DateFormat('MMM').format(DateTime(2026, month, 1));
  }
}

