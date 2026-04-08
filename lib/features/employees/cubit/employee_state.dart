// features/employees/cubit/employee_state.dart
import '../../../models/employee.dart';

abstract class EmployeeState {}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoaded extends EmployeeState {
  final List<Employee> employees;

  EmployeeLoaded(this.employees);
}

class EmployeeError extends EmployeeState {
  final String message;

  EmployeeError(this.message);
}
