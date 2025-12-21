import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/guest.dart';
import '../../models/room.dart';
import '../../providers/reservation_provider.dart';
import 'add_guest_dialog.dart';
import 'date_range_dialog.dart';

class RoomDetailsSheet extends StatefulWidget {
  final Room room;
  final Map<String, dynamic>? currentFilters;
  final Function(Map<String, dynamic>)? onFiltersChanged;
  final VoidCallback? onBookNow;
  final VoidCallback? onApplyFilters;

  // Updated constructor with optional parameters
  RoomDetailsSheet({
    required this.room,
    this.currentFilters,
    this.onFiltersChanged,
    this.onBookNow,
    this.onApplyFilters,
  });

  @override
  State<RoomDetailsSheet> createState() => _RoomDetailsSheetState();
}

class _RoomDetailsSheetState extends State<RoomDetailsSheet> {
  late Map<String, dynamic> _filters;

  final List<String> _roomTypes = ['All', 'Nile View', 'Suite', 'Regular'];
  final Map<String, String> _capacityMap = {
    'Single': '1 Person',
    'Double': '2 People',
    'Triple': '3 People',
  };

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters ?? {
      'viewType': null,
      'priceRange': RangeValues(0, 5000),
      'showAvailableOnly': true,
      'capacity': null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Room details section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Room ${widget.room.number}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRoomTypeColor(widget.room.viewType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.room.viewType,
                    style: TextStyle(
                      color: _getRoomTypeColor(widget.room.viewType),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Room image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage("assets/room.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Room info cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    width: 120,
                    child: _buildDetailItem(
                      icon: Icons.king_bed,
                      title: widget.room.viewType,
                      subtitle: 'View Type',
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    width: 120,
                    child: _buildDetailItem(
                      icon: Icons.people,
                      title: widget.room.capacity,
                      subtitle: 'Capacity',
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    width: 120,
                    child: _buildDetailItem(
                      icon: Icons.attach_money,
                      title: '${widget.room.pricePerNight.toStringAsFixed(0)}',
                      subtitle: 'Dollar / Night',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Status
            Row(
              children: [
                Icon(
                  widget.room.isAvailable ? Icons.check_circle : Icons.cancel,
                  color: widget.room.isAvailable ? Colors.green : Colors.red,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  widget.room.isAvailable ? 'Available for booking' : 'Currently Unavailable',
                  style: TextStyle(
                    color: widget.room.isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 10),

            // Amenities
            Text(
              'Service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),

            if (widget.room.amenities.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.room.amenities.map((amenity) {
                  IconData icon = _getAmenityIcon(amenity);
                  return Chip(
                    avatar: Icon(icon, size: 16),
                    label: Text(amenity),
                    backgroundColor: Colors.indigo[50],
                    labelPadding: EdgeInsets.symmetric(horizontal: 8),
                  );
                }).toList(),
              )
            else
              Text(
                'No amenities listed',
                style: TextStyle(color: Colors.grey),
              ),

            SizedBox(height: 30),

            // Book button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ()=> _startReservation(context,widget.room),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Book This Room',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            // Close button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.indigo),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getRoomTypeColor(String viewType) {
    switch (viewType.toLowerCase()) {
      case 'suite': return Colors.purple;
      case 'nile view': return Colors.blue;
      default: return Colors.green;
    }
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi': return Icons.wifi;
      case 'tv': return Icons.tv;
      case 'ac': return Icons.ac_unit;
      case 'mini bar': return Icons.local_bar;
      case 'safe': return Icons.lock;
      case 'bathroom': return Icons.bathtub;
      case 'room service': return Icons.room_service;
      case 'balcony': return Icons.balcony;
      default: return Icons.check;
    }
  }

  void _showBookConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Room ${widget.room.number}'),
        content: Text(
          'Would you like to proceed with booking Room ${widget.room.number}?\n\n'
              'View: ${widget.room.viewType}\n'
              'Capacity: ${widget.room.capacity}\n'
              'Price: ${widget.room.pricePerNight.toStringAsFixed(0)} Dollar per night',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // You can add your booking logic here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Proceeding to booking for Room ${widget.room.number}'),
                ),
              );
            },
            child: Text('Book Now'),
          ),
        ],
      ),
    );
  }
  void _startReservation(BuildContext context, Room room) async {
    // First select dates with availability check
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => DateRangeDialog(roomId: room.id),
    );

    if (result == null) return;

    final checkIn = result['in']! as DateTime;
    final checkOut = result['out']! as DateTime;
    final isAvailable = result['isAvailable'] as bool? ?? true;

    // Show warning if not available
    if (!isAvailable) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Room Not Available'),
          content: Text(
            'Room ${room.number} is already booked for some or all of the selected dates. '
                'Do you want to try different dates?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Change Dates'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Try again with new dates
        _startReservation(context, room);
      }
      return;
    }

    // Get guest info
    final guest = await showDialog<Guest>(
      context: context,
      builder: (ctx) => AddGuestDialog(),
    );

    if (guest == null) return;

    try {
      await context.read<ReservationProvider>().reserve(
        guest.id,
        room.id,
        checkIn,
        checkOut,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Room ${room.number} booked successfully!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}