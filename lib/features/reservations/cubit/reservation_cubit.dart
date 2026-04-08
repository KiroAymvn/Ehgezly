// features/reservations/cubit/reservation_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/reservation.dart';
import '../../../services/hotel_service.dart';
import 'reservation_state.dart';

class ReservationCubit extends Cubit<ReservationState> {
  final HotelService _service = HotelService();

  ReservationCubit() : super(ReservationInitial());

  List<Reservation> get allReservations => state is ReservationLoaded ? (state as ReservationLoaded).reservations : _service.reservations;

  void loadReservations() {
    emit(ReservationLoaded(_service.reservations));
  }

  Future<void> reserve(
    int guestId,
    int roomId,
    DateTime checkIn,
    DateTime checkOut,
  ) async {
    try {
      await _service.addReservation(
        guestId: guestId,
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
      );
      loadReservations();
    } catch (e) {
      emit(ReservationError(e.toString()));
      loadReservations();
    }
  }

  Future<void> updateStatus(int reservationId, String newStatus) async {
    try {
      await _service.updateReservationStatus(reservationId, newStatus);
      loadReservations();
    } catch (e) {
      emit(ReservationError(e.toString()));
      loadReservations();
    }
  }

  Future<void> updateDates(
    int reservationId,
    DateTime newCheckIn,
    DateTime newCheckOut,
  ) async {
    try {
      await _service.updateReservationDates(
        reservationId: reservationId,
        newCheckIn: newCheckIn,
        newCheckOut: newCheckOut,
      );
      loadReservations();
    } catch (e) {
      emit(ReservationError(e.toString()));
      loadReservations();
    }
  }

  Future<void> deleteReservation(int reservationId) async {
    try {
      await _service.deleteReservation(reservationId);
      loadReservations();
    } catch (e) {
      emit(ReservationError(e.toString()));
      loadReservations();
    }
  }
}

