// providers/guest_provider.dart
//
// State management for Guests. Delegates all data operations to HotelService
// and notifies listeners so the UI rebuilds automatically.

import 'package:flutter/foundation.dart';
import '../models/guest.dart';
import '../services/hotel_service.dart';

class GuestProvider with ChangeNotifier {
  final HotelService _service = HotelService();

  List<Guest> get allGuests => _service.guests;

  Future<void> addGuest({
    required String name,
    required String phone,
    String email = '',
    DateTime? birthday,
  }) async {
    await _service.addGuest(
      name: name, phone: phone, email: email, birthday: birthday,
    );
    notifyListeners();
  }

  Future<void> updateGuest({
    required int guestId,
    required String name,
    required String phone,
    String email = '',
    DateTime? birthday,
  }) async {
    await _service.updateGuest(
      guestId: guestId, name: name, phone: phone, email: email, birthday: birthday,
    );
    notifyListeners();
  }

  Future<void> deleteGuest(int guestId) async {
    await _service.deleteGuest(guestId);
    notifyListeners();
  }
}