// models/room.dart
//
// Room entity with Hive TypeAdapter support.
// TypeId = 0 — must be unique across all Hive models.

import 'package:hive/hive.dart';

part 'room.g.dart';

@HiveType(typeId: 0)
class Room extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String number;

  @HiveField(2)
  final String viewType; // Nile View, Suite, Regular

  @HiveField(3)
  final String capacity; // Single, Double, Triple

  @HiveField(4)
  final double pricePerNight;

  @HiveField(5)
  bool isAvailable;

  @HiveField(6)
  final String imageUrl;

  @HiveField(7)
  final List<String> amenities;

  Room({
    required this.id,
    required this.number,
    required this.viewType,
    required this.capacity,
    required this.pricePerNight,
    this.isAvailable = true,
    this.imageUrl = 'assets/room.jpg',
    this.amenities = const [],
  });

  // Returns how many people this room fits as a number
  int get capacityNumber {
    switch (capacity.toLowerCase()) {
      case 'single': return 1;
      case 'double': return 2;
      case 'triple': return 3;
      default:       return 1;
    }
  }

  // Returns a human-readable capacity label
  String get capacityText {
    switch (capacity.toLowerCase()) {
      case 'single': return '1 Person';
      case 'double': return '2 People';
      case 'triple': return '3 People';
      default:       return capacity;
    }
  }

  // Converts this room to a JSON-compatible map
  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'viewType': viewType,
    'capacity': capacity,
    'pricePerNight': pricePerNight,
    'isAvailable': isAvailable,
    'imageUrl': imageUrl,
    'amenities': amenities,
  };

  // Creates a Room from a JSON map
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      number: json['number'],
      viewType: json['viewType'] ?? 'Regular',
      capacity: json['capacity'] ?? 'Single',
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      imageUrl: json['imageUrl'] ?? 'assets/room.jpg',
      amenities: List<String>.from(json['amenities'] ?? []),
    );
  }
}