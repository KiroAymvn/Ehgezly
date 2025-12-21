// models/employee.dart
import 'dart:convert';

class Employee {
  final int id;
  String firstName;
  String secondName;
  String phone;
  String department;
  DateTime? hireDate;

  Employee({
    required this.id,
    required this.firstName,
    required this.secondName,
    required this.phone,
    required this.department,
    this.hireDate,
  });

  String get fullName => '$firstName $secondName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'secondName': secondName,
      'phone': phone,
      'department': department,
      'hireDate': hireDate?.toIso8601String(),
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      firstName: json['firstName'],
      secondName: json['secondName'],
      phone: json['phone'],
      department: json['department'],
      hireDate: json['hireDate'] != null ? DateTime.parse(json['hireDate']) : null,
    );
  }
}