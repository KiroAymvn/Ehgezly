// models/room.dart
class Room {
  final int id;
  final String number;
  final String viewType; // Nile view, Suite, Regular
  final String capacity; // Single, Double, Triple
  final double pricePerNight;
  bool isAvailable;
  final String imageUrl;
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

  // Helper method to get capacity number
  int get capacityNumber {
    switch (capacity.toLowerCase()) {
      case 'single': return 1;
      case 'double': return 2;
      case 'triple': return 3;
      default: return 1;
    }
  }

  // Helper method to get capacity text
  String get capacityText {
    switch (capacity.toLowerCase()) {
      case 'single': return '1 Person';
      case 'double': return '2 People';
      case 'triple': return '3 People';
      default: return capacity;
    }
  }

  // Convert to JSON
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

  // Create from JSON
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