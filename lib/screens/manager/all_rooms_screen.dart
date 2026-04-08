// screens/manager/all_rooms_screen.dart
//
// Displays the list of all rooms with stats.
// Add/Edit/Delete dialogs are in features/manager/rooms/dialogs/.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/status_helpers.dart';
import '../../models/room.dart';
import '../../features/rooms/cubit/room_cubit.dart';
import '../../features/rooms/cubit/room_state.dart';
import '../../features/manager/rooms/dialogs/add_room_dialog.dart';
import '../../features/manager/rooms/dialogs/edit_room_dialog.dart';

class AllRoomsScreen extends StatelessWidget {
  const AllRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RoomCubit>().state;
    final rooms = state is RoomLoaded ? state.rooms : <Room>[];
    final availableCount = rooms.where((r) => r.isAvailable).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
            tooltip: 'Add Room',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Stats Row ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatCard(title: 'Total',     value: '${rooms.length}',                          color: Colors.blue),
                  const SizedBox(width: 12),
                  _StatCard(title: 'Available', value: '$availableCount',                          color: Colors.green),
                  const SizedBox(width: 12),
                  _StatCard(title: 'Reserved',  value: '${rooms.length - availableCount}',         color: Colors.orange),
                ],
              ),
            ),
          ),

          // ── Room List ─────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (ctx, i) => _RoomListItem(room: rooms[i]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const AddRoomDialog());
  }
}

// ── Stat Card Widget ───────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: color),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Room List Item ─────────────────────────────────────────────────────────────

class _RoomListItem extends StatelessWidget {
  final Room room;
  const _RoomListItem({required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room image
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage('assets/room.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Room details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text('Room ${room.number}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Row(children: [
                          _AvailabilitySwitch(room: room),
                          _RoomMenu(room: room),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      _Badge(text: room.viewType,
                          color: StatusHelpers.getViewTypeColor(room.viewType)),
                      const SizedBox(width: 6),
                      _Badge(text: room.capacityText, color: Colors.blue),
                    ]),
                    const SizedBox(height: 4),
                    Text('${room.pricePerNight.toStringAsFixed(0)} Dollar/night',
                        style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (room.amenities.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Amenities: ${room.amenities.take(3).join(', ')}'
                          '${room.amenities.length > 3 ? '...' : ''}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small helper widgets ───────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _AvailabilitySwitch extends StatelessWidget {
  final Room room;
  const _AvailabilitySwitch({required this.room});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Switch.adaptive(
        value: room.isAvailable,
        activeColor: Colors.green,
        onChanged: (val) =>
            context.read<RoomCubit>().toggleAvailability(room.id, val),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      const SizedBox(height: 2),
      Text(room.isAvailable ? 'Available' : 'Reserved',
          style: TextStyle(
              fontSize: 10,
              color: room.isAvailable ? Colors.green : Colors.red)),
    ]);
  }
}

class _RoomMenu extends StatelessWidget {
  final Room room;
  const _RoomMenu({required this.room});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
      onSelected: (value) {
        if (value == 'edit') {
          showDialog(
            context: context,
            builder: (_) => EditRoomDialog(room: room),
          );
        } else if (value == 'delete') {
          _showDeleteDialog(context);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit, size: 16, color: Colors.blue),
            SizedBox(width: 6),
            Text('Edit'),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete, size: 16, color: Colors.red),
            SizedBox(width: 6),
            Text('Delete'),
          ]),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Room ${room.number}'),
        content: Text(
          'Are you sure you want to delete Room ${room.number}?\n\n'
          'View: ${room.viewType}\n'
          'Capacity: ${room.capacityText}\n'
          'Price: ${room.pricePerNight.toStringAsFixed(0)} Dollar/night',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await context.read<RoomCubit>().deleteRoom(room.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Room ${room.number} deleted'),
                  backgroundColor: Colors.green,
                ));
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}