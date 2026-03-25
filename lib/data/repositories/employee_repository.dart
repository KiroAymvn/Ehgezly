// data/repositories/employee_repository.dart
//
// Handles all CRUD operations for Employee entities.

import '../../models/employee.dart';

class EmployeeRepository {
  final List<Employee> _employees;

  const EmployeeRepository({required List<Employee> employees})
      : _employees = employees;

  // ── Queries ────────────────────────────────────────────────────────────────

  List<Employee> get all => List.unmodifiable(_employees);

  Employee? getById(int id) {
    try {
      return _employees.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Employee> getByDepartment(String department) =>
      _employees.where((e) => e.department == department).toList();

  List<String> getUniqueDepartments() =>
      _employees.map((e) => e.department).toSet().toList();

  // ── Mutations ──────────────────────────────────────────────────────────────

  Employee add({
    required int newId,
    required String firstName,
    required String secondName,
    required String phone,
    required String department,
  }) {
    final employee = Employee(
      id: newId,
      firstName: firstName,
      secondName: secondName,
      phone: phone,
      department: department,
      hireDate: DateTime.now(),
    );
    _employees.add(employee);
    return employee;
  }

  void update({
    required int employeeId,
    required String firstName,
    required String secondName,
    required String phone,
    required String department,
  }) {
    final existing = getById(employeeId);
    if (existing == null) return;
    final index = _employees.indexOf(existing);
    _employees[index] = Employee(
      id: employeeId,
      firstName: firstName,
      secondName: secondName,
      phone: phone,
      department: department,
      hireDate: existing.hireDate,
    );
  }

  void delete(int employeeId) {
    _employees.removeWhere((e) => e.id == employeeId);
  }
}
