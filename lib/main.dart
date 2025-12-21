// lib/main.dart
import 'package:database_project/providers/employee_provider.dart';
import 'package:database_project/providers/guest_provider.dart';
import 'package:database_project/providers/reservation_provider.dart';
import 'package:database_project/providers/room__provider.dart';
import 'package:database_project/screens/customer/customer_home_screen.dart';
import 'package:database_project/screens/login_screen.dart';
import 'package:database_project/screens/manager/all_employees_screen.dart';
import 'package:database_project/screens/manager/all_guests_screen.dart';
import 'package:database_project/screens/manager/all_reservations_screen.dart';
import 'package:database_project/screens/manager/all_rooms_screen.dart';
import 'package:database_project/screens/manager/manager_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For better date formatting
import 'debug_screen.dart';
import 'services/hotel_service.dart'; // Import the HotelService

void main() async {

  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HotelService and load saved data
  final hotelService = HotelService();
  await hotelService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => GuestProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()..loadEmployees()),
      ],
      child: HotelApp(),
    ),
  );
}

class HotelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xffe5eaf6),
        primarySwatch: Colors.indigo,
        fontFamily: 'Poppins',
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xffe5eaf6),
          foregroundColor: Colors.indigo,
          elevation: 3,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.indigo),
        ),
        cardTheme: CardThemeData(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      initialRoute: '/',
// Add to main.dart routes
      routes: {
        '/': (ctx) => LoginScreen(),
        '/customerHome': (ctx) => CustomerHomeScreen(),
        '/managerHome': (ctx) => ManagerHomeScreen(),
        '/manager/rooms': (ctx) => AllRoomsScreen(),
        '/manager/guests': (ctx) => AllGuestsScreen(),
        '/manager/reservations': (ctx) => AllReservationsScreen(),
        '/manager/employees': (context) => AllEmployeesScreen(),
        '/debug': (ctx) => DebugScreen(), // Add this line
      },    );
  }
}