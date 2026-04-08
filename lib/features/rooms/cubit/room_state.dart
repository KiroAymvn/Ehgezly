// features/rooms/cubit/room_state.dart
import '../../../models/room.dart';

abstract class RoomState {}

class RoomInitial extends RoomState {}

class RoomLoaded extends RoomState {
  final List<Room> rooms;
  final List<Room> availableRooms;

  RoomLoaded(this.rooms, this.availableRooms);
}

class RoomError extends RoomState {
  final String message;

  RoomError(this.message);
}
