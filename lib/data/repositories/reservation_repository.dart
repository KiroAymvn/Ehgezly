// data/repositories/reservation_repository.dart
//
// Handles all CRUD operations for Reservation entities,
// including date-overlap validation.

import '../../models/reservation.dart';

class ReservationRepository {
  final List<Reservation> _reservations;

  const ReservationRepository({required List<Reservation> reservations})
      : _reservations = reservations;

  // ── Queries ────────────────────────────────────────────────────────────────

  List<Reservation> get all => List.unmodifiable(_reservations);

  Reservation? getById(int id) {
    try {
      return _reservations.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Reservation> getForGuest(int guestId) =>
      _reservations.where((r) => r.guestId == guestId).toList();

  List<Reservation> getForRoom(int roomId) =>
      _reservations.where((r) => r.roomId == roomId).toList();

  // ── Mutations ──────────────────────────────────────────────────────────────

  /// Creates a new reservation. Validates dates and checks for conflicts using
  /// [hasConflict] — a closure provided by [HotelService] (avoids circular dep).
  Reservation add({
    required int newId,
    required int guestId,
    required int roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required bool Function(int roomId, DateTime ci, DateTime co) hasConflict,
  }) {
    if (checkOut.isBefore(checkIn) || checkOut.isAtSameMomentAs(checkIn)) {
      throw Exception('Check-out date must be after check-in date');
    }
    if (hasConflict(roomId, checkIn, checkOut)) {
      throw Exception(
        'Room already booked for selected dates. Please choose different dates.',
      );
    }

    final reservation = Reservation(
      id: newId,
      guestId: guestId,
      roomId: roomId,
      checkIn: checkIn,
      checkOut: checkOut,
      status: 'Confirmed',
    );
    _reservations.add(reservation);
    return reservation;
  }

  /// Updates only the status field of a reservation.
  Reservation? updateStatus(int reservationId, String newStatus) {
    final existing = getById(reservationId);
    if (existing == null) return null;
    final index = _reservations.indexOf(existing);
    final updated = Reservation(
      id: existing.id,
      guestId: existing.guestId,
      roomId: existing.roomId,
      checkIn: existing.checkIn,
      checkOut: existing.checkOut,
      status: newStatus,
    );
    _reservations[index] = updated;
    return updated;
  }

  /// Updates check-in and check-out dates, re-validating for conflicts.
  /// [hasConflict] should exclude the current reservation from its check.
  void updateDates({
    required int reservationId,
    required DateTime newCheckIn,
    required DateTime newCheckOut,
    required bool Function(int roomId, DateTime ci, DateTime co, int excludeId)
        hasConflict,
  }) {
    final existing = getById(reservationId);
    if (existing == null) return;

    if (newCheckOut.isBefore(newCheckIn) ||
        newCheckOut.isAtSameMomentAs(newCheckIn)) {
      throw Exception('Check-out date must be after check-in date');
    }

    if (hasConflict(existing.roomId, newCheckIn, newCheckOut, reservationId)) {
      throw Exception(
        'New dates conflict with an existing reservation for this room',
      );
    }

    final index = _reservations.indexOf(existing);
    _reservations[index] = Reservation(
      id: existing.id,
      guestId: existing.guestId,
      roomId: existing.roomId,
      checkIn: newCheckIn,
      checkOut: newCheckOut,
      status: existing.status,
    );
  }

  /// Returns the reservation that was deleted, or null if not found.
  Reservation? delete(int reservationId) {
    final existing = getById(reservationId);
    if (existing == null) return null;
    _reservations.removeWhere((r) => r.id == reservationId);
    return existing;
  }
}
