// services/hotel_service.dart
//
// Singleton facade that coordinates the four repositories and handles
// persistence. Screens and providers interact only with this class —
// they never access repositories directly.

import '../data/local/local_storage_service.dart';
import '../data/local/sample_data.dart';
import '../data/repositories/employee_repository.dart';
import '../data/repositories/guest_repository.dart';
import '../data/repositories/reservation_repository.dart';
import '../data/repositories/room_repository.dart';
import '../models/employee.dart';
import '../models/guest.dart';
import '../models/reservation.dart';
import '../models/room.dart';

class HotelService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final HotelService _instance = HotelService._internal();
  factory HotelService() => _instance;
  HotelService._internal();

  // ── Internal State ─────────────────────────────────────────────────────────
  final LocalStorageService _storage = LocalStorageService();

  final List<Room>        _rooms        = [];
  final List<Guest>       _guests       = [];
  final List<Reservation> _reservations = [];
  final List<Employee>    _employees    = [];

  Map<String, int> _lastIds = {
    'roomId': 0, 'guestId': 0, 'reservationId': 0, 'employeeId': 0,
  };

  // ── Lazy Repository Access ─────────────────────────────────────────────────
  // Repositories are created on first access so they always receive the
  // live list references (not copies).
  RoomRepository?        _roomRepo;
  GuestRepository?       _guestRepo;
  ReservationRepository? _resRepo;
  EmployeeRepository?    _empRepo;

  RoomRepository        get _rooms_         => _roomRepo        ??= RoomRepository(rooms: _rooms, reservations: _reservations);
  GuestRepository       get _guests_        => _guestRepo       ??= GuestRepository(guests: _guests, reservations: _reservations);
  ReservationRepository get _reservations_  => _resRepo         ??= ReservationRepository(reservations: _reservations);
  EmployeeRepository    get _employees_     => _empRepo         ??= EmployeeRepository(employees: _employees);

  // ── Public Getters ─────────────────────────────────────────────────────────
  List<Room>        get rooms        => _rooms_.all;
  List<Guest>       get guests       => _guests_.all;
  List<Reservation> get reservations => _reservations_.all;
  List<Employee>    get employees    => _employees_.all;
  List<Room>        get availableRooms => _rooms_.available;

  // ── Initialization ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    final data = await _storage.loadAll();

    _lastIds = data.lastIds;
    _rooms       ..clear()..addAll(data.rooms);
    _guests      ..clear()..addAll(data.guests);
    _reservations..clear()..addAll(data.reservations);
    _employees   ..clear()..addAll(data.employees);

    if (_rooms.isEmpty) {
      _rooms    .addAll(SampleData.rooms);
      _employees.addAll(SampleData.employees);
      _lastIds = SampleData.initialLastIds;
      await saveAllData();
    }
  }

  Future<void> saveAllData() async {
    await _storage.saveAll(
      rooms: _rooms,
      guests: _guests,
      reservations: _reservations,
      employees: _employees,
      lastIds: _lastIds,
    );
  }

  Future<void> clearAllData() async {
    _rooms       .clear();
    _guests      .clear();
    _reservations.clear();
    _employees   .clear();
    _lastIds = {'roomId': 0, 'guestId': 0, 'reservationId': 0, 'employeeId': 0};

    await _storage.clearAll();
    _rooms    .addAll(SampleData.rooms);
    _employees.addAll(SampleData.employees);
    _lastIds = SampleData.initialLastIds;
    await saveAllData();
  }

  // ── Room Operations ────────────────────────────────────────────────────────

  Room? getRoomById(int id) => _rooms_.getById(id);

  List<Room> getAvailableRoomsForDates(DateTime checkIn, DateTime checkOut) =>
      _rooms_.getAvailableForDates(checkIn, checkOut);

  bool isRoomAvailableForDates(int roomId, DateTime checkIn, DateTime checkOut) =>
      _rooms_.isAvailableForDates(roomId, checkIn, checkOut);

  List<Reservation> getUpcomingReservationsForRoom(int roomId) =>
      _rooms_.getUpcomingReservations(roomId);

  Future<void> addRoom({
    required String number,
    required String viewType,
    required String capacity,
    required double pricePerNight,
    String imageUrl = '',
    List<String> amenities = const [],
  }) async {
    _lastIds['roomId'] = (_lastIds['roomId'] ?? 0) + 1;
    _rooms_.add(
      newId: _lastIds['roomId']!,
      number: number, viewType: viewType, capacity: capacity,
      pricePerNight: pricePerNight, imageUrl: imageUrl, amenities: amenities,
    );
    await saveAllData();
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
    _rooms_.update(
      roomId: roomId, number: number, viewType: viewType, capacity: capacity,
      pricePerNight: pricePerNight, isAvailable: isAvailable,
      imageUrl: imageUrl, amenities: amenities,
    );
    await saveAllData();
  }

  Future<void> deleteRoom(int roomId) async {
    _rooms_.delete(roomId); // throws if active reservations exist
    await saveAllData();
  }

  Future<void> updateRoomAvailability(int roomId, bool isAvailable) async {
    _rooms_.updateAvailability(roomId, isAvailable);
    await saveAllData();
  }

  // ── Guest Operations ───────────────────────────────────────────────────────

  Guest? getGuestById(int id) => _guests_.getById(id);

  Future<void> addGuest({
    required String name,
    required String phone,
    String email = '',
    DateTime? birthday,
  }) async {
    _lastIds['guestId'] = (_lastIds['guestId'] ?? 0) + 1;
    _guests_.add(
      newId: _lastIds['guestId']!,
      name: name, phone: phone, email: email, birthday: birthday,
    );
    await saveAllData();
  }

  Future<void> updateGuest({
    required int guestId,
    required String name,
    required String phone,
    String email = '',
    DateTime? birthday,
  }) async {
    _guests_.update(
      guestId: guestId, name: name, phone: phone, email: email, birthday: birthday,
    );
    await saveAllData();
  }

  Future<void> deleteGuest(int guestId) async {
    _guests_.delete(guestId);
    await saveAllData();
  }

  // ── Reservation Operations ─────────────────────────────────────────────────

  Reservation? getReservationById(int id) => _reservations_.getById(id);

  Future<void> addReservation({
    required int guestId,
    required int roomId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    // Validate that room and guest exist before delegating
    final room = getRoomById(roomId);
    if (room == null) throw Exception('Room does not exist');

    final guest = getGuestById(guestId);
    if (guest == null) throw Exception('Guest does not exist');

    if (!room.isAvailable) throw Exception('Room is currently marked as unavailable');

    _lastIds['reservationId'] = (_lastIds['reservationId'] ?? 0) + 1;
    _reservations_.add(
      newId: _lastIds['reservationId']!,
      guestId: guestId, roomId: roomId, checkIn: checkIn, checkOut: checkOut,
      hasConflict: (rId, ci, co) => !_rooms_.isAvailableForDates(rId, ci, co),
    );
    await saveAllData();
  }

  Future<void> updateReservationStatus(int reservationId, String newStatus) async {
    final updated = _reservations_.updateStatus(reservationId, newStatus);
    if (updated == null) return;

    // Sync room availability based on status transition
    if (newStatus.toLowerCase() == 'cancelled' ||
        newStatus.toLowerCase() == 'checked-out') {
      _rooms_.updateAvailability(updated.roomId, true);
    } else if (newStatus.toLowerCase() == 'checked-in') {
      _rooms_.updateAvailability(updated.roomId, false);
    }

    await saveAllData();
  }

  Future<void> updateReservationDates({
    required int reservationId,
    required DateTime newCheckIn,
    required DateTime newCheckOut,
  }) async {
    _reservations_.updateDates(
      reservationId: reservationId,
      newCheckIn: newCheckIn,
      newCheckOut: newCheckOut,
      hasConflict: (roomId, ci, co, excludeId) {
        for (final r in _reservations) {
          if (r.id != excludeId &&
              r.roomId == roomId &&
              r.status.toLowerCase() != 'cancelled' &&
              r.status.toLowerCase() != 'checked-out') {
            if (ci.isBefore(r.checkOut) && co.isAfter(r.checkIn)) return true;
          }
        }
        return false;
      },
    );
    await saveAllData();
  }

  Future<void> deleteReservation(int reservationId) async {
    final deleted = _reservations_.delete(reservationId);
    if (deleted != null &&
        deleted.status.toLowerCase() != 'cancelled' &&
        deleted.status.toLowerCase() != 'checked-out') {
      _rooms_.updateAvailability(deleted.roomId, true);
    }
    await saveAllData();
  }

  // ── Employee Operations ────────────────────────────────────────────────────

  Employee? getEmployeeById(int id) => _employees_.getById(id);

  Future<void> addEmployee({
    required String firstName,
    required String secondName,
    required String phone,
    required String department,
  }) async {
    _lastIds['employeeId'] = (_lastIds['employeeId'] ?? 0) + 1;
    _employees_.add(
      newId: _lastIds['employeeId']!,
      firstName: firstName, secondName: secondName,
      phone: phone, department: department,
    );
    await saveAllData();
  }

  Future<void> updateEmployee({
    required int employeeId,
    required String firstName,
    required String secondName,
    required String phone,
    required String department,
  }) async {
    _employees_.update(
      employeeId: employeeId, firstName: firstName,
      secondName: secondName, phone: phone, department: department,
    );
    await saveAllData();
  }

  Future<void> deleteEmployee(int employeeId) async {
    _employees_.delete(employeeId);
    await saveAllData();
  }

  List<Employee> getEmployeesByDepartment(String department) =>
      _employees_.getByDepartment(department);

  List<String> getUniqueDepartments() => _employees_.getUniqueDepartments();

  // ── Business Logic ─────────────────────────────────────────────────────────

  List<Reservation> getReservationsForGuest(int guestId) =>
      _reservations_.getForGuest(guestId);

  List<Reservation> getReservationsForRoom(int roomId) =>
      _reservations_.getForRoom(roomId);

  double calculateExpectedRevenue() {
    double total = 0;
    for (final res in _reservations) {
      if (res.status.toLowerCase() == 'cancelled') continue;
      final room = getRoomById(res.roomId);
      if (room != null) {
        total += room.pricePerNight * res.checkOut.difference(res.checkIn).inDays;
      }
    }
    return total;
  }

  double getOccupancyRate() {
    if (_rooms.isEmpty) return 0.0;
    return _rooms.where((r) => !r.isAvailable).length / _rooms.length;
  }
}