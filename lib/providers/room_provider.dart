// providers/room_provider.dart
//
// State management for Rooms. Delegates all data operations to HotelService
// and notifies listeners so the UI rebuilds automatically.

import 'package:flutter/foundation.dart';
import '../models/room.dart';
import '../services/hotel_service.dart';

class RoomProvider with ChangeNotifier {
  final HotelService _service = HotelService();

  List<Room> get allRooms      => _service.rooms;
  List<Room> get availableRooms => _service.availableRooms;

  Future<void> toggleAvailability(int roomId, bool available) async {
    await _service.updateRoomAvailability(roomId, available);
    notifyListeners();
  }

  Future<void> addRoom(
    String number,
    String viewType,
    String capacity,
    double pricePerNight, {
    String imageUrl = '',
    List<String> amenities = const [],
  }) async {
    await _service.addRoom(
      number: number, viewType: viewType, capacity: capacity,
      pricePerNight: pricePerNight, imageUrl: imageUrl, amenities: amenities,
    );
    notifyListeners();
  }

  Future<void> updateRoom({
    required int roomId,
    required String number,
    required String viewType,
    required String capacity,
    required double pricePerNight,
    required bool isAvailable,
    String imageUrl = '',
    List<String> amenities = const [],
  }) async {
    await _service.updateRoom(
      roomId: roomId, number: number, viewType: viewType, capacity: capacity,
      pricePerNight: pricePerNight, isAvailable: isAvailable,
      imageUrl: imageUrl, amenities: amenities,
    );
    notifyListeners();
  }

  Future<void> deleteRoom(int roomId) async {
    await _service.deleteRoom(roomId);
    notifyListeners();
  }
}
