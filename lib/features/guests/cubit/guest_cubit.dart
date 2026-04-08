// features/guests/cubit/guest_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/guest.dart';
import '../../../services/hotel_service.dart';
import 'guest_state.dart';

class GuestCubit extends Cubit<GuestState> {
  final HotelService _service = HotelService();

  GuestCubit() : super(GuestInitial());

  List<Guest> get allGuests => state is GuestLoaded ? (state as GuestLoaded).guests : _service.guests;

  void loadGuests() {
    emit(GuestLoaded(_service.guests));
  }

  Future<void> addGuest({
    required String name,
    required String phone,
    String email = '',
    DateTime? birthday,
  }) async {
    try {
      await _service.addGuest(
        name: name,
        phone: phone,
        email: email,
        birthday: birthday,
      );
      loadGuests();
    } catch (e) {
      emit(GuestError(e.toString()));
      loadGuests();
    }
  }

  Future<void> updateGuest({
    required int guestId,
    required String name,
    required String phone,
    String email = '',
    DateTime? birthday,
  }) async {
    try {
      await _service.updateGuest(
        guestId: guestId,
        name: name,
        phone: phone,
        email: email,
        birthday: birthday,
      );
      loadGuests();
    } catch (e) {
      emit(GuestError(e.toString()));
      loadGuests();
    }
  }

  Future<void> deleteGuest(int guestId) async {
    try {
      await _service.deleteGuest(guestId);
      loadGuests();
    } catch (e) {
      emit(GuestError(e.toString()));
      loadGuests();
    }
  }
}

