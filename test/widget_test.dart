// Basic smoke test for the Hotel Management app.
//
// Verifies that the login screen renders correctly with the
// expected UI elements (title, guest portal, manager dashboard).

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:database_project/providers/room_provider.dart';
import 'package:database_project/providers/guest_provider.dart';
import 'package:database_project/providers/reservation_provider.dart';
import 'package:database_project/providers/employee_provider.dart';
import 'package:database_project/main.dart';

void main() {
  testWidgets('Login screen renders with Guest Portal and Manager Dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RoomProvider()),
          ChangeNotifierProvider(create: (_) => GuestProvider()),
          ChangeNotifierProvider(create: (_) => ReservationProvider()),
          ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ],
        child: const HotelApp(),
      ),
    );

    // Verify the login screen shows key elements
    expect(find.text('Grand Hotel'), findsOneWidget);
    expect(find.text('Guest Portal'), findsOneWidget);
    expect(find.text('Manager Dashboard'), findsOneWidget);
  });
}
