// providers/guest_provider.dart
import 'package:flutter/cupertino.dart';
import '../models/guest.dart';
import '../services/hotel_service.dart';

class GuestProvider with ChangeNotifier {
  final HotelService _service = HotelService();

  List<Guest> get allGuests => _service.guests;

  Future<void> addGuest(String name, String phone,
      {String email = '', DateTime? birthday}) async {  // Add birthday parameter
    await _service.addGuest(
      name: name,
      phone: phone,
      email: email,
      birthday: birthday,  // Pass birthday
    );
    notifyListeners();
  }

  Future<void> updateGuest(int guestId, String name, String phone,
      {String email = '', DateTime? birthday}) async {  // Add birthday parameter
    await _service.updateGuest(
      guestId: guestId,
      name: name,
      phone: phone,
      email: email,
      birthday: birthday,  // Pass birthday
    );
    notifyListeners();
  }

  Future<void> deleteGuest(int guestId) async {
    await _service.deleteGuest(guestId);
    notifyListeners();
  }
}