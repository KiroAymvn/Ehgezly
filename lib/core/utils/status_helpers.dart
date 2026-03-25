// core/utils/status_helpers.dart
//
// Shared helpers for reservation status UI.
// Previously duplicated across all_reservations_screen, manager_home_screen,
// and customer_home_screen. Now lives in one place.

import 'package:flutter/material.dart';

class StatusHelpers {
  StatusHelpers._(); // Prevent instantiation

  /// Returns a color corresponding to the reservation [status].
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':   return Colors.blue;
      case 'checked-in':  return Colors.green;
      case 'checked-out': return Colors.grey;
      case 'cancelled':   return Colors.red;
      default:            return Colors.orange;
    }
  }

  /// Returns an icon corresponding to the reservation [status].
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':   return Icons.check_circle;
      case 'checked-in':  return Icons.login;
      case 'checked-out': return Icons.logout;
      case 'cancelled':   return Icons.cancel;
      default:            return Icons.calendar_today;
    }
  }

  /// Returns a color for a room view type label.
  static Color getViewTypeColor(String viewType) {
    switch (viewType.toLowerCase()) {
      case 'nile view': return Colors.teal;
      case 'suite':     return Colors.purple;
      case 'regular':   return Colors.blue;
      default:          return Colors.green;
    }
  }

  /// Returns a color for an employee department badge.
  static Color getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'reception':   return Colors.blue;
      case 'housekeeping': return Colors.green;
      case 'kitchen':     return Colors.orange;
      case 'maintenance': return Colors.red;
      case 'security':    return Colors.purple;
      case 'management':  return Colors.indigo;
      default:            return Colors.grey;
    }
  }
}
