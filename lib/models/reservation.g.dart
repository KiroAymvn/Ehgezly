// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReservationAdapter extends TypeAdapter<Reservation> {
  @override
  final int typeId = 2;

  @override
  Reservation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reservation(
      id: fields[0] as int,
      guestId: fields[1] as int,
      roomId: fields[2] as int,
      checkIn: fields[3] as DateTime,
      checkOut: fields[4] as DateTime,
      status: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Reservation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.guestId)
      ..writeByte(2)
      ..write(obj.roomId)
      ..writeByte(3)
      ..write(obj.checkIn)
      ..writeByte(4)
      ..write(obj.checkOut)
      ..writeByte(5)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReservationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
