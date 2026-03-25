// providers/employee_provider.dart
//
// State management for Employees. Delegates all data operations to HotelService
// and notifies listeners so the UI rebuilds automatically.

import 'package:flutter/foundation.dart';
import '../models/employee.dart';
import '../services/hotel_service.dart';

class EmployeeProvider with ChangeNotifier {
  final HotelService _service = HotelService();

  // EmployeeProvider reads directly from the service list (no local copy needed)
  List<Employee> get allEmployees => _service.employees;

  /// Call once at startup to ensure data is initialized.
  Future<void> loadEmployees() async {
    notifyListeners();
  }

  Future<void> addEmployee({
    required String firstName,
    required String secondName,
    required String phone,
    required String department,
  }) async {
    await _service.addEmployee(
      firstName: firstName, secondName: secondName,
      phone: phone, department: department,
    );
    notifyListeners();
  }

  Future<void> updateEmployee({
    required int employeeId,
    required String firstName,
    required String secondName,
    required String phone,
    required String department,
  }) async {
    await _service.updateEmployee(
      employeeId: employeeId, firstName: firstName, secondName: secondName,
      phone: phone, department: department,
    );
    notifyListeners();
  }

  Future<void> deleteEmployee(int employeeId) async {
    await _service.deleteEmployee(employeeId);
    notifyListeners();
  }

  List<Employee> getByDepartment(String department) =>
      _service.getEmployeesByDepartment(department);

  Employee? getById(int id) => _service.getEmployeeById(id);
}