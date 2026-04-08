// lib/main.dart
//
// Application entry point. Initializes the HotelService singleton, then
// sets up providers and routes. Theme is defined in core/theme/app_theme.dart.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'debug_screen.dart';
import 'models/room.dart';
import 'models/guest.dart';
import 'models/reservation.dart';
import 'models/employee.dart';
import 'features/rooms/cubit/room_cubit.dart';
import 'features/guests/cubit/guest_cubit.dart';
import 'features/reservations/cubit/reservation_cubit.dart';
import 'features/employees/cubit/employee_cubit.dart';
import 'features/customer/cubit/customer_filter_cubit.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/manager/all_employees_screen.dart';
import 'screens/manager/all_guests_screen.dart';
import 'screens/manager/all_reservations_screen.dart';
import 'screens/manager/all_rooms_screen.dart';
import 'screens/manager/manager_home_screen.dart';
import 'services/hotel_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register adapters
  await Hive.initFlutter();
  Hive.registerAdapter(RoomAdapter());
  Hive.registerAdapter(GuestAdapter());
  Hive.registerAdapter(ReservationAdapter());
  Hive.registerAdapter(EmployeeAdapter());

  // Open Hive boxes for local storage
  await Hive.openBox<Room>('hotel_rooms_box');
  await Hive.openBox<Guest>('hotel_guests_box');
  await Hive.openBox<Reservation>('hotel_reservations_box');
  await Hive.openBox<Employee>('hotel_employees_box');
  await Hive.openBox('hotel_meta_box');

  // Load persisted data before rendering the first frame
  await HotelService().initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RoomCubit()..loadRooms()),
        BlocProvider(create: (_) => GuestCubit()..loadGuests()),
        BlocProvider(create: (_) => ReservationCubit()..loadReservations()),
        BlocProvider(create: (_) => EmployeeCubit()..loadEmployees()),
        BlocProvider(create: (_) => CustomerFilterCubit()),
      ],
      child: const HotelApp(),
    ),
  );
}

class HotelApp extends StatelessWidget {
  const HotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/':                    (ctx) => LoginScreen(),
        '/customerHome':        (ctx) => CustomerHomeScreen(),
        '/managerHome':         (ctx) => ManagerHomeScreen(),
        '/manager/rooms':       (ctx) => AllRoomsScreen(),
        '/manager/guests':      (ctx) => AllGuestsScreen(),
        '/manager/reservations':(ctx) => AllReservationsScreen(),
        '/manager/employees':   (ctx) => AllEmployeesScreen(),
        '/debug':               (ctx) => DebugScreen(),
      },
    );
  }
}