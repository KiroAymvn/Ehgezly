// data/repositories/guest_repository.dart
//
// Handles all CRUD operations for Guest entities.

import '../../models/guest.dart';
import '../../models/reservation.dart';

class GuestRepository {
  final List<Guest> _guests;
  final List<Reservation> _reservations;

  const GuestRepository({
    required List<Guest> guests,
    required List<Reservation> reservations,
  })  : _guests = guests,
        _reservations = reservations;

  // ── Queries ────────────────────────────────────────────────────────────────

  List<Guest> get all => List.unmodifiable(_guests);

  Guest? getById(int id) {
    try {
      return _guests.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  Guest add({
    required int newId,
    required String name,
    required String phone,
    String email = '',
    DateTime? birthday,
  }) {
    final guest = Guest(
      id: newId,
      name: name,
      phone: phone,
      email: email,
      birthday: birthday,
    );
    _guests.add(guest);
    return guest;
  }

  void update({
    required int guestId,
    required String name,
    required String phone,
    String email = '',
    DateTime? birthday,
  }) {
    final existing = getById(guestId);
    if (existing == null) return;
    final index = _guests.indexOf(existing);
    _guests[index] = Guest(
      id: guestId,
      name: name,
      phone: phone,
      email: email,
      birthday: birthday,
    );
  }

  /// Deletes the guest and all their reservations.
  void delete(int guestId) {
    _guests.removeWhere((g) => g.id == guestId);
    _reservations.removeWhere((r) => r.guestId == guestId);
  }
}
