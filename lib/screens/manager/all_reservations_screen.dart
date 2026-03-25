// screens/manager/all_reservations_screen.dart
//
// Lists all reservations with filter/sort/search controls.
// Edit, bill, and delete actions are kept as inline dialogs
// driven by private helper methods — no separate dialog files
// needed since they share local state.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_formatter.dart';
import '../../core/utils/status_helpers.dart';
import '../../models/guest.dart';
import '../../models/reservation.dart';
import '../../models/room.dart';
import '../../providers/reservation_provider.dart';
import '../../services/hotel_service.dart';

class AllReservationsScreen extends StatefulWidget {
  const AllReservationsScreen({super.key});

  @override
  State<AllReservationsScreen> createState() => _AllReservationsScreenState();
}

class _AllReservationsScreenState extends State<AllReservationsScreen> {
  String _selectedFilter = 'all';
  String _selectedSort   = 'newest';
  String _searchQuery    = '';

  // Status values available in the edit dialog
  static const _statusOptions = ['Confirmed', 'Checked-in', 'Checked-out', 'Cancelled'];

  // Filter and sort option lists
  static const _filterOptions = [
    {'value': 'all',         'label': 'All Reservations'},
    {'value': 'confirmed',   'label': 'Confirmed'},
    {'value': 'checked-in',  'label': 'Checked-in'},
    {'value': 'checked-out', 'label': 'Checked-out'},
    {'value': 'cancelled',   'label': 'Cancelled'},
  ];

  static const _sortOptions = [
    {'value': 'newest',      'label': 'Newest First'},
    {'value': 'oldest',      'label': 'Oldest First'},
    {'value': 'guest_name',  'label': 'Guest Name (A-Z)'},
    {'value': 'room_number', 'label': 'Room Number'},
    {'value': 'price',       'label': 'Total Price'},
  ];

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final service      = HotelService();
    final reservations = context.watch<ReservationProvider>().allReservations;
    final filtered     = _applyFilterAndSort(reservations, service);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reservations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter & Sort',
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export',
            onPressed: () => _showExportDialog(context, filtered, service),
          ),
        ],
      ),
      body: Column(children: [
        // ── Search Bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by guest name or room number...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
          ),
        ),

        // ── Count Row ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filtered.length} reservation${filtered.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              Text(
                'Sort: ${_sortOptions.firstWhere((s) => s['value'] == _selectedSort)['label']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),

        // ── List ────────────────────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final res   = filtered[i];
                    final guest = service.getGuestById(res.guestId);
                    final room  = service.getRoomById(res.roomId);
                    return _ReservationCard(
                      reservation: res, guest: guest, room: room,
                      onEdit:   () => _editReservation(context, res, guest, room),
                      onBill:   () => _generateBill(context, res, guest, room),
                      onDelete: () => _deleteReservation(context, res),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  // ── Filter / Sort Logic ─────────────────────────────────────────────────────

  List<Reservation> _applyFilterAndSort(
      List<Reservation> all, HotelService service) {
    var list = all.toList();

    // Status filter
    if (_selectedFilter != 'all') {
      list = list.where((r) => r.status.toLowerCase() == _selectedFilter).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      list = list.where((r) {
        final guestName  = service.getGuestById(r.guestId)?.name.toLowerCase() ?? '';
        final roomNumber = service.getRoomById(r.roomId)?.number.toLowerCase() ?? '';
        return guestName.contains(_searchQuery) ||
            roomNumber.contains(_searchQuery) ||
            r.id.toString().contains(_searchQuery);
      }).toList();
    }

    // Sort
    switch (_selectedSort) {
      case 'newest':
        list.sort((a, b) => b.checkIn.compareTo(a.checkIn));
        break;
      case 'oldest':
        list.sort((a, b) => a.checkIn.compareTo(b.checkIn));
        break;
      case 'guest_name':
        list.sort((a, b) {
          final na = service.getGuestById(a.guestId)?.name.toLowerCase() ?? '';
          final nb = service.getGuestById(b.guestId)?.name.toLowerCase() ?? '';
          return na.compareTo(nb);
        });
        break;
      case 'room_number':
        list.sort((a, b) {
          final na = service.getRoomById(a.roomId)?.number ?? '';
          final nb = service.getRoomById(b.roomId)?.number ?? '';
          return na.compareTo(nb);
        });
        break;
      case 'price':
        list.sort((a, b) {
          final ra = service.getRoomById(a.roomId);
          final rb = service.getRoomById(b.roomId);
          final pa = (ra?.pricePerNight ?? 0) * a.checkOut.difference(a.checkIn).inDays;
          final pb = (rb?.pricePerNight ?? 0) * b.checkOut.difference(b.checkIn).inDays;
          return pb.compareTo(pa);
        });
        break;
    }

    return list;
  }

  // ── Filter Dialog ───────────────────────────────────────────────────────────

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Filter & Sort Reservations'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Filter by Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _filterOptions.map((f) {
                  final selected = _selectedFilter == f['value'];
                  return ChoiceChip(
                    label: Text(f['label']!),
                    selected: selected,
                    selectedColor: Colors.indigo,
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey[700]),
                    onSelected: (v) =>
                        setS(() => _selectedFilter = v ? f['value']! : 'all'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('Sort by', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              const SizedBox(height: 8),
              Column(
                children: _sortOptions.map((s) => RadioListTile<String>(
                  title: Text(s['label']!),
                  value: s['value']!,
                  groupValue: _selectedSort,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setS(() => _selectedSort = v!),
                )).toList(),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setS(() { _selectedFilter = 'all'; _selectedSort = 'newest'; _searchQuery = ''; });
                Navigator.pop(ctx);
              },
              child: const Text('Clear All'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    ).then((_) => setState(() {}));
  }

  // ── Edit Dialog ─────────────────────────────────────────────────────────────

  void _editReservation(BuildContext ctx, Reservation res, Guest? guest, Room? room) {
    String selectedStatus = res.status;
    DateTime checkIn  = res.checkIn;
    DateTime checkOut = res.checkOut;
    final provider = context.read<ReservationProvider>();

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (dialogCtx, setS) => AlertDialog(
          title: Text('Edit Reservation #${res.id}'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              _DetailRow(label: 'Guest', value: guest?.name ?? 'Unknown'),
              const SizedBox(height: 8),
              _DetailRow(label: 'Room',  value: '${room?.number ?? '?'} (${room?.viewType ?? '?'})'),
              if (room != null) ...[
                const SizedBox(height: 8),
                _DetailRow(label: 'Price/Night', value: '${room.pricePerNight.toStringAsFixed(0)} Dollar'),
              ],
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                isExpanded: true,
                items: _statusOptions.map((s) => DropdownMenuItem(
                  value: s,
                  child: Row(children: [
                    Container(width: 12, height: 12,
                        decoration: BoxDecoration(color: StatusHelpers.getStatusColor(s), shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Text(s),
                  ]),
                )).toList(),
                onChanged: (v) { if (v != null) setS(() => selectedStatus = v); },
              ),
              const SizedBox(height: 16),
              const Text('Dates:', style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: const Text('Check-in'),
                subtitle: Text(AppDateFormatter.format(checkIn)),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final d = await showDatePicker(
                    context: dialogCtx, initialDate: checkIn,
                    firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setS(() {
                    checkIn = d;
                    if (checkOut.isBefore(d) || checkOut.isAtSameMomentAs(d)) checkOut = d.add(const Duration(days: 1));
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.red),
                title: const Text('Check-out'),
                subtitle: Text(AppDateFormatter.format(checkOut)),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final d = await showDatePicker(
                    context: dialogCtx,
                    initialDate: checkOut,
                    firstDate: checkIn.add(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (d != null) setS(() => checkOut = d);
                },
              ),
              if (room != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${(room.pricePerNight * checkOut.difference(checkIn).inDays).toStringAsFixed(0)} Dollar',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700], fontSize: 16),
                    ),
                  ]),
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (checkOut.isBefore(checkIn) || checkOut.isAtSameMomentAs(checkIn)) {
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(
                    const SnackBar(content: Text('Check-out must be after check-in'), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (selectedStatus != res.status)         provider.updateStatus(res.id, selectedStatus);
                if (checkIn  != res.checkIn || checkOut != res.checkOut)
                  provider.updateDates(res.id, checkIn, checkOut);
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Reservation updated'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bill Dialog ─────────────────────────────────────────────────────────────

  void _generateBill(BuildContext ctx, Reservation res, Guest? guest, Room? room) {
    final nights = res.checkOut.difference(res.checkIn).inDays;
    final total  = (room?.pricePerNight ?? 0) * nights;

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Guest Bill'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _DetailRow(label: 'Guest',      value: guest?.name ?? 'Unknown'),
          _DetailRow(label: 'Room',       value: 'Room ${room?.number ?? '?'} (${room?.viewType ?? '?'})'),
          _DetailRow(label: 'Check-in',   value: AppDateFormatter.format(res.checkIn)),
          _DetailRow(label: 'Check-out',  value: AppDateFormatter.format(res.checkOut)),
          _DetailRow(label: 'Nights',     value: '$nights'),
          _DetailRow(label: 'Rate',       value: '${room?.pricePerNight.toStringAsFixed(0) ?? '0'} Dollar/night'),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${ total.toStringAsFixed(0)} Dollar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green[700])),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  // ── Delete Dialog ────────────────────────────────────────────────────────────

  void _deleteReservation(BuildContext ctx, Reservation res) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete Reservation'),
        content: Text('Are you sure you want to delete Reservation #${res.id}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<ReservationProvider>().deleteReservation(res.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Reservation deleted'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Export Dialog ────────────────────────────────────────────────────────────

  void _showExportDialog(BuildContext ctx, List<Reservation> list, HotelService service) {
    if (list.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('No reservations to export')));
      return;
    }

    // Build a quick summary
    double revenue = 0;
    int totalNights = 0;
    for (final r in list) {
      final room = service.getRoomById(r.roomId);
      final nights = r.checkOut.difference(r.checkIn).inDays;
      totalNights += nights;
      revenue += (room?.pricePerNight ?? 0) * nights;
    }

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Reservations Summary'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _DetailRow(label: 'Total Reservations', value: '${list.length}'),
          _DetailRow(label: 'Total Nights',        value: '$totalNights'),
          _DetailRow(label: 'Total Revenue',       value: 'Dollar ${revenue.toStringAsFixed(0)}'),
          if (list.isNotEmpty)
            _DetailRow(label: 'Avg per Reservation',
                value: 'Dollar ${(revenue / list.length).toStringAsFixed(0)}'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}

// ── Private helpers ────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.calendar_today, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('No reservations found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        Text('Try adjusting your filters', style: TextStyle(color: Colors.grey[500])),
      ]),
    );
  }
}

// ── Reservation Card ───────────────────────────────────────────────────────────

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final Guest? guest;
  final Room? room;
  final VoidCallback onEdit;
  final VoidCallback onBill;
  final VoidCallback onDelete;

  const _ReservationCard({
    required this.reservation, required this.guest, required this.room,
    required this.onEdit, required this.onBill, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final nights     = reservation.checkOut.difference(reservation.checkIn).inDays;
    final totalPrice = (room?.pricePerNight ?? 0) * nights;
    final color      = StatusHelpers.getStatusColor(reservation.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Title row
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text('Reservation #${reservation.id}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(reservation.status,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),

          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _InfoCell(icon: Icons.person,       label: 'Guest',     value: guest?.name ?? 'Unknown')),
            const SizedBox(width: 16),
            Expanded(child: _InfoCell(icon: Icons.meeting_room, label: 'Room',      value: room != null ? '${room!.number} (${room!.viewType})' : 'Unknown')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _InfoCell(icon: Icons.calendar_today, label: 'Check-in',  value: AppDateFormatter.format(reservation.checkIn))),
            const SizedBox(width: 16),
            Expanded(child: _InfoCell(icon: Icons.calendar_today, label: 'Check-out', value: AppDateFormatter.format(reservation.checkOut))),
          ]),

          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$nights night${nights > 1 ? 's' : ''}', style: TextStyle(color: Colors.grey[600])),
            if (room != null)
              Text('Total: ${totalPrice.toStringAsFixed(0)} Dollar',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),

          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              icon: const Icon(Icons.edit, size: 18), label: const Text('Edit'),
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
            )),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(
              icon: const Icon(Icons.receipt, size: 18), label: const Text('Bill'),
              onPressed: onBill,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: onDelete,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: const BorderSide(color: Colors.red),
              ),
            )),
          ]),
        ]),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCell({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]);
  }
}