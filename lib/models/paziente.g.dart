// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paziente.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MisurazioneParametriAdapter extends TypeAdapter<MisurazioneParametri> {
  @override
  final int typeId = 0;

  @override
  MisurazioneParametri read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MisurazioneParametri(
      dataOra: fields[0] as DateTime,
      pressione: fields[1] as String?,
      frequenzaCardiaca: fields[2] as int?,
      spo2: fields[3] as int?,
      glicemia: fields[4] as double?,
      temperatura: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, MisurazioneParametri obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.dataOra)
      ..writeByte(1)
      ..write(obj.pressione)
      ..writeByte(2)
      ..write(obj.frequenzaCardiaca)
      ..writeByte(3)
      ..write(obj.spo2)
      ..writeByte(4)
      ..write(obj.glicemia)
      ..writeByte(5)
      ..write(obj.temperatura);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MisurazioneParametriAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotaDiarioAdapter extends TypeAdapter<NotaDiario> {
  @override
  final int typeId = 1;

  @override
  NotaDiario read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotaDiario(
      dataOra: fields[0] as DateTime,
      testo: fields[1] as String,
      operatore: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NotaDiario obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dataOra)
      ..writeByte(1)
      ..write(obj.testo)
      ..writeByte(2)
      ..write(obj.operatore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotaDiarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InterventoMedicazioneAdapter extends TypeAdapter<InterventoMedicazione> {
  @override
  final int typeId = 2;

  @override
  InterventoMedicazione read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterventoMedicazione(
      dataOra: fields[0] as DateTime,
      tipoMedicazione: fields[1] as String,
      noteTrattamento: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InterventoMedicazione obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dataOra)
      ..writeByte(1)
      ..write(obj.tipoMedicazione)
      ..writeByte(2)
      ..write(obj.noteTrattamento);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterventoMedicazioneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PazienteAdapter extends TypeAdapter<Paziente> {
  @override
  final int typeId = 3;

  @override
  Paziente read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Paziente(
      id: fields[0] as String,
      nome: fields[1] as String,
      cognome: fields[2] as String,
      codiceFiscale: fields[3] as String,
      indirizzo: fields[4] as String,
      telefono: fields[5] as String,
      diario: (fields[6] as List?)?.cast<NotaDiario>(),
      parametri: (fields[7] as List?)?.cast<MisurazioneParametri>(),
      medicazioni: (fields[8] as List?)?.cast<InterventoMedicazione>(),
    );
  }

  @override
  void write(BinaryWriter writer, Paziente obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.cognome)
      ..writeByte(3)
      ..write(obj.codiceFiscale)
      ..writeByte(4)
      ..write(obj.indirizzo)
      ..writeByte(5)
      ..write(obj.telefono)
      ..writeByte(6)
      ..write(obj.diario)
      ..writeByte(7)
      ..write(obj.parametri)
      ..writeByte(8)
      ..write(obj.medicazioni);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PazienteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
