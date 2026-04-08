// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomAdapter extends TypeAdapter<Room> {
  @override
  final int typeId = 0;

  @override
  Room read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Room(
      id: fields[0] as int,
      number: fields[1] as String,
      viewType: fields[2] as String,
      capacity: fields[3] as String,
      pricePerNight: fields[4] as double,
      isAvailable: fields[5] as bool,
      imageUrl: fields[6] as String,
      amenities: (fields[7] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Room obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.number)
      ..writeByte(2)
      ..write(obj.viewType)
      ..writeByte(3)
      ..write(obj.capacity)
      ..writeByte(4)
      ..write(obj.pricePerNight)
      ..writeByte(5)
      ..write(obj.isAvailable)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.amenities);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
