import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/guest.dart';
import '../../models/reservation.dart';
import '../../models/room.dart';
import '../../providers/guest_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/room__provider.dart';
import '../../services/hotel_service.dart';
// Update DateRangeDialog to check availability
class DateRangeDialog extends StatefulWidget {
  final int? roomId; // Optional: Check specific room

  DateRangeDialog({this.roomId});

  @override
  State<DateRangeDialog> createState() => _DateRangeDialogState();
}

class _DateRangeDialogState extends State<DateRangeDialog> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  bool _checkingAvailability = false;
  String? _availabilityMessage;
  bool? _isAvailable;

  @override
  Widget build(BuildContext context) {
    final service = HotelService();
    final nights = _checkIn != null && _checkOut != null
        ? _checkOut!.difference(_checkIn!).inDays
        : 0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Dates',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),

            _buildDateCard(
              title: 'Check-in Date',
              date: _checkIn,
              onTap: _pickCheckIn,
              isSelected: _checkIn != null,
            ),
            SizedBox(height: 12),

            _buildDateCard(
              title: 'Check-out Date',
              date: _checkOut,
              onTap: _pickCheckOut,
              isSelected: _checkOut != null,
            ),

            if (_checkIn != null && _checkOut != null) ...[
              SizedBox(height: 20),

              // Availability check section
              if (_checkingAvailability)
                CircularProgressIndicator()
              else if (_availabilityMessage != null)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isAvailable == true ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isAvailable == true ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isAvailable == true ? Icons.check_circle : Icons.error,
                        color: _isAvailable == true ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _availabilityMessage!,
                          style: TextStyle(
                            color: _isAvailable == true ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 16),

              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.nightlight_round, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text(
                      '$nights night${nights > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 12),

                // Check Availability button (only when dates are selected)
                if (_checkIn != null && _checkOut != null && widget.roomId != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _checkAvailability,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Center(child: Text('Check Availability',style: TextStyle(color: Colors.white,fontSize: 10),)),
                    ),
                  ),

                SizedBox(width: widget.roomId != null ? 12 : 0),

                // Confirm button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _checkIn != null && _checkOut != null && _checkOut!.isAfter(_checkIn!)
                        ? () => Navigator.pop(
                      context,
                      {
                        'in': _checkIn!,
                        'out': _checkOut!,
                        'isAvailable': _isAvailable ?? true
                      },
                    )
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16,horizontal: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Confirm Dates',style: TextStyle(color: Colors.indigo,fontSize: 10),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _checkAvailability() async {
    if (widget.roomId == null || _checkIn == null || _checkOut == null) return;

    setState(() {
      _checkingAvailability = true;
      _availabilityMessage = null;
      _isAvailable = null;
    });

    final service = HotelService();

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    try {
      // Check if room is available
      final isAvailable = service.isRoomAvailableForDates(widget.roomId!, _checkIn!, _checkOut!);

      setState(() {
        _checkingAvailability = false;
        _isAvailable = isAvailable;
        _availabilityMessage = isAvailable
            ? 'Room is available for selected dates!'
            : 'Room is already booked for some or all of these dates.';
      });
    } catch (e) {
      setState(() {
        _checkingAvailability = false;
        _isAvailable = false;
        _availabilityMessage = 'Error checking availability: ${e.toString()}';
      });
    }
  }
  Widget _buildDateCard({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.indigo : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: isSelected ? Colors.indigo : Colors.grey,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      date != null
                          ? _dateFormat.format(date)
                          : 'Select date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.indigo : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
// ... keep existing _buildDateCard, _pickCheckIn, _pickCheckOut methods
}

  Future<void> _pickCheckIn() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _checkIn = picked;
        if (_checkOut != null && _checkOut!.isBefore(picked.add(Duration(days: 1)))) {
          _checkOut = null;
        }
      });
    }
  }

  Future<void> _pickCheckOut() async {
    final start = _checkIn ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOut ?? start.add(Duration(days: 1)),
      firstDate: start.add(Duration(days: 1)),
      lastDate: DateTime(start.year + 2),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _checkOut = picked);
  }
}
