import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/guest.dart';
import '../../models/room.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/room_provider.dart';
import '../../services/hotel_service.dart';
import 'add_guest_dialog.dart';
import 'date_range_dialog.dart';
import 'room_details_sheet.dart';
import 'widgets/room_grid_card.dart';
import 'widgets/advanced_filter_sheet.dart';
import 'widgets/active_filters_bar.dart';
import 'widgets/empty_rooms_state.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // Filter states
  Map<String, dynamic> _filters = {
    'viewType': 'All',
    'capacity': 'All',
    'showAvailableOnly': true,
    'minPrice': null,
    'maxPrice': null,
    'searchQuery': '',
  };

  final TextEditingController _searchController = TextEditingController();
  final HotelService _service = HotelService();

  // Track highest and lowest room prices for filter guidance
  double _maxRoomPrice = 0;
  double _minRoomPrice = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _filters['searchQuery'] = _searchController.text;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateRoomPrices();
    });
  }

  void _calculateRoomPrices() {
    final rooms = context.read<RoomProvider>().allRooms;
    if (rooms.isNotEmpty) {
      double maxPrice = rooms.map((r) => r.pricePerNight).reduce((a, b) => a > b ? a : b);
      double minPrice = rooms.map((r) => r.pricePerNight).reduce((a, b) => a < b ? a : b);
      setState(() {
        _maxRoomPrice = maxPrice;
        _minRoomPrice = minPrice;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetAllFilters() {
    setState(() {
      _filters = {
        'viewType': 'All',
        'capacity': 'All',
        'showAvailableOnly': true,
        'minPrice': null,
        'maxPrice': null,
        'searchQuery': '',
      };
      _searchController.clear();
    });
  }

  bool _hasActiveFilters() {
    return _filters['viewType'] != 'All' ||
        _filters['capacity'] != 'All' ||
        _filters['showAvailableOnly'] == false ||
        _filters['minPrice'] != null ||
        _filters['maxPrice'] != null ||
        _filters['searchQuery']?.isNotEmpty == true;
  }

  String _buildFilterSummary() {
    List<String> activeFilters = [];

    if (_filters['viewType'] != 'All') {
      activeFilters.add('View: ${_filters['viewType']}');
    }

    if (_filters['capacity'] != 'All') {
      activeFilters.add('Capacity: ${_filters['capacity']}');
    }

    if (_filters['minPrice'] != null || _filters['maxPrice'] != null) {
      String priceRange = '';
      if (_filters['minPrice'] != null && _filters['maxPrice'] != null) {
        priceRange = 'Dollar ${_filters['minPrice']} - Dollar ${_filters['maxPrice']}';
      } else if (_filters['minPrice'] != null) {
        priceRange = 'Above Dollar ${_filters['minPrice']}';
      } else if (_filters['maxPrice'] != null) {
        priceRange = 'Below Dollar ${_filters['maxPrice']}';
      }
      activeFilters.add('Price: $priceRange');
    }

    if (_filters['searchQuery']?.isNotEmpty == true) {
      activeFilters.add('Search: "${_filters['searchQuery']}"');
    }

    if (!_filters['showAvailableOnly']) {
      activeFilters.add('Showing all rooms');
    }

    return activeFilters.join(' • ');
  }

  List<Room> _applyFilters(List<Room> rooms) {
    List<Room> filtered = List.from(rooms);

    if (_filters['viewType'] != null && _filters['viewType'] != 'All') {
      filtered = filtered.where((room) => room.viewType == _filters['viewType']).toList();
    }
    if (_filters['capacity'] != null && _filters['capacity'] != 'All') {
      filtered = filtered.where((room) => room.capacity == _filters['capacity']).toList();
    }
    if (_filters['minPrice'] != null) {
      filtered = filtered.where((room) => room.pricePerNight >= _filters['minPrice']).toList();
    }
    if (_filters['maxPrice'] != null) {
      filtered = filtered.where((room) => room.pricePerNight <= _filters['maxPrice']).toList();
    }
    if (_filters['showAvailableOnly'] == true) {
      filtered = filtered.where((room) => room.isAvailable).toList();
    }
    if (_filters['searchQuery']?.isNotEmpty == true) {
      filtered = filtered.where((room) =>
          room.number.toLowerCase().contains(_filters['searchQuery'].toLowerCase()) ||
          room.viewType.toLowerCase().contains(_filters['searchQuery'].toLowerCase()) ||
          room.capacity.toLowerCase().contains(_filters['searchQuery'].toLowerCase())
      ).toList();
    }
    return filtered;
  }

  void _showAdvancedFilterOptions(BuildContext context) {
    final rooms = context.read<RoomProvider>().allRooms;
    final viewTypes = ['All', ...rooms.map((r) => r.viewType).toSet()];
    final capacities = ['All', ...rooms.map((r) => r.capacity).toSet()];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AdvancedFilterSheet(
          initialFilters: _filters,
          viewTypes: viewTypes,
          capacities: capacities,
          maxRoomPrice: _maxRoomPrice,
          minRoomPrice: _minRoomPrice,
          onApply: (newFilters) {
            setState(() {
              _filters = newFilters;
            });
          },
          onReset: () {
            setState(() {
              _filters = {
                'viewType': 'All',
                'capacity': 'All',
                'showAvailableOnly': true,
                'minPrice': null,
                'maxPrice': null,
                'searchQuery': _filters['searchQuery'],
              };
            });
          },
        );
      },
    );
  }

  void _showRoomDetails(BuildContext context, Room room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => RoomDetailsSheet(room: room),
    );
  }

  void _startReservation(BuildContext context, Room room) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => DateRangeDialog(roomId: room.id),
    );

    if (result == null) return;

    final checkIn = result['in']! as DateTime;
    final checkOut = result['out']! as DateTime;
    final isAvailable = result['isAvailable'] as bool? ?? true;

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
        _startReservation(context, room);
      }
      return;
    }

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

      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<RoomProvider>().availableRooms;
    List<Room> filteredRooms = _applyFilters(rooms);

    return Scaffold(
      appBar: AppBar(
        title: Text('Available Rooms'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.filter_alt),
                onPressed: () => _showAdvancedFilterOptions(context),
                tooltip: 'Advanced Filter',
              ),
              if (_hasActiveFilters())
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by room number, type, or capacity...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Active filters bar
          if (_hasActiveFilters())
            ActiveFiltersBar(
              filters: _filters,
              onClearViewType: () => setState(() => _filters['viewType'] = 'All'),
              onClearCapacity: () => setState(() => _filters['capacity'] = 'All'),
              onClearAvailability: () => setState(() => _filters['showAvailableOnly'] = true),
              onClearPrice: () => setState(() {
                _filters['minPrice'] = null;
                _filters['maxPrice'] = null;
              }),
              onClearSearch: () {
                setState(() => _filters['searchQuery'] = '');
                _searchController.clear();
              },
              onClearAll: _resetAllFilters,
            ),

          // Results count and filter summary
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredRooms.length} room${filteredRooms.length != 1 ? 's' : ''} found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                    if (_hasActiveFilters())
                      TextButton(
                        onPressed: _resetAllFilters,
                        child: Text(
                          'Reset Filters',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                if (_hasActiveFilters())
                  Text(
                    _buildFilterSummary(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),

          // Rooms grid
          Expanded(
            child: filteredRooms.isEmpty
                ? EmptyRoomsState(
                    onResetFilters: _resetAllFilters,
                    onTryDifferentFilters: () => _showAdvancedFilterOptions(context),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.43,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final room = filteredRooms[index];
                              return RoomGridCard(
                                room: room,
                                service: _service,
                                onTap: () => _showRoomDetails(context, room),
                                onBookNow: () => _startReservation(context, room),
                              );
                            },
                            childCount: filteredRooms.length,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
