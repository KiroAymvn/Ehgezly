// data/local/local_storage_service.dart
//
// All Hive local storage read and write operations live here.
// Other parts of the app should NOT import Hive directly —
// they should use this service instead.

import 'package:hive/hive.dart';
import '../../models/employee.dart';
import '../../models/guest.dart';
import '../../models/reservation.dart';
import '../../models/room.dart';

class LocalStorageService {
  // ── Hive Box Names ─────────────────────────────────────────────────────────
  static const String _roomsBoxName        = 'hotel_rooms_box';
  static const String _guestsBoxName       = 'hotel_guests_box';
  static const String _reservationsBoxName = 'hotel_reservations_box';
  static const String _employeesBoxName    = 'hotel_employees_box';
  static const String _metaBoxName         = 'hotel_meta_box';
  static const String _lastIdKey           = 'hotel_last_ids';

  // ── Save All ───────────────────────────────────────────────────────────────

  Future<void> saveAll({
    required List<Room> rooms,
    required List<Guest> guests,
    required List<Reservation> reservations,
    required List<Employee> employees,
    required Map<String, int> lastIds,
  }) async {
    try {
      final roomsBox = Hive.box<Room>(_roomsBoxName);
      await roomsBox.clear();
      await roomsBox.addAll(rooms);

      final guestsBox = Hive.box<Guest>(_guestsBoxName);
      await guestsBox.clear();
      await guestsBox.addAll(guests);

      final resBox = Hive.box<Reservation>(_reservationsBoxName);
      await resBox.clear();
      await resBox.addAll(reservations);

      final empBox = Hive.box<Employee>(_employeesBoxName);
      await empBox.clear();
      await empBox.addAll(employees);

      final metaBox = Hive.box(_metaBoxName);
      // Convert map to String, dynamic as Hive prefers
      final dynamicMeta = lastIds.map((key, value) => MapEntry(key, value as dynamic));
      await metaBox.put(_lastIdKey, dynamicMeta);
    } catch (e) {
      print('LocalStorageService.saveAll error: $e');
      rethrow;
    }
  }

  // ── Load All ───────────────────────────────────────────────────────────────

  Future<StorageData> loadAll() async {
    try {
      final roomsBox = Hive.box<Room>(_roomsBoxName);
      final guestsBox = Hive.box<Guest>(_guestsBoxName);
      final resBox = Hive.box<Reservation>(_reservationsBoxName);
      final empBox = Hive.box<Employee>(_employeesBoxName);
      final metaBox = Hive.box(_metaBoxName);

      final rawMeta = metaBox.get(_lastIdKey);
      Map<String, int>? lastIds;
      if (rawMeta != null && rawMeta is Map) {
        lastIds = rawMeta.map((k, v) => MapEntry(k.toString(), v as int));
      }

      return StorageData(
        rooms: roomsBox.values.toList(),
        guests: guestsBox.values.toList(),
        reservations: resBox.values.toList(),
        employees: empBox.values.toList(),
        lastIds: lastIds ?? {'roomId': 0, 'guestId': 0, 'reservationId': 0, 'employeeId': 0},
      );
    } catch (e) {
      print('LocalStorageService.loadAll error: $e');
      return StorageData.empty();
    }
  }

  // ── Clear All ──────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await Future.wait([
      Hive.box<Room>(_roomsBoxName).clear(),
      Hive.box<Guest>(_guestsBoxName).clear(),
      Hive.box<Reservation>(_reservationsBoxName).clear(),
      Hive.box<Employee>(_employeesBoxName).clear(),
      Hive.box(_metaBoxName).clear(),
    ]);
  }
}

// ── Value Object returned by loadAll ──────────────────────────────────────────

class StorageData {
  final List<Room> rooms;
  final List<Guest> guests;
  final List<Reservation> reservations;
  final List<Employee> employees;
  final Map<String, int> lastIds;

  const StorageData({
    required this.rooms,
    required this.guests,
    required this.reservations,
    required this.employees,
    required this.lastIds,
  });

  factory StorageData.empty() => StorageData(
        rooms: [], guests: [], reservations: [], employees: [],
        lastIds: {'roomId': 0, 'guestId': 0, 'reservationId': 0, 'employeeId': 0},
      );
}
