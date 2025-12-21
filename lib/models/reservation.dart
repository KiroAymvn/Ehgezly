// models/reservation.dart
class Reservation {
  final int id;
  final int guestId;
  final int roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final String status; // Confirmed, Checked-in, Checked-out, Cancelled

  Reservation({
    required this.id,
    required this.guestId,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    this.status = 'Confirmed',
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'guestId': guestId,
    'roomId': roomId,
    'checkIn': checkIn.toIso8601String(),
    'checkOut': checkOut.toIso8601String(),
    'status': status,
  };

  // Create from JSON
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