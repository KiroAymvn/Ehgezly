// lib/main.dart
//
// Application entry point. Initializes the HotelService singleton, then
// sets up providers and routes. Theme is defined in core/theme/app_theme.dart.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'debug_screen.dart';
import 'providers/employee_provider.dart';
import 'providers/guest_provider.dart';
import 'providers/reservation_provider.dart';
import 'providers/room_provider.dart';
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

  // Load persisted data before rendering the first frame
  await HotelService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => GuestProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()..loadEmployees()),
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