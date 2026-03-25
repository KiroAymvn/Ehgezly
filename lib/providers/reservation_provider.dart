// providers/reservation_provider.dart
//
// State management for Reservations. Delegates all data operations to HotelService
// and notifies listeners so the UI rebuilds automatically.

import 'package:flutter/foundation.dart';
import '../models/reservation.dart';
import '../services/hotel_service.dart';

class ReservationProvider with ChangeNotifier {
  final HotelService _service = HotelService();

  List<Reservation> get allReservations => _service.reservations;

  Future<void> reserve(
    int guestId, int roomId, DateTime checkIn, DateTime checkOut,
  ) async {
    await _service.addReservation(
      guestId: guestId, roomId: roomId, checkIn: checkIn, checkOut: checkOut,
    );
    notifyListeners();
  }

  Future<void> updateStatus(int reservationId, String newStatus) async {
    await _service.updateReservationStatus(reservationId, newStatus);
    notifyListeners();
  }

  Future<void> updateDates(
    int reservationId, DateTime newCheckIn, DateTime newCheckOut,
  ) async {
    await _service.updateReservationDates(
      reservationId: reservationId,
      newCheckIn: newCheckIn,
      newCheckOut: newCheckOut,
    );
    notifyListeners();
  }

  Future<void> deleteReservation(int reservationId) async {
    await _service.deleteReservation(reservationId);
    notifyListeners();
  }
}