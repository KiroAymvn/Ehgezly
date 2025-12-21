// Create a new screen: screens/room_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/room.dart';
import '../../services/hotel_service.dart';



class RoomCalendarScreen extends StatelessWidget {
  final Room room;

  RoomCalendarScreen({required this.room});

  @override
  Widget build(BuildContext context) {
    final service = HotelService();
    final reservations = service.getReservationsForRoom(room.id);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Calendar - Room ${room.number}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room info
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage("assets/room.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room ${room.number}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(room.viewType),
                          Text('${room.pricePerNight.toStringAsFixed(0)} Dollar/night'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Booking calendar
            Text(
              'Booking Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            if (reservations.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 60,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No bookings yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    final guest = service.getGuestById(reservation.guestId);
                    final nights = reservation.checkOut.difference(reservation.checkIn).inDays;

                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${dateFormat.format(reservation.checkIn)} - ${dateFormat.format(reservation.checkOut)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(reservation.status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    reservation.status,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('Guest: ${guest?.name ?? "Unknown"}'),
                            Text('Nights: $nights'),
                            Text('Total: ${(room.pricePerNight * nights).toStringAsFixed(0)} Dollar'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.blue;
      case 'checked-in': return Colors.green;
      case 'checked-out': return Colors.grey;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }
}