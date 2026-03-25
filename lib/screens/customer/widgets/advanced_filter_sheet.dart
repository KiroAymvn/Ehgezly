import 'package:flutter/material.dart';

class AdvancedFilterSheet extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final List<String> viewTypes;
  final List<String> capacities;
  final double maxRoomPrice;
  final double minRoomPrice;
  final void Function(Map<String, dynamic> newFilters) onApply;
  final VoidCallback onReset;

  const AdvancedFilterSheet({
    Key? key,
    required this.initialFilters,
    required this.viewTypes,
    required this.capacities,
    required this.maxRoomPrice,
    required this.minRoomPrice,
    required this.onApply,
    required this.onReset,
  }) : super(key: key);

  @override
  State<AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<AdvancedFilterSheet> {
  late Map<String, dynamic> _filters;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.initialFilters);
    _minPriceController = TextEditingController(text: _filters['minPrice']?.toString() ?? '');
    _maxPriceController = TextEditingController(text: _filters['maxPrice']?.toString() ?? '');
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _resetLocalFilters() {
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
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
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
            children: widget.viewTypes.map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: _filters['viewType'] == type,
                onSelected: (selected) {
                  setState(() => _filters['viewType'] = type);
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
            children: widget.capacities.map((capacity) {
              return ChoiceChip(
                label: Text(capacity),
                selected: _filters['capacity'] == capacity,
                onSelected: (selected) {
                  setState(() => _filters['capacity'] = capacity);
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
          Text('Price Range (\$)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        setState(() => _filters['minPrice'] = parsed);
                      }
                    } else {
                      setState(() => _filters['minPrice'] = null);
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
                        setState(() => _filters['maxPrice'] = parsed);
                      }
                    } else {
                      setState(() => _filters['maxPrice'] = null);
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (widget.maxRoomPrice > 0)
            Text(
              'Room prices range from ${widget.minRoomPrice.toStringAsFixed(0)} to ${widget.maxRoomPrice.toStringAsFixed(0)} \$',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),

          SizedBox(height: 24),

          // Availability Filter
          SwitchListTile(
            title: Text('Show Available Rooms Only'),
            subtitle: Text('Hide rooms that are already booked'),
            value: _filters['showAvailableOnly'],
            onChanged: (value) {
              setState(() => _filters['showAvailableOnly'] = value);
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
                  onPressed: _resetLocalFilters,
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

                    widget.onApply(_filters);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Apply Filters', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
        ],
      ),
    );
  }
}
