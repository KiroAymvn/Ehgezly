// data/local/sample_data.dart
//
// Provides the initial seed data loaded when the app is run for the first time.
// Keeping it separate makes it easy to find and update without touching
// the rest of the persistence or business logic.

import '../../models/employee.dart';
import '../../models/room.dart';

class SampleData {
  SampleData._(); // Prevent instantiation

  /// Initial rooms seeded on first launch.
  static List<Room> get rooms => [
        Room(
          id: 1, number: '1', viewType: 'Nile View', capacity: 'Single',
          pricePerNight: 150, isAvailable: true,
          imageUrl: 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
          amenities: ['WiFi', 'Gym', 'Spa', 'Dinner', 'Massage'],
        ),
        Room(
          id: 2, number: '2', viewType: 'Nile View', capacity: 'Double',
          pricePerNight: 300, isAvailable: false,
          imageUrl: 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=400',
          amenities: ['WiFi', 'Gym', 'Spa', 'Dinner', 'Massage'],
        ),
        Room(
          id: 3, number: '3', viewType: 'Regular', capacity: 'Triple',
          pricePerNight: 220, isAvailable: true,
          imageUrl: 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=400',
          amenities: ['WiFi', 'Gym', 'Spa', 'Dinner', 'Massage'],
        ),
        Room(
          id: 4, number: '4', viewType: 'suite', capacity: 'Single',
          pricePerNight: 350, isAvailable: true,
          imageUrl: 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=400',
          amenities: ['WiFi', 'Gym', 'Spa', 'Dinner', 'Massage'],
        ),
        Room(
          id: 5, number: '5', viewType: 'Regular', capacity: 'double',
          pricePerNight: 200, isAvailable: false,
          imageUrl: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=400',
          amenities: ['WiFi', 'Gym', 'Spa', 'Dinner', 'Massage'],
        ),
      ];

  /// Initial employees seeded on first launch.
  static List<Employee> get employees => [
        Employee(
          id: 1, firstName: 'Alice', secondName: 'Smith',
          phone: '01234567890', department: 'Reception',
          hireDate: DateTime(2024, 1, 15),
        ),
        Employee(
          id: 2, firstName: 'Bob', secondName: 'Johnson',
          phone: '01111111111', department: 'Housekeeping',
          hireDate: DateTime(2024, 2, 20),
        ),
        Employee(
          id: 3, firstName: 'Carol', secondName: 'Davis',
          phone: '01555555555', department: 'Management',
          hireDate: DateTime(2024, 3, 10),
        ),
        Employee(
          id: 4, firstName: 'David', secondName: 'Martinez',
          phone: '01000000000', department: 'Management',
          hireDate: DateTime(2024, 3, 10),
        ),
      ];

  /// Last-used IDs matching the seed data above.
  static Map<String, int> get initialLastIds => {
        'roomId': 5,
        'guestId': 0,
        'reservationId': 0,
        'employeeId': 4,
      };
}
