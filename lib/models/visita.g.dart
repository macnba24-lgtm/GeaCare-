// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visita.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VisitaDomiciliareAdapter extends TypeAdapter<VisitaDomiciliare> {
  @override
  final int typeId = 4;

  @override
  VisitaDomiciliare read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VisitaDomiciliare(
      id: fields[0] as String,
      idPaziente: fields[1] as String,
      nomePaziente: fields[2] as String,
      indirizzo: fields[3] as String,
      dataOra: fields[4] as DateTime,
      prestazione: fields[5] as String,
      completata: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, VisitaDomiciliare obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idPaziente)
      ..writeByte(2)
      ..write(obj.nomePaziente)
      ..writeByte(3)
      ..write(obj.indirizzo)
      ..writeByte(4)
      ..write(obj.dataOra)
      ..writeByte(5)
      ..write(obj.prestazione)
      ..writeByte(6)
      ..write(obj.completata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitaDomiciliareAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
