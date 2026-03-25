// data/repositories/room_repository.dart
//
// Handles all CRUD operations for Room entities.
// Date-conflict logic lives here so no other class needs to know about it.

import '../../models/reservation.dart';
import '../../models/room.dart';

class RoomRepository {
  final List<Room> _rooms;
  final List<Reservation> _reservations;

  const RoomRepository({
    required List<Room> rooms,
    required List<Reservation> reservations,
  })  : _rooms = rooms,
        _reservations = reservations;

  // ── Queries ────────────────────────────────────────────────────────────────

  List<Room> get all => List.unmodifiable(_rooms);

  List<Room> get available => _rooms.where((r) => r.isAvailable).toList();

  Room? getById(int id) {
    try {
      return _rooms.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns rooms with no conflicting confirmed/checked-in reservation
  /// for the requested [checkIn]–[checkOut] window.
  List<Room> getAvailableForDates(DateTime checkIn, DateTime checkOut) {
    return _rooms.where((room) {
      return !_hasDateConflict(room.id, checkIn, checkOut);
    }).toList();
  }

  bool isAvailableForDates(int roomId, DateTime checkIn, DateTime checkOut) {
    return !_hasDateConflict(roomId, checkIn, checkOut);
  }

  /// Returns upcoming (future check-out) confirmed reservations for a room.
  List<Reservation> getUpcomingReservations(int roomId) {
    final now = DateTime.now();
    return _reservations.where((res) {
      return res.roomId == roomId &&
          res.status == 'Confirmed' &&
          res.checkOut.isAfter(now);
    }).toList();
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  /// Adds a new [Room] with an auto-assigned [id] and returns it.
  Room add({
    required int newId,
    required String number,
    required String viewType,
    required String capacity,
    required double pricePerNight,
    String imageUrl = '',
    List<String> amenities = const [],
  }) {
    final room = Room(
      id: newId,
      number: number,
      viewType: viewType,
      capacity: capacity,
      pricePerNight: pricePerNight,
      isAvailable: true,
      imageUrl: imageUrl.isNotEmpty
          ? imageUrl
          : 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
      amenities: amenities,
    );
    _rooms.add(room);
    return room;
  }

  /// Replaces the room with [roomId] using the provided values.
  void update({
    required int roomId,
    required String number,
    required String viewType,
    required String capacity,
    required double pricePerNight,
    required bool isAvailable,
    String imageUrl = '',
    List<String> amenities = const [],
  }) {
    final existing = getById(roomId);
    if (existing == null) return;
    final index = _rooms.indexOf(existing);
    _rooms[index] = Room(
      id: roomId,
      number: number,
      viewType: viewType,
      capacity: capacity,
      pricePerNight: pricePerNight,
      isAvailable: isAvailable,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : existing.imageUrl,
      amenities: amenities,
    );
  }

  /// Throws if the room has active reservations.
  void delete(int roomId) {
    final hasActive = _reservations.any((res) =>
        res.roomId == roomId &&
        res.status.toLowerCase() != 'cancelled' &&
        res.status.toLowerCase() != 'checked-out');

    if (hasActive) {
      throw Exception(
        'Cannot delete room with active reservations. '
        'Cancel or complete reservations first.',
      );
    }
    _rooms.removeWhere((r) => r.id == roomId);
  }

  /// Updates only the availability flag of a room.
  void updateAvailability(int roomId, bool isAvailable) {
    final existing = getById(roomId);
    if (existing == null) return;
    final index = _rooms.indexOf(existing);
    _rooms[index] = Room(
      id: roomId,
      number: existing.number,
      viewType: existing.viewType,
      capacity: existing.capacity,
      pricePerNight: existing.pricePerNight,
      isAvailable: isAvailable,
      imageUrl: existing.imageUrl,
      amenities: existing.amenities,
    );
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  bool _hasDateConflict(int roomId, DateTime checkIn, DateTime checkOut) {
    for (final res in _reservations) {
      if (res.roomId == roomId &&
          res.status.toLowerCase() != 'cancelled' &&
          res.status.toLowerCase() != 'checked-out') {
        if (_datesOverlap(res.checkIn, res.checkOut, checkIn, checkOut)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _datesOverlap(
    DateTime start1, DateTime end1,
    DateTime start2, DateTime end2,
  ) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }
}
