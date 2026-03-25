// data/local/local_storage_service.dart
//
// All SharedPreferences read and write operations live here.
// Other parts of the app should NOT import shared_preferences directly —
// they should use this service instead.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/employee.dart';
import '../../models/guest.dart';
import '../../models/reservation.dart';
import '../../models/room.dart';

class LocalStorageService {
  // ── SharedPreferences Keys ─────────────────────────────────────────────────
  static const String _roomsKey        = 'hotel_rooms';
  static const String _guestsKey       = 'hotel_guests';
  static const String _reservationsKey = 'hotel_reservations';
  static const String _employeesKey    = 'hotel_employees';
  static const String _lastIdKey       = 'hotel_last_ids';

  // ── Save All ───────────────────────────────────────────────────────────────

  Future<void> saveAll({
    required List<Room> rooms,
    required List<Guest> guests,
    required List<Reservation> reservations,
    required List<Employee> employees,
    required Map<String, int> lastIds,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(_lastIdKey,        json.encode(lastIds)),
        prefs.setString(_roomsKey,         json.encode(rooms.map((r) => r.toJson()).toList())),
        prefs.setString(_guestsKey,        json.encode(guests.map((g) => g.toJson()).toList())),
        prefs.setString(_reservationsKey,  json.encode(reservations.map((r) => r.toJson()).toList())),
        prefs.setString(_employeesKey,     json.encode(employees.map((e) => e.toJson()).toList())),
      ]);
    } catch (e) {
      print('LocalStorageService.saveAll error: $e');
      rethrow;
    }
  }

  // ── Load All ───────────────────────────────────────────────────────────────

  Future<StorageData> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final lastIds = _parseLastIds(prefs.getString(_lastIdKey));
      final rooms   = _parseList(prefs.getString(_roomsKey),        Room.fromJson);
      final guests  = _parseList(prefs.getString(_guestsKey),       Guest.fromJson);
      final res     = _parseList(prefs.getString(_reservationsKey), Reservation.fromJson);
      final emps    = _parseList(prefs.getString(_employeesKey),    Employee.fromJson);

      return StorageData(
        rooms: rooms, guests: guests,
        reservations: res, employees: emps,
        lastIds: lastIds,
      );
    } catch (e) {
      print('LocalStorageService.loadAll error: $e');
      return StorageData.empty();
    }
  }

  // ── Clear All ──────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_roomsKey),
      prefs.remove(_guestsKey),
      prefs.remove(_reservationsKey),
      prefs.remove(_employeesKey),
      prefs.remove(_lastIdKey),
    ]);
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  Map<String, int> _parseLastIds(String? raw) {
    if (raw == null) {
      return {'roomId': 0, 'guestId': 0, 'reservationId': 0, 'employeeId': 0};
    }
    return Map<String, int>.from(json.decode(raw));
  }

  List<T> _parseList<T>(String? raw, T Function(Map<String, dynamic>) fromJson) {
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> list = json.decode(raw);
    final result = <T>[];
    for (final item in list) {
      try {
        result.add(fromJson(item as Map<String, dynamic>));
      } catch (e) {
        print('Parse error for ${T.toString()}: $e');
      }
    }
    return result;
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
