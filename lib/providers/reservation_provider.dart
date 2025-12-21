// providers/reservation_provider.dart
import 'package:flutter/cupertino.dart';

import '../models/reservation.dart';
import '../services/hotel_service.dart';

class ReservationProvider with ChangeNotifier {
  final HotelService _service = HotelService();

  List<Reservation> get allReservations => _service.reservations;

  Future<void> reserve(int guestId, int roomId, DateTime checkIn, DateTime checkOut) async {
    await _service.addReservation(guestId: guestId, roomId: roomId, checkIn: checkIn, checkOut: checkOut);
    notifyListeners();
  }

  Future<void> updateReservationStatus(int reservationId, String newStatus) async {
    await _service.updateReservationStatus(reservationId, newStatus);
    notifyListeners();
  }

  Future<void> updateReservationDates(int reservationId, DateTime newCheckIn, DateTime newCheckOut) async {
    await _service.updateReservationDates(reservationId: reservationId, newCheckIn: newCheckIn, newCheckOut: newCheckOut);
    notifyListeners();
  }

  Future<void> deleteReservation(int reservationId) async {
    await _service.deleteReservation(reservationId);
    notifyListeners();
  }
}