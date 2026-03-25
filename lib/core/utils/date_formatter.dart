// core/utils/date_formatter.dart
//
// A single shared DateFormat instance used across the entire app.
// This avoids creating new formatter objects on every rebuild.

import 'package:intl/intl.dart';

class AppDateFormatter {
  AppDateFormatter._(); // Prevent instantiation

  /// Formats a date as "Jan 01, 2024"
  static final DateFormat displayDate = DateFormat('MMM dd, yyyy');

  /// Formats a date as "Jan 01"
  static final DateFormat shortDate = DateFormat('MMM dd');

  /// Formats a date as "January 01, 2024"
  static final DateFormat longDate = DateFormat('MMMM dd, yyyy');

  /// Formats a date as "2024-01-01" (for storage/debugging)
  static final DateFormat isoDate = DateFormat('yyyy-MM-dd');

  /// Convenience method: format any date as the standard display format
  static String format(DateTime date) => displayDate.format(date);
}
