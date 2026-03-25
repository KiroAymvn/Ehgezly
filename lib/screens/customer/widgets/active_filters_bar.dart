import 'package:flutter/material.dart';

class ActiveFiltersBar extends StatelessWidget {
  final Map<String, dynamic> filters;
  final VoidCallback onClearViewType;
  final VoidCallback onClearCapacity;
  final VoidCallback onClearAvailability;
  final VoidCallback onClearPrice;
  final VoidCallback onClearSearch;
  final VoidCallback onClearAll;

  const ActiveFiltersBar({
    Key? key,
    required this.filters,
    required this.onClearViewType,
    required this.onClearCapacity,
    required this.onClearAvailability,
    required this.onClearPrice,
    required this.onClearSearch,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  if (filters['viewType'] != null && filters['viewType'] != 'All')
                    FilterChip(
                      label: Text('View: ${filters['viewType']}'),
                      onSelected: (_) => onClearViewType(),
                    ),
                  if (filters['capacity'] != null && filters['capacity'] != 'All')
                    FilterChip(
                      label: Text('Capacity: ${filters['capacity']}'),
                      onSelected: (_) => onClearCapacity(),
                    ),
                  if (filters['showAvailableOnly'] == false)
                    FilterChip(
                      label: Text('Show All'),
                      onSelected: (_) => onClearAvailability(),
                    ),
                  if (filters['minPrice'] != null || filters['maxPrice'] != null)
                    FilterChip(
                      label: Text(
                        'Price: ${filters['minPrice'] != null ? 'Dollar ${filters['minPrice']}' : 'Min'} - ${filters['maxPrice'] != null ? 'Dollar ${filters['maxPrice']}' : 'Max'}',
                      ),
                      onSelected: (_) => onClearPrice(),
                    ),
                  if (filters['searchQuery']?.isNotEmpty == true)
                    FilterChip(
                      label: Text('Search: "${filters['searchQuery']}"'),
                      onSelected: (_) => onClearSearch(),
                    ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: onClearAll,
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
