// features/employees/cubit/employee_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/employee.dart';
import '../../../services/hotel_service.dart';
import 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final HotelService _service = HotelService();

  EmployeeCubit() : super(EmployeeInitial());

  List<Employee> get allEmployees => state is EmployeeLoaded ? (state as EmployeeLoaded).employees : _service.employees;

  void loadEmployees() {
    emit(EmployeeLoaded(_service.employees));
  }

  Future<void> addEmployee({
    required String firstName,
    required String secondName,
    required String phone,
    required String department,
  }) async {
    try {
      await _service.addEmployee(
        firstName: firstName,
        secondName: secondName,
        phone: phone,
        department: department,
      );
      loadEmployees();
    } catch (e) {
      emit(EmployeeError(e.toString()));
      loadEmployees();
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
      await _service.updateEmployee(
        employeeId: employeeId,
        firstName: firstName,
        secondName: secondName,
        phone: phone,
        department: department,
      );
      loadEmployees();
    } catch (e) {
      emit(EmployeeError(e.toString()));
      loadEmployees();
    }
  }

  Future<void> deleteEmployee(int employeeId) async {
    try {
      await _service.deleteEmployee(employeeId);
      loadEmployees();
    } catch (e) {
      emit(EmployeeError(e.toString()));
      loadEmployees();
    }
  }
}

