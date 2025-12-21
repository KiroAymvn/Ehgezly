import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/guest.dart';
import '../../models/reservation.dart';
import '../../models/room.dart';
import '../../providers/guest_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/room__provider.dart';
import '../../services/hotel_service.dart';
import 'add_guest_dialog.dart';
import 'date_range_dialog.dart';
import 'room_details_sheet.dart';

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

  TextEditingController _searchController = TextEditingController();
  final HotelService _service = HotelService();

  // Price controllers for digital input
  TextEditingController _minPriceController = TextEditingController();
  TextEditingController _maxPriceController = TextEditingController();

  // Track highest room price for filter guidance
  double _maxRoomPrice = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _filters['searchQuery'] = _searchController.text;
      });
    });

    // Calculate max room price when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateMaxRoomPrice();
    });
  }

  void _calculateMaxRoomPrice() {
    final rooms = context.read<RoomProvider>().allRooms;
    if (rooms.isNotEmpty) {
      double maxPrice = rooms.map((r) => r.pricePerNight).reduce((a, b) => a > b ? a : b);
      setState(() {
        _maxRoomPrice = maxPrice;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<RoomProvider>().availableRooms;

    // Apply filters
    List<Room> filteredRooms = _applyFilters(rooms);

    return Scaffold(
      appBar: AppBar(
        title: Text('Available Rooms'),
        actions: [
          // Filter icon with badge
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.indigo[50],
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          if (_filters['viewType'] != null && _filters['viewType'] != 'All')
                            FilterChip(
                              label: Text('View: ${_filters['viewType']}'),
                              onSelected: (selected) {
                                setState(() {
                                  _filters['viewType'] = 'All';
                                });
                              },
                            ),
                          if (_filters['capacity'] != null && _filters['capacity'] != 'All')
                            FilterChip(
                              label: Text('Capacity: ${_filters['capacity']}'),
                              onSelected: (selected) {
                                setState(() {
                                  _filters['capacity'] = 'All';
                                });
                              },
                            ),
                          if (_filters['showAvailableOnly'] == false)
                            FilterChip(
                              label: Text('Show All'),
                              onSelected: (selected) {
                                setState(() {
                                  _filters['showAvailableOnly'] = true;
                                });
                              },
                            ),
                          if (_filters['minPrice'] != null || _filters['maxPrice'] != null)
                            FilterChip(
                              label: Text(
                                'Price: ${_filters['minPrice'] != null ? 'Dollar ${_filters['minPrice']}' : 'Min'} - ${_filters['maxPrice'] != null ? 'Dollar ${_filters['maxPrice']}' : 'Max'}',
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _filters['minPrice'] = null;
                                  _filters['maxPrice'] = null;
                                  _minPriceController.clear();
                                  _maxPriceController.clear();
                                });
                              },
                            ),
                          if (_filters['searchQuery']?.isNotEmpty == true)
                            FilterChip(
                              label: Text('Search: "${_filters['searchQuery']}"'),
                              onSelected: (selected) {
                                setState(() {
                                  _filters['searchQuery'] = '';
                                  _searchController.clear();
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
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
                        _minPriceController.clear();
                        _maxPriceController.clear();
                      });
                    },
                    child: Text('Clear All'),
                  ),
                ],
              ),
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
                        onPressed: () {
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
                            _minPriceController.clear();
                            _maxPriceController.clear();
                          });
                        },
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
                ? _buildEmptyState()
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
                        return _buildRoomCard(context, room);
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

  bool _hasActiveFilters() {
    return _filters['viewType'] != 'All' ||
        _filters['capacity'] != 'All' ||
        _filters['showAvailableOnly'] == false ||
        _filters['minPrice'] != null ||
        _filters['maxPrice'] != null ||
        _filters['searchQuery']?.isNotEmpty == true;
  }

  List<Room> _applyFilters(List<Room> rooms) {
    List<Room> filtered = List.from(rooms);

    // Apply view type filter
    if (_filters['viewType'] != null && _filters['viewType'] != 'All') {
      filtered = filtered.where((room) => room.viewType == _filters['viewType']).toList();
    }

    // Apply capacity filter
    if (_filters['capacity'] != null && _filters['capacity'] != 'All') {
      filtered = filtered.where((room) => room.capacity == _filters['capacity']).toList();
    }

    // Apply price filter with unlimited range
    if (_filters['minPrice'] != null) {
      filtered = filtered.where((room) => room.pricePerNight >= _filters['minPrice']).toList();
    }

    if (_filters['maxPrice'] != null) {
      filtered = filtered.where((room) => room.pricePerNight <= _filters['maxPrice']).toList();
    }

    // Apply availability filter
    if (_filters['showAvailableOnly'] == true) {
      filtered = filtered.where((room) => room.isAvailable).toList();
    }

    // Apply search filter
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
    // Get unique view types and capacities for filters
    final rooms = context.read<RoomProvider>().allRooms;
    final viewTypes = ['All', ...rooms.map((r) => r.viewType).toSet().toList()];
    final capacities = ['All', ...rooms.map((r) => r.capacity).toSet().toList()];

    // Pre-fill price controllers if filters exist
    _minPriceController.text = _filters['minPrice']?.toString() ?? '';
    _maxPriceController.text = _filters['maxPrice']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Advanced Filters',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[800],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // View Type Filter
                  Text('Room View Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: viewTypes.map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: _filters['viewType'] == type,
                        onSelected: (selected) {
                          setState(() {
                            _filters['viewType'] = type;
                          });
                        },
                        selectedColor: Colors.indigo,
                        labelStyle: TextStyle(
                          color: _filters['viewType'] == type ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24),

                  // Capacity Filter
                  Text('Room Capacity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: capacities.map((capacity) {
                      return ChoiceChip(
                        label: Text(capacity),
                        selected: _filters['capacity'] == capacity,
                        onSelected: (selected) {
                          setState(() {
                            _filters['capacity'] = capacity;
                          });
                        },
                        selectedColor: Colors.indigo,
                        labelStyle: TextStyle(
                          color: _filters['capacity'] == capacity ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24),

                  // Price Range Filter (Digital Input)
                  Text('Price Range (Dollar)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          decoration: InputDecoration(
                            labelText: 'Minimum Price',
                            hintText: 'Min',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              final parsed = double.tryParse(value);
                              if (parsed != null) {
                                setState(() {
                                  _filters['minPrice'] = parsed;
                                });
                              }
                            } else {
                              setState(() {
                                _filters['minPrice'] = null;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          decoration: InputDecoration(
                            labelText: 'Maximum Price',
                            hintText: 'Max',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              final parsed = double.tryParse(value);
                              if (parsed != null) {
                                setState(() {
                                  _filters['maxPrice'] = parsed;
                                });
                              }
                            } else {
                              setState(() {
                                _filters['maxPrice'] = null;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (_maxRoomPrice > 0)
                    Text(
                      'Room prices range from ${rooms.map((r) => r.pricePerNight).reduce((a, b) => a < b ? a : b).toStringAsFixed(0)} to ${_maxRoomPrice.toStringAsFixed(0)} Dollar',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                    ),

                  SizedBox(height: 24),

                  // Availability Filter
                  SwitchListTile(
                    title: Text('Show Available Rooms Only'),
                    subtitle: Text('Hide rooms that are already booked'),
                    value: _filters['showAvailableOnly'],
                    onChanged: (value) {
                      setState(() {
                        _filters['showAvailableOnly'] = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.indigo,
                  ),

                  SizedBox(height: 30),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _filters = {
                                'viewType': 'All',
                                'capacity': 'All',
                                'showAvailableOnly': true,
                                'minPrice': null,
                                'maxPrice': null,
                                'searchQuery': _filters['searchQuery'],
                              };
                              _minPriceController.clear();
                              _maxPriceController.clear();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Reset Filters'),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Validate price inputs
                            if (_minPriceController.text.isNotEmpty &&
                                double.tryParse(_minPriceController.text) == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please enter a valid minimum price')),
                              );
                              return;
                            }

                            if (_maxPriceController.text.isNotEmpty &&
                                double.tryParse(_maxPriceController.text) == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please enter a valid maximum price')),
                              );
                              return;
                            }

                            if (_filters['minPrice'] != null && _filters['maxPrice'] != null &&
                                _filters['minPrice']! > _filters['maxPrice']!) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Minimum price cannot be greater than maximum price')),
                              );
                              return;
                            }

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Apply Filters',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {}); // Refresh the screen when filters are applied
    });
  }

  Widget _buildRoomCard(BuildContext context, Room room) {
    // Check if room has any upcoming reservations
    final upcomingReservations = _service.getUpcomingReservationsForRoom(room.id);
    final hasUpcomingReservations = upcomingReservations.isNotEmpty;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showRoomDetails(context, room),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Image
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(
                      image: AssetImage("assets/room.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),

                // Room Details
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Room ${room.number}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getRoomTypeColor(room.viewType).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    room.viewType,
                                    style: TextStyle(
                                      color: _getRoomTypeColor(room.viewType),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.people, size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    room.capacityText,
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.attach_money, size: 14, color: Colors.green),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${room.pricePerNight.toStringAsFixed(0)} Dollar/night',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[700],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            if (room.amenities.isNotEmpty)
                              Text(
                                'Services: ${room.amenities.take(2).join(', ')}${room.amenities.length > 2 ? '...' : ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _startReservation(context, room),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Book Now',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Availability badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasUpcomingReservations ? Colors.orange : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasUpcomingReservations ? 'Soon Booked' : 'Available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // If room has upcoming reservations, show a small indicator
            if (hasUpcomingReservations)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event_busy,
                    size: 16,
                    color: Colors.orange[800],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRoomTypeColor(String viewType) {
    switch (viewType.toLowerCase()) {
      case 'suite': return Colors.purple;
      case 'nile view': return Colors.blue;
      case 'regular': return Colors.green;
      default: return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              'No rooms match your search',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search criteria',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
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
                  _minPriceController.clear();
                  _maxPriceController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Reset All Filters'),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () => _showAdvancedFilterOptions(context),
              child: Text('Try Different Filters'),
            ),
          ],
        ),
      ),
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
