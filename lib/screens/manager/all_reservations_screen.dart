import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/guest.dart';
import '../../models/reservation.dart';
import '../../models/room.dart';
import '../../providers/reservation_provider.dart';
import '../../services/hotel_service.dart';

class AllReservationsScreen extends StatefulWidget {
  @override
  State<AllReservationsScreen> createState() => _AllReservationsScreenState();
}

class _AllReservationsScreenState extends State<AllReservationsScreen> {
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  // Filter states
  String _selectedFilter = 'all'; // all, confirmed, checked-in, checked-out, cancelled
  String _selectedSort = 'newest'; // newest, oldest, guest_name, room_number, price
  String _searchQuery = '';

  // Filter options
  final List<Map<String, dynamic>> _filterOptions = [
    {'value': 'all', 'label': 'All Reservations'},
    {'value': 'confirmed', 'label': 'Confirmed'},
    {'value': 'checked-in', 'label': 'Checked-in'},
    {'value': 'checked-out', 'label': 'Checked-out'},
    {'value': 'cancelled', 'label': 'Cancelled'},
  ];

  final List<Map<String, dynamic>> _sortOptions = [
    {'value': 'newest', 'label': 'Newest First'},
    {'value': 'oldest', 'label': 'Oldest First'},
    {'value': 'guest_name', 'label': 'Guest Name (A-Z)'},
    {'value': 'room_number', 'label': 'Room Number'},
    {'value': 'price', 'label': 'Total Price'},
  ];

  // Status options for editing
  final List<String> _statusOptions = ['Confirmed', 'Checked-in', 'Checked-out', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    final reservations = context.watch<ReservationProvider>().allReservations;
    final service = HotelService();

    // Filter and sort reservations
    List<Reservation> filteredReservations = _getFilteredReservations(reservations, service);

    return Scaffold(
      appBar: AppBar(
        title: Text('All Reservations'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter & Sort',
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _exportReservations(context, filteredReservations, service),
            tooltip: 'Export',
          ),
        ],
      ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by guest name or room number...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            // Reservations count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredReservations.length} reservation${filteredReservations.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Sorted by: ${_sortOptions.firstWhere((s) => s['value'] == _selectedSort)['label']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Reservations list
            Expanded(
              child: filteredReservations.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 80, color: Colors.grey[300]),
                    SizedBox(height: 16),
                    Text(
                      'No reservations found',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    Text(
                      'Try adjusting your filters',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredReservations.length,
                itemBuilder: (ctx, i) {
                  final reservation = filteredReservations[i];
                  final guest = service.getGuestById(reservation.guestId);
                  final room = service.getRoomById(reservation.roomId);

                  return _buildReservationCard(
                    context,
                    reservation,
                    guest,
                    room,
                  );
                },
              ),
            ),
          ],
        ),);
  }

  List<Reservation> _getFilteredReservations(List<Reservation> reservations, HotelService service) {
    List<Reservation> filtered = reservations;

    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((r) => r.status.toLowerCase() == _selectedFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((reservation) {
        final guest = service.getGuestById(reservation.guestId);
        final room = service.getRoomById(reservation.roomId);

        final guestName = guest?.name?.toLowerCase() ?? '';
        final roomNumber = room?.number?.toLowerCase() ?? '';

        return guestName.contains(_searchQuery) ||
            roomNumber.contains(_searchQuery) ||
            reservation.id.toString().contains(_searchQuery);
      }).toList();
    }

    // Apply sorting
    filtered = _sortReservations(filtered, service);

    return filtered;
  }

  List<Reservation> _sortReservations(List<Reservation> reservations, HotelService service) {
    List<Reservation> sorted = List.from(reservations);

    switch (_selectedSort) {
      case 'newest':
        sorted.sort((a, b) => b.checkIn.compareTo(a.checkIn));
        break;
      case 'oldest':
        sorted.sort((a, b) => a.checkIn.compareTo(b.checkIn));
        break;
      case 'guest_name':
        sorted.sort((a, b) {
          final guestA = service.getGuestById(a.guestId);
          final guestB = service.getGuestById(b.guestId);
          final nameA = guestA?.name?.toLowerCase() ?? '';
          final nameB = guestB?.name?.toLowerCase() ?? '';
          return nameA.compareTo(nameB);
        });
        break;
      case 'room_number':
        sorted.sort((a, b) {
          final roomA = service.getRoomById(a.roomId);
          final roomB = service.getRoomById(b.roomId);
          final numA = roomA?.number ?? '';
          final numB = roomB?.number ?? '';
          return numA.compareTo(numB);
        });
        break;
      case 'price':
        sorted.sort((a, b) {
          final roomA = service.getRoomById(a.roomId);
          final roomB = service.getRoomById(b.roomId);
          final nightsA = a.checkOut.difference(a.checkIn).inDays;
          final nightsB = b.checkOut.difference(b.checkIn).inDays;
          final priceA = (roomA?.pricePerNight ?? 0) * nightsA;
          final priceB = (roomB?.pricePerNight ?? 0) * nightsB;
          return priceB.compareTo(priceA); // Highest first
        });
        break;
    }

    return sorted;
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter & Sort Reservations'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter by Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _filterOptions.map((filter) {
                        final isSelected = _selectedFilter == filter['value'];
                        return ChoiceChip(
                          label: Text(filter['label']),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected ? filter['value'] as String : 'all';
                            });
                          },
                          selectedColor: Colors.indigo,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 24),

                    Text(
                      'Sort by',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Column(
                      children: _sortOptions.map((sort) {
                        final isSelected = _selectedSort == sort['value'];
                        return RadioListTile<String>(
                          title: Text(sort['label']),
                          value: sort['value'] as String,
                          groupValue: _selectedSort,
                          onChanged: (value) {
                            setState(() {
                              _selectedSort = value!;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'all';
                      _selectedSort = 'newest';
                      _searchQuery = '';
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Clear All'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() {}); // Refresh the UI
    });
  }

  void _exportReservations(BuildContext context, List<Reservation> reservations, HotelService service) {
    if (reservations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No reservations to export')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Reservations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export ${reservations.length} reservation${reservations.length != 1 ? 's' : ''} as:'),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.text_snippet),
              title: Text('CSV Format'),
              subtitle: Text('Comma-separated values'),
              onTap: () {
                _generateCSV(reservations, service);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('CSV data copied to clipboard'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text('Summary Report'),
              subtitle: Text('Total revenue and statistics'),
              onTap: () {
                _generateSummaryReport(reservations, service);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _generateCSV(List<Reservation> reservations, HotelService service) {
    StringBuffer csv = StringBuffer();

    // Header
    csv.writeln('ID,Guest Name,Room Number,Room Type,Check-in,Check-out,Nights,Price/Night,Total Price,Status');

    // Data
    for (var reservation in reservations) {
      final guest = service.getGuestById(reservation.guestId);
      final room = service.getRoomById(reservation.roomId);
      final nights = reservation.checkOut.difference(reservation.checkIn).inDays;
      final totalPrice = (room?.pricePerNight ?? 0) * nights;

      csv.writeln('${reservation.id},'
          '"${guest?.name ?? "Unknown"}",'
          '${room?.number ?? "Unknown"},'
          '${room?.viewType ?? "Unknown"},'
          '${_dateFormat.format(reservation.checkIn)},'
          '${_dateFormat.format(reservation.checkOut)},'
          '$nights,'
          '${room?.pricePerNight.toStringAsFixed(0)},'
          '${totalPrice.toStringAsFixed(0)},'
          '${reservation.status}');
    }

    // Copy to clipboard (in real app, you would use clipboard package)
    print('CSV Data:\n$csv'); // For demo purposes
  }

  void _generateSummaryReport(List<Reservation> reservations, HotelService service) {
    double totalRevenue = 0;
    int totalNights = 0;
    Map<String, int> statusCount = {};
    Map<String, double> roomTypeRevenue = {};

    for (var reservation in reservations) {
      final room = service.getRoomById(reservation.roomId);
      final nights = reservation.checkOut.difference(reservation.checkIn).inDays;
      final revenue = (room?.pricePerNight ?? 0) * nights;

      totalRevenue += revenue;
      totalNights += nights;

      // Count by status
      statusCount[reservation.status] = (statusCount[reservation.status] ?? 0) + 1;

      // Revenue by room type
      if (room != null) {
        roomTypeRevenue[room.viewType] = (roomTypeRevenue[room.viewType] ?? 0) + revenue;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reservations Summary'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Summary Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Statistics
              _buildStatRow('Total Reservations', '${reservations.length}'),
              _buildStatRow('Total Nights', '$totalNights'),
              _buildStatRow('Total Revenue', 'Dollar ${totalRevenue.toStringAsFixed(0)}'),
              _buildStatRow('Average per Reservation', 'Dollar ${(totalRevenue / reservations.length).toStringAsFixed(0)}'),

              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),

              // Status breakdown
              Text('Status Breakdown', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              ...statusCount.entries.map((entry) =>
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('${entry.value} (${((entry.value / reservations.length) * 100).toStringAsFixed(1)}%)'),
                      ],
                    ),
                  )
              ).toList(),

              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),

              // Revenue by room type
              Text('Revenue by Room Type', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              ...roomTypeRevenue.entries.map((entry) =>
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('Dollar ${entry.value.toStringAsFixed(0)}'),
                      ],
                    ),
                  )
              ).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Save or share report
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Report saved')),
              );
            },
            child: Text('Save Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildReservationCard(
      BuildContext context,
      Reservation reservation,
      Guest? guest,
      Room? room,
      ) {
    final nights = reservation.checkOut.difference(reservation.checkIn).inDays;
    final totalPrice = (room?.pricePerNight ?? 0) * nights;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Reservation #${reservation.id}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reservation.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(reservation.status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    reservation.status,
                    style: TextStyle(
                      color: _getStatusColor(reservation.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildReservationDetail(
                    icon: Icons.person,
                    title: 'Guest',
                    value: guest?.name ?? 'Unknown',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildReservationDetail(
                    icon: Icons.meeting_room,
                    title: 'Room',
                    value: room != null ? '${room.number} (${room.viewType})' : 'Unknown',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildReservationDetail(
                    icon: Icons.calendar_today,
                    title: 'Check-in',
                    value: _dateFormat.format(reservation.checkIn),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildReservationDetail(
                    icon: Icons.calendar_today,
                    title: 'Check-out',
                    value: _dateFormat.format(reservation.checkOut),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$nights night${nights > 1 ? 's' : ''}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (room != null)
                  Text(
                    'Total: ${totalPrice.toStringAsFixed(0)} Dollar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.edit, size: 18),
                    label: Text('Edit'),
                    onPressed: () => _editReservation(context, reservation, guest, room),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.receipt, size: 18),
                    label: Text('Bill'),
                    onPressed: () => _generateBill(context, reservation, guest, room),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.delete, size: 18, color: Colors.red),
                    label: Text('Delete', style: TextStyle(color: Colors.red)),
                    onPressed: () => _deleteReservation(context, reservation, room),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationDetail({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;
      case 'checked-in':
        return Colors.green;
      case 'checked-out':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
// Helper to build status dropdown items (add to your existing methods)
  Widget _buildStatusDropdownItem(String status) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Helper to show status change confirmation
  void _showStatusChangeDialog(BuildContext context, String oldStatus, String newStatus, int reservationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Status?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change reservation status from:'),
            SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(oldStatus),
                  backgroundColor: _getStatusColor(oldStatus).withOpacity(0.2),
                  labelStyle: TextStyle(color: _getStatusColor(oldStatus)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 20),
                ),
                Chip(
                  label: Text(newStatus),
                  backgroundColor: _getStatusColor(newStatus).withOpacity(0.2),
                  labelStyle: TextStyle(color: _getStatusColor(newStatus)),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (newStatus == 'Cancelled')
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Changing to "Cancelled" will make the room available for new bookings.',
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update status using provider
              final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
              reservationProvider.updateReservationStatus(reservationId, newStatus);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Status updated to $newStatus'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
  void _editReservation(BuildContext context, Reservation reservation, Guest? guest, Room? room) {
    final service = HotelService();
    String selectedStatus = reservation.status;
    DateTime checkInDate = reservation.checkIn;
    DateTime checkOutDate = reservation.checkOut;
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Reservation #${reservation.id}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Guest Info
                    _buildDetailRow('Guest:', guest?.name ?? 'Unknown'),
                    SizedBox(height: 8),

                    // Room Info
                    _buildDetailRow('Room:', '${room?.number ?? 'Unknown'} (${room?.viewType ?? 'Unknown'})'),
                    SizedBox(height: 8),

                    // Price Info
                    if (room != null)
                      _buildDetailRow('Price/Night:', '${room.pricePerNight.toStringAsFixed(0)} Dollar'),
                    SizedBox(height: 8),

                    Divider(),
                    SizedBox(height: 16),

                    // Status Selection
                    Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(status),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                      isExpanded: true,
                    ),
                    SizedBox(height: 16),

                    // Date Selection
                    Text('Dates:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),

                    // Check-in Date
                    ListTile(
                      leading: Icon(Icons.calendar_today, color: Colors.blue),
                      title: Text('Check-in Date'),
                      subtitle: Text(_dateFormat.format(checkInDate)),
                      trailing: Icon(Icons.edit),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: checkInDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null && picked != checkInDate) {
                          setState(() {
                            checkInDate = picked;
                            // Ensure check-out is after check-in
                            if (checkOutDate.isBefore(picked) || checkOutDate.isAtSameMomentAs(picked)) {
                              checkOutDate = picked.add(Duration(days: 1));
                            }
                          });
                        }
                      },
                    ),

                    // Check-out Date
                    ListTile(
                      leading: Icon(Icons.calendar_today, color: Colors.red),
                      title: Text('Check-out Date'),
                      subtitle: Text(_dateFormat.format(checkOutDate)),
                      trailing: Icon(Icons.edit),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: checkOutDate,
                          firstDate: checkInDate.add(Duration(days: 1)),
                          lastDate: DateTime.now().add(Duration(days: 730)),
                        );
                        if (picked != null && picked != checkOutDate) {
                          setState(() {
                            checkOutDate = picked;
                          });
                        }
                      },
                    ),

                    // Nights calculation
                    if (room != null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Nights:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${checkOutDate.difference(checkInDate).inDays} nights'),
                            ],
                          ),
                        ),
                      ),

                    // Total Price Preview
                    if (room != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Price:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${(room.pricePerNight * checkOutDate.difference(checkInDate).inDays).toStringAsFixed(0)} Dollar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Status change warning
                    if (selectedStatus != reservation.status)
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(selectedStatus).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getStatusColor(selectedStatus).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(selectedStatus),
                                color: _getStatusColor(selectedStatus),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getStatusMessage(selectedStatus, reservation.status),
                                  style: TextStyle(
                                    color: _getStatusColor(selectedStatus),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Room availability notice for specific status changes
                    if ((selectedStatus == 'Cancelled' || selectedStatus == 'Checked-out') &&
                        room != null &&
                        !room.isAvailable)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Changing to "${selectedStatus}" will make Room ${room.number} available again',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validate dates
                    if (checkOutDate.isBefore(checkInDate) || checkOutDate.isAtSameMomentAs(checkInDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Check-out date must be after check-in date'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    bool changesMade = false;

                    // Update status if changed
                    if (selectedStatus != reservation.status) {
                      reservationProvider.updateReservationStatus(reservation.id, selectedStatus);
                      changesMade = true;
                    }

                    // Update dates if changed
                    if (checkInDate != reservation.checkIn || checkOutDate != reservation.checkOut) {
                      reservationProvider.updateReservationDates(reservation.id, checkInDate, checkOutDate);
                      changesMade = true;
                    }

                    Navigator.pop(context);

                    if (changesMade) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reservation updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Helper method for detail rows
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

// Helper method to get status icon
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'checked-in':
        return Icons.hotel;
      case 'checked-out':
        return Icons.exit_to_app;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

// Helper method to get status change message
  String _getStatusMessage(String newStatus, String oldStatus) {
    final messages = {
      'Confirmed': 'Setting reservation as confirmed',
      'Checked-in': 'Guest is checking in now',
      'Checked-out': 'Guest has checked out',
      'Cancelled': 'Reservation has been cancelled',
    };

    return messages[newStatus] ?? 'Status changed from $oldStatus to $newStatus';
  }  void _generateBill(BuildContext context, Reservation reservation, Guest? guest, Room? room) {
    final nights = reservation.checkOut.difference(reservation.checkIn).inDays;
    final totalPrice = (room?.pricePerNight ?? 0) * nights;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invoice - Reservation #${reservation.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guest: ${guest?.name ?? "Unknown"}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Room: ${room?.number ?? "Unknown"} (${room?.viewType ?? "Unknown"})'),
              SizedBox(height: 8),
              Text('Check-in: ${_dateFormat.format(reservation.checkIn)}'),
              Text('Check-out: ${_dateFormat.format(reservation.checkOut)}'),
              SizedBox(height: 8),
              Divider(),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${nights} night${nights > 1 ? 's' : ''}'),
                  Text('Dollar ${room?.pricePerNight.toStringAsFixed(0) ?? "0"} / night'),
                ],
              ),
              SizedBox(height: 8),
              Divider(),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Dollar ${totalPrice.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[700])),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Print or save bill
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bill generated successfully')),
              );
            },
            child: Text('Print Bill'),
          ),
        ],
      ),
    );
  }

  void _deleteReservation(BuildContext context, Reservation reservation, Room? room) {
    final service = HotelService();
    final guest = service.getGuestById(reservation.guestId);
    final nights = reservation.checkOut.difference(reservation.checkIn).inDays;
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Reservation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this reservation?'),
            SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reservation #${reservation.id}', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Guest: ${guest?.name ?? "Unknown"}'),
                  Text('Room: ${room?.number ?? "Unknown"}'),
                  Text('Dates: ${_dateFormat.format(reservation.checkIn)} - ${_dateFormat.format(reservation.checkOut)}'),
                  Text('Status: ${reservation.status}'),
                  SizedBox(height: 4),
                  Text(
                    'Total: Dollar ${((room?.pricePerNight ?? 0) * nights).toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            if (reservation.status != 'Cancelled')
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Deleting will make Room ${room?.number ?? ""} available again',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete reservation using provider
              reservationProvider.deleteReservation(reservation.id);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reservation deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete Reservation'),
          ),
        ],
      ),
    );
  }}