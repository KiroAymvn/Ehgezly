// models/employee.dart
//
// Employee entity with Hive TypeAdapter support.
// TypeId = 3 — must be unique across all Hive models.

import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 3)
class Employee extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  String firstName;

  @HiveField(2)
  String secondName;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String department;

  @HiveField(5)
  DateTime? hireDate;

  Employee({
    required this.id,
    required this.firstName,
    required this.secondName,
    required this.phone,
    required this.department,
    this.hireDate,
  });

  // Returns the full name of the employee
  String get fullName => '$firstName $secondName';

  // Converts this employee to a JSON-compatible map
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

  // Creates an Employee from a JSON map
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