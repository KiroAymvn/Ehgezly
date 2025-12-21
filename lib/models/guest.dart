// models/guest.dart
class Guest {
  final int id;
  final String name;
  final String phone;
  final String email;
  final DateTime? birthday; // Add nullable birthday field

  Guest({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.birthday, // Add to constructor
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'birthday': birthday?.toIso8601String(), // Handle null
  };

  // Create from JSON
  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'] ?? '',
      birthday: json['birthday'] != null
          ? DateTime.tryParse(json['birthday']) // Use tryParse for safety
          : null,
    );
  }

  // Helper method to format birthday
  String? get formattedBirthday {
    if (birthday == null) return null;
    return '${birthday!.day}/${birthday!.month}/${birthday!.year}';
  }

  // Helper method to calculate age
  int? get age {
    if (birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month ||
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }
}