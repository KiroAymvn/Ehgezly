// screens/manager/all_rooms_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room.dart';
import '../../providers/room__provider.dart';

class AllRoomsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<RoomProvider>().allRooms;
    final availableCount = rooms.where((r) => r.isAvailable).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('All Rooms'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddRoomDialog(context),
            tooltip: 'Add Room',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    width: 120,
                    child: _buildStatCard(
                      title: 'Total Rooms',
                      value: rooms.length.toString(),
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    width: 120,
                    child: _buildStatCard(
                      title: 'Available',
                      value: availableCount.toString(),
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    width: 120,
                    child: _buildStatCard(
                      title: 'Reserved',
                      value: (rooms.length - availableCount).toString(),
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Room List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (ctx, i) {
                final room = rooms[i];
                return _buildRoomListItem(context, room);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomListItem(BuildContext context, Room room) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        child: InkWell(
          onTap: () {
            // Optional: Show room details when tapped
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage("assets/room.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10),

                // Room details (Expanded to take available space)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Room ${room.number}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Switch.adaptive(
                                    value: room.isAvailable,
                                    activeColor: Colors.green,
                                    onChanged: (val) {
                                      context.read<RoomProvider>().toggleAvailability(room.id, val);
                                    },
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    room.isAvailable ? 'Available' : 'Reserved',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: room.isAvailable ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 4),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, size: 20, color: Colors.grey),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 16, color: Colors.blue),
                                        SizedBox(width: 6),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 16, color: Colors.red),
                                        SizedBox(width: 6),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditRoomDialog(context, room);
                                  } else if (value == 'delete') {
                                    _showDeleteRoomDialog(context, room);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getViewTypeColor(room.viewType).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              room.viewType,
                              style: TextStyle(
                                fontSize: 11,
                                color: _getViewTypeColor(room.viewType),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              room.capacityText,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${room.pricePerNight.toStringAsFixed(0)} Dollar/night',
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      if (room.amenities.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amenities:',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 2),
                            Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              children: room.amenities.take(2).map((amenity) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    amenity,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            if (room.amenities.length > 2)
                              Text(
                                '+${room.amenities.length - 2} more',
                                style: TextStyle(fontSize: 10, color: Colors.grey[500], fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Color _getViewTypeColor(String viewType) {
    switch (viewType.toLowerCase()) {
      case 'nile view': return Colors.teal;
      case 'suite': return Colors.purple;
      case 'regular': return Colors.blue;
      default: return Colors.green;
    }
  }

  void _showAddRoomDialog(BuildContext context) {
    final roomNumberController = TextEditingController();
    final priceController = TextEditingController();
    String? selectedViewType;
    String? selectedCapacity;
    List<String> selectedAmenities = [];

    final List<String> viewTypes = ['Nile View', 'Suite', 'Regular'];
    final List<String> capacities = ['Single', 'Double', 'Triple'];
    final List<String> allAmenities = [
      'WiFi', 'Gym', 'Spa', 'Dinner', 'Massage'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Room'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: roomNumberController,
                      decoration: InputDecoration(
                        labelText: 'Room Number',
                        hintText: 'e.g., 101, 202',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'View Type',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedViewType,
                      items: viewTypes
                          .map(
                            (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedViewType = value;
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Capacity',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCapacity,
                      items: capacities
                          .map(
                            (capacity) => DropdownMenuItem(
                          value: capacity,
                          child: Text(capacity),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCapacity = value;
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price per Night',
                        prefixText: 'Dollar ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 12),
                    Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allAmenities.map((amenity) {
                        final isSelected = selectedAmenities.contains(amenity);
                        return FilterChip(
                          label: Text(amenity),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedAmenities.add(amenity);
                              } else {
                                selectedAmenities.remove(amenity);
                              }
                            });
                          },
                          backgroundColor: isSelected ? Colors.blue[100] : Colors.grey[200],
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
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
                    // Validate inputs
                    if (roomNumberController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter room number')),
                      );
                      return;
                    }

                    if (selectedViewType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select view type')),
                      );
                      return;
                    }

                    if (selectedCapacity == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select capacity')),
                      );
                      return;
                    }

                    final priceText = priceController.text.trim();
                    if (priceText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter price')),
                      );
                      return;
                    }

                    final price = double.tryParse(priceText);
                    if (price == null || price <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter valid price')),
                      );
                      return;
                    }

                    // Check if room number already exists
                    final existingRoom = context.read<RoomProvider>().allRooms
                        .firstWhere((room) => room.number == roomNumberController.text.trim(),
                        orElse: () => Room(
                            id: -1,
                            number: '',
                            viewType: '',
                            capacity: '',
                            pricePerNight: 0
                        ));

                    if (existingRoom.id != -1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Room number ${roomNumberController.text.trim()} already exists')),
                      );
                      return;
                    }

                    // Add the room
                    context.read<RoomProvider>().addRoom(
                      roomNumberController.text.trim(),
                      selectedViewType!,
                      selectedCapacity!,
                      price,
                      amenities: selectedAmenities,
                    );

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Room ${roomNumberController.text.trim()} added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context);
                  },
                  child: Text('Add Room'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // New method to show edit room dialog
  void _showEditRoomDialog(BuildContext context, Room room) {
    final roomNumberController = TextEditingController(text: room.number);
    final priceController = TextEditingController(text: room.pricePerNight.toString());
    String? selectedViewType = room.viewType;
    String? selectedCapacity = room.capacity;
    bool isAvailable = room.isAvailable;
    List<String> selectedAmenities = List.from(room.amenities);

    final List<String> viewTypes = ['Nile View', 'Suite', 'Regular'];
    final List<String> capacities = ['Single', 'Double', 'Triple'];
    final List<String> allAmenities = [
      'WiFi', 'TV', 'AC', 'Mini Bar', 'Safe', 'Bathroom',
      'Room Service', 'Balcony', 'Sea View', 'Breakfast Included'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Room ${room.number}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: roomNumberController,
                      decoration: InputDecoration(
                        labelText: 'Room Number',
                        hintText: 'e.g., 101, 202',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'View Type',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedViewType,
                      items: viewTypes
                          .map(
                            (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedViewType = value;
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Capacity',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCapacity,
                      items: capacities
                          .map(
                            (capacity) => DropdownMenuItem(
                          value: capacity,
                          child: Text(capacity),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCapacity = value;
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Price per Night',
                        prefixText: 'Dollar ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 12),
                    SwitchListTile(
                      title: Text('Room Available'),
                      subtitle: Text('Is this room available for booking?'),
                      value: isAvailable,
                      onChanged: (value) {
                        setState(() {
                          isAvailable = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    SizedBox(height: 12),
                    Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allAmenities.map((amenity) {
                        final isSelected = selectedAmenities.contains(amenity);
                        return FilterChip(
                          label: Text(amenity),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedAmenities.add(amenity);
                              } else {
                                selectedAmenities.remove(amenity);
                              }
                            });
                          },
                          backgroundColor: isSelected ? Colors.blue[100] : Colors.grey[200],
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
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
                    // Validate inputs
                    if (roomNumberController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter room number')),
                      );
                      return;
                    }

                    if (selectedViewType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select view type')),
                      );
                      return;
                    }

                    if (selectedCapacity == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select capacity')),
                      );
                      return;
                    }

                    final priceText = priceController.text.trim();
                    if (priceText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter price')),
                      );
                      return;
                    }

                    final price = double.tryParse(priceText);
                    if (price == null || price <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter valid price')),
                      );
                      return;
                    }

                    // Check if room number already exists (excluding current room)
                    final existingRoom = context.read<RoomProvider>().allRooms
                        .firstWhere((r) => r.number == roomNumberController.text.trim() && r.id != room.id,
                        orElse: () => Room(
                            id: -1,
                            number: '',
                            viewType: '',
                            capacity: '',
                            pricePerNight: 0
                        ));

                    if (existingRoom.id != -1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Room number ${roomNumberController.text.trim()} already exists')),
                      );
                      return;
                    }

                    // Update the room
                    context.read<RoomProvider>().updateRoom(
                      roomId: room.id,
                      number: roomNumberController.text.trim(),
                      viewType: selectedViewType!,
                      capacity: selectedCapacity!,
                      pricePerNight: price,
                      isAvailable: isAvailable,
                      amenities: selectedAmenities,
                    );

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Room ${room.number} updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context);
                  },
                  child: Text('Update Room'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // New method to show delete room dialog
  void _showDeleteRoomDialog(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Room ${room.number}'),
        content: Text(
          'Are you sure you want to delete Room ${room.number}? '
              'This action cannot be undone.\n\n'
              'View: ${room.viewType}\n'
              'Capacity: ${room.capacityText}\n'
              'Price: ${room.pricePerNight.toStringAsFixed(0)} Dollar per night',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              try {
                await context.read<RoomProvider>().deleteRoom(room.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Room ${room.number} deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}