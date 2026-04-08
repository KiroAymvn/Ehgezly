// features/reservations/cubit/reservation_state.dart
import '../../../models/reservation.dart';

abstract class ReservationState {}

class ReservationInitial extends ReservationState {}

class ReservationLoaded extends ReservationState {
  final List<Reservation> reservations;

  ReservationLoaded(this.reservations);
}

class ReservationError extends ReservationState {
  final String message;

  ReservationError(this.message);
}
