// features/manager/rooms/dialogs/add_room_dialog.dart
//
// Dialog for adding a new room. Extracted from all_rooms_screen.dart.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../providers/room_provider.dart';

class AddRoomDialog extends StatefulWidget {
  const AddRoomDialog({super.key});

  @override
  State<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final _roomNumberController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedViewType;
  String? _selectedCapacity;
  List<String> _selectedAmenities = [];

  @override
  void dispose() {
    _roomNumberController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Room'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _roomNumberController,
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
                labelText: 'View Type',
                border: OutlineInputBorder(),
              ),
              value: _selectedViewType,
              items: AppConstants.roomViewTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedViewType = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Capacity',
                border: OutlineInputBorder(),
              ),
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Amenities',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.roomAmenities.map((amenity) {
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
                  backgroundColor: isSelected ? Colors.blue[100] : Colors.grey[200],
                  selectedColor: Colors.blue,
                  labelStyle:
                      TextStyle(color: isSelected ? Colors.white : Colors.black),
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
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add Room'),
        ),
      ],
    );
  }

  void _submit() {
    final number = _roomNumberController.text.trim();
    final priceText = _priceController.text.trim();

    if (number.isEmpty) {
      _showSnack('Please enter room number');
      return;
    }
    if (_selectedViewType == null) {
      _showSnack('Please select view type');
      return;
    }
    if (_selectedCapacity == null) {
      _showSnack('Please select capacity');
      return;
    }
    if (priceText.isEmpty) {
      _showSnack('Please enter price');
      return;
    }
    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      _showSnack('Please enter a valid price');
      return;
    }

    // Check for duplicate room number
    final exists = context.read<RoomProvider>().allRooms
        .any((r) => r.number == number);
    if (exists) {
      _showSnack('Room number $number already exists');
      return;
    }

    context.read<RoomProvider>().addRoom(
          number, _selectedViewType!, _selectedCapacity!, price,
          amenities: _selectedAmenities,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room $number added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
