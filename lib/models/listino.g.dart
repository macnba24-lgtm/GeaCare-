// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listino.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoceListinoAdapter extends TypeAdapter<VoceListino> {
  @override
  final int typeId = 5;

  @override
  VoceListino read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VoceListino(
      id: fields[0] as String,
      nome: fields[1] as String,
      prezzo: fields[2] as double,
      categoria: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VoceListino obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.prezzo)
      ..writeByte(3)
      ..write(obj.categoria);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoceListinoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
