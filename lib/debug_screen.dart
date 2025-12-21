// screens/debug/debug_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/hotel_service.dart';

class DebugScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = HotelService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Debug - Data Persistence'),
      ),
      body: FutureBuilder(
        future: _loadDebugInfo(service),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data as Map<String, dynamic>;

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildDebugCard(
                'Hotel Data',
                'Rooms: ${data['roomsCount']}\n'
                    'Guests: ${data['guestsCount']}\n'
                    'Reservations: ${data['reservationsCount']}\n'
                    'Revenue: EGP ${data['revenue']}',
                Icons.hotel,
                Colors.blue,
              ),

              SizedBox(height: 16),

              _buildDebugCard(
                'SharedPreferences Status',
                'Rooms key: ${data['roomsKeyExists']}\n'
                    'Guests key: ${data['guestsKeyExists']}\n'
                    'Reservations key: ${data['reservationsKeyExists']}\n'
                    'Last IDs key: ${data['lastIdsKeyExists']}',
                Icons.storage,
                Colors.green,
              ),

              SizedBox(height: 16),

              _buildDebugCard(
                'Sample Room Data',
                data['sampleRoom'],
                Icons.meeting_room,
                Colors.purple,
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await service.clearAllData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Data cleared and reset to sample')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('Clear & Reset Data'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await service.saveAllData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Data manually saved')),
                        );
                      },
                      child: Text('Force Save'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  final exported = await service.exportAllData();
                  print('Exported Data: $exported');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Data exported to console')),
                  );
                },
                child: Text('Export to Console'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDebugCard(String title, String content, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }

// In the _loadDebugInfo method of DebugScreen, add:
  Future<Map<String, dynamic>> _loadDebugInfo(HotelService service) async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'roomsCount': service.rooms.length,
      'guestsCount': service.guests.length,
      'reservationsCount': service.reservations.length,
      'employeesCount': service.employees.length, // Add this
      'revenue': service.calculateExpectedRevenue().toStringAsFixed(0),
      'roomsKeyExists': prefs.containsKey('hotel_rooms'),
      'guestsKeyExists': prefs.containsKey('hotel_guests'),
      'reservationsKeyExists': prefs.containsKey('hotel_reservations'),
      'employeesKeyExists': prefs.containsKey('hotel_employees'), // Add this
      'lastIdsKeyExists': prefs.containsKey('hotel_last_ids'),
      'sampleRoom': service.rooms.isNotEmpty
          ? 'ID: ${service.rooms.first.id}, Number: ${service.rooms.first.number}, Type: ${service.rooms.first.viewType}, Available: ${service.rooms.first.isAvailable}'
          : 'No rooms',
      'sampleEmployee': service.employees.isNotEmpty // Add this
          ? 'ID: ${service.employees.first.id}, Name: ${service.employees.first.fullName}, Department: ${service.employees.first.department}'
          : 'No employees',
    };
  }}