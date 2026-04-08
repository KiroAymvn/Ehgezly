// features/rooms/cubit/room_cubit.dart
import 'package:database_project/models/room.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/hotel_service.dart';
import 'room_state.dart';

class RoomCubit extends Cubit<RoomState> {
  final HotelService _service = HotelService();

  RoomCubit() : super(RoomInitial());

  List<Room> get allRooms => state is RoomLoaded ? (state as RoomLoaded).rooms : _service.rooms;
  List<Room> get availableRooms => state is RoomLoaded ? (state as RoomLoaded).availableRooms : _service.availableRooms;

  void loadRooms() {
    emit(RoomLoaded(_service.rooms, _service.availableRooms));
  }

  Future<void> toggleAvailability(int roomId, bool available) async {
    try {
      await _service.updateRoomAvailability(roomId, available);
      loadRooms();
    } catch (e) {
      emit(RoomError(e.toString()));
      loadRooms(); // Revert back to loaded state after error emit
    }
  }

  Future<void> addRoom({
    required String number,
    required String viewType,
    required String capacity,
    required double pricePerNight,
    String imageUrl = '',
    List<String> amenities = const [],
  }) async {
    try {
      await _service.addRoom(
        number: number,
        viewType: viewType,
        capacity: capacity,
        pricePerNight: pricePerNight,
        imageUrl: imageUrl,
        amenities: amenities,
      );
      loadRooms();
    } catch (e) {
      emit(RoomError(e.toString()));
      loadRooms();
    }
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
    try {
      await _service.updateRoom(
        roomId: roomId,
        number: number,
        viewType: viewType,
        capacity: capacity,
        pricePerNight: pricePerNight,
        isAvailable: isAvailable,
        imageUrl: imageUrl,
        amenities: amenities,
      );
      loadRooms();
    } catch (e) {
      emit(RoomError(e.toString()));
      loadRooms();
    }
  }

  Future<void> deleteRoom(int roomId) async {
    try {
      await _service.deleteRoom(roomId);
      loadRooms();
    } catch (e) {
      emit(RoomError(e.toString()));
      loadRooms();
    }
  }
}

