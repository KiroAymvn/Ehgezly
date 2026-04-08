// models/reservation.dart
//
// Reservation entity with Hive TypeAdapter support.
// TypeId = 2 — must be unique across all Hive models.

import 'package:hive/hive.dart';

part 'reservation.g.dart';

@HiveType(typeId: 2)
class Reservation extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int guestId;

  @HiveField(2)
  final int roomId;

  @HiveField(3)
  final DateTime checkIn;

  @HiveField(4)
  final DateTime checkOut;

  @HiveField(5)
  final String status; // Confirmed, Checked-in, Checked-out, Cancelled

  Reservation({
    required this.id,
    required this.guestId,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    this.status = 'Confirmed',
  });

  // Converts this reservation to a JSON-compatible map
  Map<String, dynamic> toJson() => {
    'id': id,
    'guestId': guestId,
    'roomId': roomId,
    'checkIn': checkIn.toIso8601String(),
    'checkOut': checkOut.toIso8601String(),
    'status': status,
  };

  // Creates a Reservation from a JSON map
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      guestId: json['guestId'],
      roomId: json['roomId'],
      checkIn: DateTime.parse(json['checkIn']),
      checkOut: DateTime.parse(json['checkOut']),
      status: json['status'],
    );
  }
}