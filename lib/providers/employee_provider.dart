// providers/employee_provider.dart
import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/hotel_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final HotelService _hotelService = HotelService();
  List<Employee> _employees = [];

  List<Employee> get allEmployees => _employees;

  EmployeeProvider() {
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    await _hotelService.initialize();
    _employees = _hotelService.employees;
    notifyListeners();
  }

  Future<void> loadEmployees() async {
    await _loadEmployees();
  }

  Future<void> addEmployee({
    required String firstName,
    required String secondName,
    required String phone,
    required String department,
  }) async {
    try {
      await _hotelService.addEmployee(
        firstName: firstName,
        secondName: secondName,
        phone: phone,
        department: department,
      );

      // Reload employees from service
      _employees = _hotelService.employees;
      notifyListeners();
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
      await _hotelService.updateEmployee(
        employeeId: employeeId,
        firstName: firstName,
        secondName: secondName,
        phone: phone,
        department: department,
      );

      // Reload employees from service
      _employees = _hotelService.employees;
      notifyListeners();
    } catch (e) {
      print('Error updating employee: $e');
      rethrow;
    }
  }

  Future<void> deleteEmployee(int employeeId) async {
    try {
      await _hotelService.deleteEmployee(employeeId);

      // Reload employees from service
      _employees = _hotelService.employees;
      notifyListeners();
    } catch (e) {
      print('Error deleting employee: $e');
      rethrow;
    }
  }

  List<Employee> getEmployeesByDepartment(String department) {
    return _hotelService.getEmployeesByDepartment(department);
  }

  List<String> getUniqueDepartments() {
    return _hotelService.getUniqueDepartments();
  }

  Employee? getEmployeeById(int id) {
    return _hotelService.getEmployeeById(id);
  }

  Map<String, dynamic> getEmployeeStatistics() {
    return _hotelService.getEmployeeStatistics();
  }

  void notify() {
    notifyListeners();
  }
}