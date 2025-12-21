// services/hotel_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/employee.dart';
import '../models/room.dart';
import '../models/guest.dart';
import '../models/reservation.dart';

class HotelService {
  // Singleton instance
  static final HotelService _instance = HotelService._internal();
  factory HotelService() => _instance;
  HotelService._internal();

  // Keys for SharedPreferences
  static const String _roomsKey = 'hotel_rooms';
  static const String _guestsKey = 'hotel_guests';
  static const String _reservationsKey = 'hotel_reservations';
  static const String _lastIdKey = 'hotel_last_ids';
  static const String _employeesKey = 'hotel_employees';

  final List<Room> _rooms = [];
  final List<Guest> _guests = [];
  final List<Reservation> _reservations = [];
  final List<Employee> _employees = [];

  // Track last used IDs
  Map<String, int> _lastIds = {
    'roomId': 0,
    'guestId': 0,
    'reservationId': 0,
    'employeeId': 0,
  };

  // Getters
  List<Room> get rooms => List.unmodifiable(_rooms);
  List<Guest> get guests => List.unmodifiable(_guests);
  List<Reservation> get reservations => List.unmodifiable(_reservations);
  List<Employee> get employees => List.unmodifiable(_employees);

  // Available rooms - rooms that are marked as available
  List<Room> get availableRooms => _rooms.where((room) => room.isAvailable).toList();

  // ==================== INITIALIZATION & DATA MANAGEMENT ====================

  // Initialize service with saved data or sample data
  Future<void> initialize() async {
    await _loadAllData();

    // If no data exists, initialize with sample data
    if (_rooms.isEmpty) {
      _initializeSampleData();
      await saveAllData();
    }

    print('HotelService initialized:');
    print('- Rooms: ${_rooms.length}');
    print('- Guests: ${_guests.length}');
    print('- Reservations: ${_reservations.length}');
    print('- Employees: ${_employees.length}');
    print('- Last IDs: $_lastIds');
  }

  // Load all data from SharedPreferences
  Future<void> _loadAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load last IDs
      final lastIdsJson = prefs.getString(_lastIdKey);
      if (lastIdsJson != null) {
        _lastIds = Map<String, int>.from(json.decode(lastIdsJson));
      }

      // Load rooms
      final roomsJson = prefs.getString(_roomsKey);
      if (roomsJson != null && roomsJson.isNotEmpty) {
        final List<dynamic> roomsList = json.decode(roomsJson);
        _rooms.clear();
        for (var roomJson in roomsList) {
          try {
            _rooms.add(Room.fromJson(roomJson));
          } catch (e) {
            print('Error parsing room: $e');
          }
        }
      }

      // Load guests
      final guestsJson = prefs.getString(_guestsKey);
      if (guestsJson != null && guestsJson.isNotEmpty) {
        final List<dynamic> guestsList = json.decode(guestsJson);
        _guests.clear();
        for (var guestJson in guestsList) {
          try {
            _guests.add(Guest.fromJson(guestJson));
          } catch (e) {
            print('Error parsing guest: $e');
          }
        }
      }

      // Load reservations
      final reservationsJson = prefs.getString(_reservationsKey);
      if (reservationsJson != null && reservationsJson.isNotEmpty) {
        final List<dynamic> reservationsList = json.decode(reservationsJson);
        _reservations.clear();
        for (var resJson in reservationsList) {
          try {
            _reservations.add(Reservation.fromJson(resJson));
          } catch (e) {
            print('Error parsing reservation: $e');
          }
        }
      }

      // Load employees
      final employeesJson = prefs.getString(_employeesKey);
      if (employeesJson != null && employeesJson.isNotEmpty) {
        final List<dynamic> employeesList = json.decode(employeesJson);
        _employees.clear();
        for (var employeeJson in employeesList) {
          try {
            _employees.add(Employee.fromJson(employeeJson));
          } catch (e) {
            print('Error parsing employee: $e');
          }
        }
      }
    } catch (e) {
      print('Error loading data: $e');
      // Reset on error
      _rooms.clear();
      _guests.clear();
      _reservations.clear();
      _employees.clear();
      _lastIds = {
        'roomId': 0,
        'guestId': 0,
        'reservationId': 0,
        'employeeId': 0,
      };
    }
  }

  // Save all data to SharedPreferences
  Future<void> saveAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save last IDs
      await prefs.setString(_lastIdKey, json.encode(_lastIds));

      // Save rooms
      final roomsJson = json.encode(_rooms.map((room) => room.toJson()).toList());
      await prefs.setString(_roomsKey, roomsJson);

      // Save guests
      final guestsJson = json.encode(_guests.map((guest) => guest.toJson()).toList());
      await prefs.setString(_guestsKey, guestsJson);

      // Save reservations
      final reservationsJson = json.encode(_reservations.map((res) => res.toJson()).toList());
      await prefs.setString(_reservationsKey, reservationsJson);

      // Save employees
      final employeesJson = json.encode(_employees.map((employee) => employee.toJson()).toList());
      await prefs.setString(_employeesKey, employeesJson);

      print('Data saved successfully');
    } catch (e) {
      print('Error saving data: $e');
      rethrow;
    }
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    _rooms.clear();
    _guests.clear();
    _reservations.clear();
    _employees.clear();
    _lastIds = {
      'roomId': 0,
      'guestId': 0,
      'reservationId': 0,
      'employeeId': 0,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roomsKey);
    await prefs.remove(_guestsKey);
    await prefs.remove(_reservationsKey);
    await prefs.remove(_lastIdKey);
    await prefs.remove(_employeesKey);

    _initializeSampleData();
    await saveAllData();
  }

  // ==================== SAMPLE DATA INITIALIZATION ====================

  // Initialize sample rooms with new viewType and capacity
  void _initializeSampleData() {
    // Clear existing data
    _rooms.clear();
    _employees.clear();

    // Set initial IDs
    _lastIds['roomId'] = 5;
    _lastIds['employeeId'] = 3;

    // Initialize sample rooms
    _rooms.addAll([
      Room(
        id: 1,
        number: "1",
        viewType: 'Nile View',
        capacity: 'Single',
        pricePerNight: 150,
        isAvailable: true,
        imageUrl: 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
        amenities: ['WiFi', 'Gym', 'Spa', 'Dinner', 'Massage'],
      ),
      Room(
        id: 2,
        number: '2',
        viewType: 'Nile View',
        capacity: 'Double',
        pricePerNight: 300,
        isAvailable: false,
        imageUrl: 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=400',
        amenities: ['WiFi', 'Gym', 'Spa', 'Dinner', 'Massage'],
      ),
      Room(
        id: 3,
        number: '3',
        viewType: 'Regular',
        capacity: 'Triple',
        pricePerNight: 220,
        isAvailable: true,
        imageUrl: 'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=400',
        amenities: ['WiFi', 'Gym', 'Spa', 'Dinner', 'Massage'],
      ),
      Room(
        id: 4,
        number: '4',
        viewType: 'suite',
        capacity: 'Single',
        pricePerNight: 350,
        isAvailable: true,
        imageUrl: 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=400',
        amenities: ['WiFi', 'Gym', 'Spa', 'Dinner', 'Massage'],
      ),
      Room(
        id: 5,
        number: '5',
        viewType: 'Regular',
        capacity: 'double',
        pricePerNight: 200,
        isAvailable: false,
        imageUrl: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=400',
        amenities: ['WiFi', 'Gym', 'Spa', 'Dinner', 'Massage'],
      ),
    ]);

    // Initialize sample employees
    _employees.addAll([
      Employee(
        id: 1,
        firstName: 'Alice',
        secondName: 'Smith',
        phone: '01234567890',
        department: 'Reception',
        hireDate: DateTime(2024, 1, 15),
      ),
      Employee(
        id: 2,
        firstName: 'Bob',
        secondName: 'Johnson',
        phone: '01111111111',
        department: 'Housekeeping',
        hireDate: DateTime(2024, 2, 20),
      ),
      Employee(
        id: 3,
        firstName: 'Carol',
        secondName: 'Davis',
        phone: '01555555555',
        department: 'Management',
        hireDate: DateTime(2024, 3, 10),
      ),
      Employee(
        id: 3,
        firstName: 'David',
        secondName: 'Martinez',
        phone: '01000000000',
        department: 'Management',
        hireDate: DateTime(2024, 3, 10),
      ),

    ]);
  }

  // ==================== DATE CONFLICT CHECKING METHODS ====================

  // Check if dates overlap
  bool _datesOverlap(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  // Check if room has conflicting reservation for given dates
  bool _hasDateConflict(int roomId, DateTime checkIn, DateTime checkOut) {
    for (final reservation in _reservations) {
      if (reservation.roomId == roomId &&
          reservation.status.toLowerCase() != 'cancelled' &&
          reservation.status.toLowerCase() != 'checked-out') {
        if (_datesOverlap(
            reservation.checkIn,
            reservation.checkOut,
            checkIn,
            checkOut
        )) {
          return true; // Conflict found
        }
      }
    }
    return false; // No conflict
  }

  // Get rooms available for specific dates
  List<Room> getAvailableRoomsForDates(DateTime checkIn, DateTime checkOut) {
    return _rooms.where((room) {
      return !_hasDateConflict(room.id, checkIn, checkOut);
    }).toList();
  }

  // Check if a specific room is available for dates
  bool isRoomAvailableForDates(int roomId, DateTime checkIn, DateTime checkOut) {
    return !_hasDateConflict(roomId, checkIn, checkOut);
  }

  // Get upcoming reservations for a room
  List<Reservation> getUpcomingReservationsForRoom(int roomId) {
    final now = DateTime.now();
    return _reservations.where((res) {
      return res.roomId == roomId &&
          res.status == 'Confirmed' &&
          res.checkOut.isAfter(now);
    }).toList();
  }

  // ==================== ROOM METHODS ====================

  Room? getRoomById(int id) {
    try {
      return _rooms.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addRoom({
    required String number,
    required String viewType,
    required String capacity,
    required double pricePerNight,
    String imageUrl = '',
    List<String> amenities = const [],
  }) async {
    try {
      _lastIds['roomId'] = (_lastIds['roomId'] ?? 0) + 1;
      final newRoom = Room(
        id: _lastIds['roomId']!,
        number: number,
        viewType: viewType,
        capacity: capacity,
        pricePerNight: pricePerNight,
        isAvailable: true,
        imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
        amenities: amenities,
      );
      _rooms.add(newRoom);
      await saveAllData();
    } catch (e) {
      print('Error adding room: $e');
      rethrow;
    }
  }

  Future<void> updateRoom({
    required int roomId,
    required String number,
    required String viewType,
    required String capacity,
    required double pricePerNight,
    required bool isAvailable,
    String imageUrl = '',
    List<String> amenities = const [],
  }) async {
    try {
      final room = getRoomById(roomId);
      if (room != null) {
        final index = _rooms.indexOf(room);
        _rooms[index] = Room(
          id: roomId,
          number: number,
          viewType: viewType,
          capacity: capacity,
          pricePerNight: pricePerNight,
          isAvailable: isAvailable,
          imageUrl: imageUrl.isNotEmpty ? imageUrl : room.imageUrl,
          amenities: amenities,
        );
        await saveAllData();
      }
    } catch (e) {
      print('Error updating room: $e');
      rethrow;
    }
  }

  Future<void> deleteRoom(int roomId) async {
    try {
      // Check if room has any active reservations
      final hasActiveReservations = _reservations.any((res) =>
      res.roomId == roomId &&
          res.status.toLowerCase() != 'cancelled' &&
          res.status.toLowerCase() != 'checked-out');

      if (hasActiveReservations) {
        throw Exception('Cannot delete room with active reservations. Cancel or complete reservations first.');
      }

      _rooms.removeWhere((room) => room.id == roomId);
      await saveAllData();
    } catch (e) {
      print('Error deleting room: $e');
      rethrow;
    }
  }

  Future<void> updateRoomAvailability(int roomId, bool isAvailable) async {
    try {
      final room = getRoomById(roomId);
      if (room != null) {
        final index = _rooms.indexOf(room);
        _rooms[index] = Room(
          id: roomId,
          number: room.number,
          viewType: room.viewType,
          capacity: room.capacity,
          pricePerNight: room.pricePerNight,
          isAvailable: isAvailable,
          imageUrl: room.imageUrl,
          amenities: room.amenities,
        );
        await saveAllData();
      }
    } catch (e) {
      print('Error updating room availability: $e');
      rethrow;
    }
  }

  // ==================== GUEST METHODS ====================

  Guest? getGuestById(int id) {
    try {
      return _guests.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  // In the addGuest method:
  Future<void> addGuest({
    required String name,
    required String phone,
    String email = '',
    DateTime? birthday,  // Make sure this parameter is here
  }) async {
    try {
      _lastIds['guestId'] = (_lastIds['guestId'] ?? 0) + 1;
      final newGuest = Guest(
        id: _lastIds['guestId']!,
        name: name,
        phone: phone,
        email: email,
        birthday: birthday,  // Pass to Guest constructor
      );
      _guests.add(newGuest);
      await saveAllData();
    } catch (e) {
      print('Error adding guest: $e');
      rethrow;
    }
  }

// In the updateGuest method:
  Future<void> updateGuest({
    required int guestId,
    required String name,
    required String phone,
    String email = '',
    DateTime? birthday,  // Add birthday parameter
  }) async {
    try {
      final guest = getGuestById(guestId);
      if (guest != null) {
        final index = _guests.indexOf(guest);
        _guests[index] = Guest(
          id: guestId,
          name: name,
          phone: phone,
          email: email,
          birthday: birthday,  // Add birthday
        );
        await saveAllData();
      }
    } catch (e) {
      print('Error updating guest: $e');
      rethrow;
    }
  }

  Future<void> deleteGuest(int guestId) async {
    try {
      _guests.removeWhere((guest) => guest.id == guestId);
      _reservations.removeWhere((reservation) => reservation.guestId == guestId);
      await saveAllData();
    } catch (e) {
      print('Error deleting guest: $e');
      rethrow;
    }
  }

  // ==================== RESERVATION METHODS ====================

  Reservation? getReservationById(int id) {
    try {
      return _reservations.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addReservation({
    required int guestId,
    required int roomId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    try {
      // Validate room exists
      final room = getRoomById(roomId);
      if (room == null) {
        throw Exception('Room does not exist');
      }

      // Validate guest exists
      final guest = getGuestById(guestId);
      if (guest == null) {
        throw Exception('Guest does not exist');
      }

      // Validate dates
      if (checkOut.isBefore(checkIn) || checkOut.isAtSameMomentAs(checkIn)) {
        throw Exception('Check-out date must be after check-in date');
      }

      // Check for date conflicts
      if (_hasDateConflict(roomId, checkIn, checkOut)) {
        throw Exception('Room already booked for selected dates. Please choose different dates.');
      }

      // Check if room is marked as available
      if (!room.isAvailable) {
        throw Exception('Room is currently marked as unavailable');
      }

      _lastIds['reservationId'] = (_lastIds['reservationId'] ?? 0) + 1;
      final newReservation = Reservation(
        id: _lastIds['reservationId']!,
        guestId: guestId,
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
        status: 'Confirmed',
      );

      _reservations.add(newReservation);
      await saveAllData();
    } catch (e) {
      print('Error adding reservation: $e');
      rethrow;
    }
  }

  Future<void> updateReservationStatus(int reservationId, String newStatus) async {
    try {
      final reservation = getReservationById(reservationId);
      if (reservation == null) return;

      final index = _reservations.indexOf(reservation);
      _reservations[index] = Reservation(
        id: reservation.id,
        guestId: reservation.guestId,
        roomId: reservation.roomId,
        checkIn: reservation.checkIn,
        checkOut: reservation.checkOut,
        status: newStatus,
      );

      // Handle room availability based on status
      final room = getRoomById(reservation.roomId);
      if (room != null) {
        if (newStatus.toLowerCase() == 'cancelled' ||
            newStatus.toLowerCase() == 'checked-out') {
          room.isAvailable = true;
        } else if (newStatus.toLowerCase() == 'checked-in') {
          room.isAvailable = false;
        }
      }

      await saveAllData();
    } catch (e) {
      print('Error updating reservation status: $e');
      rethrow;
    }
  }

  Future<void> updateReservationDates({
    required int reservationId,
    required DateTime newCheckIn,
    required DateTime newCheckOut,
  }) async {
    try {
      final reservation = getReservationById(reservationId);
      if (reservation == null) return;

      // Validate new dates
      if (newCheckOut.isBefore(newCheckIn) || newCheckOut.isAtSameMomentAs(newCheckIn)) {
        throw Exception('Check-out date must be after check-in date');
      }

      // Check for date conflicts (excluding current reservation)
      for (final otherRes in _reservations) {
        if (otherRes.id != reservationId &&
            otherRes.roomId == reservation.roomId &&
            otherRes.status.toLowerCase() != 'cancelled' &&
            otherRes.status.toLowerCase() != 'checked-out') {
          if (_datesOverlap(
              otherRes.checkIn,
              otherRes.checkOut,
              newCheckIn,
              newCheckOut
          )) {
            throw Exception('New dates conflict with existing reservation for this room');
          }
        }
      }

      final index = _reservations.indexOf(reservation);
      _reservations[index] = Reservation(
        id: reservation.id,
        guestId: reservation.guestId,
        roomId: reservation.roomId,
        checkIn: newCheckIn,
        checkOut: newCheckOut,
        status: reservation.status,
      );

      await saveAllData();
    } catch (e) {
      print('Error updating reservation dates: $e');
      rethrow;
    }
  }

  Future<void> deleteReservation(int reservationId) async {
    try {
      final reservation = getReservationById(reservationId);
      if (reservation != null) {
        // Free up the room if reservation is active
        if (reservation.status.toLowerCase() != 'cancelled' &&
            reservation.status.toLowerCase() != 'checked-out') {
          final room = getRoomById(reservation.roomId);
          if (room != null) {
            room.isAvailable = true;
          }
        }
        _reservations.removeWhere((res) => res.id == reservationId);
        await saveAllData();
      }
    } catch (e) {
      print('Error deleting reservation: $e');
      rethrow;
    }
  }

  // ==================== EMPLOYEE METHODS ====================

  Employee? getEmployeeById(int id) {
    try {
      return _employees.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addEmployee({
    required String firstName,
    required String secondName,
    required String phone,
    required String department,
  }) async {
    try {
      _lastIds['employeeId'] = (_lastIds['employeeId'] ?? 0) + 1;
      final newEmployee = Employee(
        id: _lastIds['employeeId']!,
        firstName: firstName,
        secondName: secondName,
        phone: phone,
        department: department,
        hireDate: DateTime.now(),
      );
      _employees.add(newEmployee);
      await saveAllData();
    } catch (e) {
      print('Error adding employee: $e');
      rethrow;
    }
  }

  Future<void> updateEmployee({
    required int employeeId,
    required String firstName,
    required String secondName,
    required String phone,
    required String department,
  }) async {
    try {
      final employee = getEmployeeById(employeeId);
      if (employee != null) {
        final index = _employees.indexOf(employee);
        _employees[index] = Employee(
          id: employeeId,
          firstName: firstName,
          secondName: secondName,
          phone: phone,
          department: department,
          hireDate: employee.hireDate,
        );
        await saveAllData();
      }
    } catch (e) {
      print('Error updating employee: $e');
      rethrow;
    }
  }

  Future<void> deleteEmployee(int employeeId) async {
    try {
      _employees.removeWhere((employee) => employee.id == employeeId);
      await saveAllData();
    } catch (e) {
      print('Error deleting employee: $e');
      rethrow;
    }
  }

  // Get employees by department
  List<Employee> getEmployeesByDepartment(String department) {
    return _employees
        .where((employee) => employee.department == department)
        .toList();
  }

  // Get all unique departments
  List<String> getUniqueDepartments() {
    return _employees
        .map((e) => e.department)
        .toSet()
        .toList();
  }

  // Get employee statistics
  Map<String, dynamic> getEmployeeStatistics() {
    final departments = getUniqueDepartments();
    final Map<String, int> countByDept = {};

    for (var dept in departments) {
      countByDept[dept] = getEmployeesByDepartment(dept).length;
    }

    return {
      'totalEmployees': _employees.length,
      'countByDepartment': countByDept,
      'departments': departments,
    };
  }

  // ==================== BUSINESS LOGIC ====================

  List<Reservation> getReservationsForGuest(int guestId) {
    return _reservations
        .where((reservation) => reservation.guestId == guestId)
        .toList();
  }

  List<Reservation> getReservationsForRoom(int roomId) {
    return _reservations
        .where((reservation) => reservation.roomId == roomId)
        .toList();
  }

  double calculateExpectedRevenue() {
    double totalRevenue = 0;

    for (final reservation in _reservations) {
      final room = getRoomById(reservation.roomId);
      if (room != null && reservation.status.toLowerCase() != 'cancelled') {
        final nights = reservation.checkOut.difference(reservation.checkIn).inDays;
        totalRevenue += room.pricePerNight * nights;
      }
    }

    return totalRevenue;
  }

  double getOccupancyRate() {
    if (_rooms.isEmpty) return 0.0;
    final occupiedRooms = _rooms.where((room) => !room.isAvailable).length;
    return occupiedRooms / _rooms.length;
  }

  // Updated: Get available rooms by view type
  Map<String, int> getAvailableRoomsByViewType() {
    final Map<String, int> result = {};

    for (final room in _rooms) {
      if (room.isAvailable) {
        result[room.viewType] = (result[room.viewType] ?? 0) + 1;
      }
    }

    return result;
  }

  // Updated: Get available rooms by capacity
  Map<String, int> getAvailableRoomsByCapacity() {
    final Map<String, int> result = {};

    for (final room in _rooms) {
      if (room.isAvailable) {
        result[room.capacity] = (result[room.capacity] ?? 0) + 1;
      }
    }

    return result;
  }

  // Updated: Get revenue by view type
  Map<String, double> getRevenueByViewType() {
    final Map<String, double> result = {};

    for (final reservation in _reservations) {
      if (reservation.status.toLowerCase() != 'cancelled') {
        final room = getRoomById(reservation.roomId);
        if (room != null) {
          final nights = reservation.checkOut.difference(reservation.checkIn).inDays;
          final revenue = room.pricePerNight * nights;
          result[room.viewType] = (result[room.viewType] ?? 0) + revenue;
        }
      }
    }

    return result;
  }

  // Updated: Get revenue by capacity
  Map<String, double> getRevenueByCapacity() {
    final Map<String, double> result = {};

    for (final reservation in _reservations) {
      if (reservation.status.toLowerCase() != 'cancelled') {
        final room = getRoomById(reservation.roomId);
        if (room != null) {
          final nights = reservation.checkOut.difference(reservation.checkIn).inDays;
          final revenue = room.pricePerNight * nights;
          result[room.capacity] = (result[room.capacity] ?? 0) + revenue;
        }
      }
    }

    return result;
  }

  // Get guest statistics
  Map<String, dynamic> getGuestStatistics() {
    return {
      'totalGuests': _guests.length,
      'guestsWithReservations': _guests.where((guest) {
        return _reservations.any((res) => res.guestId == guest.id);
      }).length,
      'topSpenders': _getTopSpendingGuests(),
    };
  }

  List<Map<String, dynamic>> _getTopSpendingGuests() {
    final Map<int, double> guestSpending = {};

    for (final reservation in _reservations) {
      if (reservation.status.toLowerCase() != 'cancelled') {
        final room = getRoomById(reservation.roomId);
        if (room != null) {
          final nights = reservation.checkOut.difference(reservation.checkIn).inDays;
          final revenue = room.pricePerNight * nights;
          guestSpending[reservation.guestId] = (guestSpending[reservation.guestId] ?? 0) + revenue;
        }
      }
    }

    final List<Map<String, dynamic>> result = [];

    guestSpending.forEach((guestId, amount) {
      final guest = getGuestById(guestId);
      if (guest != null) {
        result.add({
          'guest': guest,
          'totalSpent': amount,
          'reservationCount': _reservations.where((r) => r.guestId == guestId).length,
        });
      }
    });

    result.sort((a, b) => b['totalSpent'].compareTo(a['totalSpent']));
    return result.take(5).toList();
  }

  // Export all data for backup
  Future<Map<String, dynamic>> exportAllData() async {
    return {
      'rooms': _rooms.map((r) => r.toJson()).toList(),
      'guests': _guests.map((g) => g.toJson()).toList(),
      'reservations': _reservations.map((r) => r.toJson()).toList(),
      'employees': _employees.map((e) => e.toJson()).toList(),
      'lastIds': _lastIds,
      'statistics': {
        'totalRevenue': calculateExpectedRevenue(),
        'occupancyRate': getOccupancyRate(),
        'totalGuests': _guests.length,
        'totalRooms': _rooms.length,
        'totalReservations': _reservations.length,
        'totalEmployees': _employees.length,
        'revenueByViewType': getRevenueByViewType(),
        'revenueByCapacity': getRevenueByCapacity(),
        'availableByViewType': getAvailableRoomsByViewType(),
        'availableByCapacity': getAvailableRoomsByCapacity(),
      },
    };
  }

  // Helper method to get rooms filtered by view type and capacity
  List<Room> getRoomsByViewTypeAndCapacity(String? viewType, String? capacity) {
    return _rooms.where((room) {
      bool matches = true;
      if (viewType != null && viewType != 'All') {
        matches = matches && room.viewType == viewType;
      }
      if (capacity != null) {
        matches = matches && room.capacity == capacity;
      }
      return matches;
    }).toList();
  }
}