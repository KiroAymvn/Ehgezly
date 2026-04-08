// models/guest.dart
//
// Guest entity with Hive TypeAdapter support.
// TypeId = 1 — must be unique across all Hive models.

import 'package:hive/hive.dart';

part 'guest.g.dart';

@HiveType(typeId: 1)
class Guest extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final DateTime? birthday;

  Guest({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.birthday,
  });

  // Converts this guest to a JSON-compatible map
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'birthday': birthday?.toIso8601String(),
  };

  // Creates a Guest from a JSON map
  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'] ?? '',
      birthday: json['birthday'] != null
          ? DateTime.tryParse(json['birthday'])
          : null,
    );
  }

  // Returns the birthday formatted as dd/mm/yyyy or null if not set
  String? get formattedBirthday {
    if (birthday == null) return null;
    return '${birthday!.day}/${birthday!.month}/${birthday!.year}';
  }

  // Calculates the guest's current age from their birthday
  int? get age {
    if (birthday == null) return null;
    final now = DateTime.now();
    int years = now.year - birthday!.year;
    if (now.month < birthday!.month ||
        (now.month == birthday!.month && now.day < birthday!.day)) {
      years--;
    }
    return years;
  }
}