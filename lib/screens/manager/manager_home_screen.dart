// screens/manager/manager_home_screen.dart
//
// Manager dashboard: shows stat cards for employees, rooms, guests,
// reservations, and revenue, plus quick actions and recent activity.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/status_helpers.dart';
import '../../features/employees/cubit/employee_cubit.dart';
import '../../features/employees/cubit/employee_state.dart';
import '../../features/guests/cubit/guest_cubit.dart';
import '../../features/guests/cubit/guest_state.dart';
import '../../features/reservations/cubit/reservation_cubit.dart';
import '../../features/reservations/cubit/reservation_state.dart';
import '../../features/rooms/cubit/room_cubit.dart';
import '../../features/rooms/cubit/room_state.dart';
import '../../models/reservation.dart';
import '../../services/hotel_service.dart';
import 'add_guest_simple_dialog.dart';
import 'dashboard_card.dart';

class ManagerHomeScreen extends StatelessWidget {
  const ManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roomState = context.watch<RoomCubit>().state;
    final guestState = context.watch<GuestCubit>().state;
    final resState = context.watch<ReservationCubit>().state;
    final empState = context.watch<EmployeeCubit>().state;

    final rooms        = roomState is RoomLoaded ? roomState.rooms : [];
    final guests       = guestState is GuestLoaded ? guestState.guests : [];
    final reservations = resState is ReservationLoaded ? resState.reservations : [];
    final employees    = empState is EmployeeLoaded ? empState.employees : [];
    final revenue      = HotelService().calculateExpectedRevenue();

    final cards = [
      DashboardCard(
        title: 'Employees', count: '${employees.length}',
        subtitle: 'Staff members', icon: Icons.badge,
        color: Colors.teal, route: '/manager/employees',
      ),
      DashboardCard(
        title: 'Rooms', count: '${rooms.length}',
        subtitle: '${rooms.where((r) => r.isAvailable).length} available',
        icon: Icons.meeting_room, color: Colors.blue, route: '/manager/rooms',
      ),
      DashboardCard(
        title: 'Guests', count: '${guests.length}',
        subtitle: 'Registered guests', icon: Icons.people,
        color: Colors.green, route: '/manager/guests',
      ),
      DashboardCard(
        title: 'Reservations', count: '${reservations.length}',
        subtitle: 'Current bookings', icon: Icons.book_online,
        color: Colors.purple, route: '/manager/reservations',
      ),
      DashboardCard(
        title: 'Revenue',
        count: 'Dollar ${revenue.toStringAsFixed(0)}',
        subtitle: 'Expected revenue', icon: Icons.attach_money,
        color: Colors.orange, route: '',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}, tooltip: 'Notifications'),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              // Providers are live; this button is a placeholder for future use.
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  crossAxisSpacing: 6, mainAxisSpacing: 16, childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => cards[i], childCount: cards.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: _QuickActionsCard(onAddGuest: () => _addGuest(context))),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(child: _RecentActivityCard()),
            ),
          ],
        ),
      ),
    );
  }

  void _addGuest(BuildContext context) async {
    final added = await showDialog<bool>(
      context: context, builder: (_) => const AddGuestSimpleDialog(),
    );
    if (added == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest added successfully'), backgroundColor: Colors.green),
      );
    }
  }
}

// ── Quick Actions Card ─────────────────────────────────────────────────────────

class _QuickActionsCard extends StatelessWidget {
  final VoidCallback onAddGuest;
  const _QuickActionsCard({required this.onAddGuest});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(spacing: 12, runSpacing: 12, children: [
              _ActionButton(icon: Icons.add, label: 'Add Guest', onTap: onAddGuest),
              _ActionButton(icon: Icons.bed, label: 'Check In', onTap: () {}),
              _ActionButton(icon: Icons.exit_to_app, label: 'Check Out', onTap: () {}),
              _ActionButton(icon: Icons.receipt, label: 'Generate Bill', onTap: () {}),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.indigo[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo[100]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.indigo),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.indigo[800]),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recent Activity Card ────────────────────────────────────────────────────────

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    final resState = context.watch<ReservationCubit>().state;
    final reservations = resState is ReservationLoaded ? resState.reservations : <Reservation>[];
    final service = HotelService();
    final recent = reservations.length > 3 ? reservations.sublist(0, 3) : reservations;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('No recent activity', style: TextStyle(color: Colors.grey[600])),
                ),
              )
            else
              Column(
                children: recent.map((res) {
                  final guest = service.getGuestById(res.guestId);
                  final room  = service.getRoomById(res.roomId);
                  return _ActivityItem(
                    icon: StatusHelpers.getStatusIcon(res.status),
                    color: StatusHelpers.getStatusColor(res.status),
                    title: room != null
                        ? 'Room ${room.number} ${res.status}'
                        : 'Reservation ${res.status}',
                    subtitle: guest != null
                        ? 'Guest: ${guest.name} • ${DateFormat('MMM dd').format(res.checkIn)}'
                        : 'Unknown guest • ${DateFormat('MMM dd').format(res.checkIn)}',
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _ActivityItem({required this.icon, required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ]),
    );
  }
}