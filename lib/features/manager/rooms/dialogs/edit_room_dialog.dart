// features/manager/rooms/dialogs/edit_room_dialog.dart
//
// Dialog for editing an existing room. Extracted from all_rooms_screen.dart.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../models/room.dart';
import '../../../../features/rooms/cubit/room_cubit.dart';

class EditRoomDialog extends StatefulWidget {
  final Room room;
  const EditRoomDialog({super.key, required this.room});

  @override
  State<EditRoomDialog> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<EditRoomDialog> {
  late final TextEditingController _numberController;
  late final TextEditingController _priceController;
  late String? _selectedViewType;
  late String? _selectedCapacity;
  late bool _isAvailable;
  late List<String> _selectedAmenities;

  final List<String> _allAmenities = [
    'WiFi', 'TV', 'AC', 'Mini Bar', 'Safe', 'Bathroom',
    'Room Service', 'Balcony', 'Sea View', 'Breakfast Included',
  ];

  @override
  void initState() {
    super.initState();
    _numberController =
        TextEditingController(text: widget.room.number);
    _priceController =
        TextEditingController(text: widget.room.pricePerNight.toString());
    _selectedViewType = widget.room.viewType;
    _selectedCapacity = widget.room.capacity;
    _isAvailable = widget.room.isAvailable;
    _selectedAmenities = List.from(widget.room.amenities);
  }

  @override
  void dispose() {
    _numberController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Room ${widget.room.number}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Room Number',
                hintText: 'e.g., 101, 202',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'View Type', border: OutlineInputBorder()),
              value: _selectedViewType,
              items: AppConstants.roomViewTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedViewType = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'Capacity', border: OutlineInputBorder()),
              value: _selectedCapacity,
              items: AppConstants.roomCapacities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCapacity = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price per Night',
                prefixText: 'Dollar ',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Room Available'),
              subtitle: const Text('Is this room available for booking?'),
              value: _isAvailable,
              onChanged: (v) => setState(() => _isAvailable = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Amenities',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allAmenities.map((amenity) {
                final isSelected = _selectedAmenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _selectedAmenities.add(amenity)
                          : _selectedAmenities.remove(amenity);
                    });
                  },
                  backgroundColor:
                      isSelected ? Colors.blue[100] : Colors.grey[200],
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Update Room')),
      ],
    );
  }

  void _submit() {
    final number = _numberController.text.trim();
    final priceText = _priceController.text.trim();

    if (number.isEmpty) { _showSnack('Please enter room number'); return; }
    if (_selectedViewType == null) { _showSnack('Please select view type'); return; }
    if (_selectedCapacity == null) { _showSnack('Please select capacity'); return; }
    if (priceText.isEmpty) { _showSnack('Please enter price'); return; }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      _showSnack('Please enter a valid price');
      return;
    }

    // Duplicate number check (excluding current room)
    final exists = context
        .read<RoomCubit>()
        .allRooms
        .any((r) => r.number == number && r.id != widget.room.id);
    if (exists) { _showSnack('Room number $number already exists'); return; }

    context.read<RoomCubit>().updateRoom(
          roomId: widget.room.id,
          number: number,
          viewType: _selectedViewType!,
          capacity: _selectedCapacity!,
          pricePerNight: price,
          isAvailable: _isAvailable,
          amenities: _selectedAmenities,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room ${widget.room.number} updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

