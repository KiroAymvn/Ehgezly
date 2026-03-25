import 'package:flutter/material.dart';

class EmptyRoomsState extends StatelessWidget {
  final VoidCallback onResetFilters;
  final VoidCallback onTryDifferentFilters;

  const EmptyRoomsState({
    Key? key,
    required this.onResetFilters,
    required this.onTryDifferentFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              onPressed: onResetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Reset All Filters'),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: onTryDifferentFilters,
              child: Text('Try Different Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
