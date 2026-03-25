// core/constants/app_constants.dart
//
// Application-wide constants: route names, credentials, and other fixed values.
// Centralizing them here avoids magic strings scattered across screens.

class AppConstants {
  AppConstants._(); // Prevent instantiation

  // ── Route Names ──────────────────────────────────────────────────────────
  static const String routeLogin          = '/';
  static const String routeCustomerHome   = '/customerHome';
  static const String routeManagerHome    = '/managerHome';
  static const String routeManagerRooms   = '/manager/rooms';
  static const String routeManagerGuests  = '/manager/guests';
  static const String routeManagerRes     = '/manager/reservations';
  static const String routeManagerEmp     = '/manager/employees';
  static const String routeDebug          = '/debug';

  // ── Reservation Status Values ─────────────────────────────────────────────
  static const String statusConfirmed  = 'Confirmed';
  static const String statusCheckedIn  = 'Checked-in';
  static const String statusCheckedOut = 'Checked-out';
  static const String statusCancelled  = 'Cancelled';

  // ── Room Types & Capacities ───────────────────────────────────────────────
  static const List<String> roomViewTypes = ['Nile View', 'Suite', 'Regular'];
  static const List<String> roomCapacities = ['Single', 'Double', 'Triple'];
  static const List<String> roomAmenities = [
    'WiFi', 'Gym', 'Spa', 'Dinner', 'Massage',
  ];

  // ── Employee Departments ──────────────────────────────────────────────────
  static const List<String> departments = [
    'All', 'Reception', 'Housekeeping', 'Kitchen',
    'Maintenance', 'Security', 'Management',
  ];
}
