import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_provider.dart';
import '../../models/guest.dart';
import '../../models/reservation.dart';
import '../../models/room.dart';
import '../../providers/guest_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/room__provider.dart';
import '../../services/hotel_service.dart';
import 'add_guest_simple_dialog.dart';
import 'dashboard_card.dart';
// screens/manager/manager_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/guest_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../services/hotel_service.dart';
import 'add_guest_simple_dialog.dart';
import 'dashboard_card.dart';

class ManagerHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<RoomProvider>().allRooms;
    final guests = context.watch<GuestProvider>().allGuests;
    final reservations = context.watch<ReservationProvider>().allReservations;
    final service = HotelService();
    final revenue = service.calculateExpectedRevenue();
    final employees = context.watch<EmployeeProvider>().allEmployees;

    final List<DashboardCard> cards = [
      DashboardCard(
        title: 'Employees',
        count: employees.length.toString(),
        subtitle: 'Staff members',
        icon: Icons.badge,
        color: Colors.teal,
        route: '/manager/employees',
      ),
      DashboardCard(
        title: 'Rooms',
        count: rooms.length.toString(),
        subtitle: '${rooms.where((r) => r.isAvailable).length} available',
        icon: Icons.meeting_room,
        color: Colors.blue,
        route: '/manager/rooms',
      ),
      DashboardCard(
        title: 'Guests',
        count: guests.length.toString(),
        subtitle: 'Registered guests',
        icon: Icons.people,
        color: Colors.green,
        route: '/manager/guests',
      ),
      DashboardCard(
        title: 'Reservations',
        count: reservations.length.toString(),
        subtitle: 'Current bookings',
        icon: Icons.book_online,
        color: Colors.purple,
        route: '/manager/reservations',
      ),
      DashboardCard(
        title: 'Revenue',
        count: 'Dollar ${revenue.toStringAsFixed(0)}',
        subtitle: 'Expected revenue',
        icon: Icons.attach_money,
        color: Colors.orange,
        route: '',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Manager Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<RoomProvider>().notifyListeners();
              context.read<GuestProvider>().notifyListeners();
              context.read<ReservationProvider>().notifyListeners();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => cards[index],
                  childCount: cards.length,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _buildQuickActions(context),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: _buildRecentActivity(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  icon: Icons.add,
                  label: 'Add Guest',
                  onTap: () => _addGuest(context),
                ),
                _buildActionButton(
                  icon: Icons.bed,
                  label: 'Check In',
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.exit_to_app,
                  label: 'Check Out',
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.receipt,
                  label: 'Generate Bill',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.indigo[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo[100]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.indigo),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.indigo[800],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final reservations = context.watch<ReservationProvider>().allReservations;
    final service = HotelService();

    // Get recent reservations (last 3)
    final recentReservations = reservations.length > 3
        ? reservations.sublist(0, 3)
        : reservations;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (recentReservations.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No recent activity',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              Column(
                children: recentReservations.map((reservation) {
                  final guest = service.getGuestById(reservation.guestId);
                  final room = service.getRoomById(reservation.roomId);

                  return _buildActivityItem(
                    icon: _getStatusIcon(reservation.status),
                    title: room != null ? 'Room ${room.number} ${reservation.status}' : 'Reservation ${reservation.status}',
                    subtitle: guest != null
                        ? 'Guest: ${guest.name} • ${DateFormat('MMM dd').format(reservation.checkIn)}'
                        : 'Unknown guest • ${DateFormat('MMM dd').format(reservation.checkIn)}',
                    color: _getStatusColor(reservation.status),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'checked-in':
        return Icons.login;
      case 'checked-out':
        return Icons.logout;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.calendar_today;
    }
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

  void _addGuest(BuildContext context) async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => AddGuestSimpleDialog(),
    );
    if (added == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guest added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}