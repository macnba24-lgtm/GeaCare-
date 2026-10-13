import 'package:hive/hive.dart';

part 'paziente.g.dart';

@HiveType(typeId: 0)
class MisurazioneParametri extends HiveObject {
  @HiveField(0)
  final DateTime dataOra;

  @HiveField(1)
  final String? pressione;

  @HiveField(2)
  final int? frequenzaCardiaca;

  @HiveField(3)
  final int? spo2;

  @HiveField(4)
  final double? glicemia;

  @HiveField(5)
  final double? temperatura;

  MisurazioneParametri({
    required this.dataOra,
    this.pressione,
    this.frequenzaCardiaca,
    this.spo2,
    this.glicemia,
    this.temperatura,
  });
}

@HiveType(typeId: 1)
class NotaDiario extends HiveObject {
  @HiveField(0)
  final DateTime dataOra;

  @HiveField(1)
  final String testo;

  @HiveField(2)
  final String operatore;

  NotaDiario({
    required this.dataOra,
    required this.testo,
    required this.operatore,
  });
}

@HiveType(typeId: 2)
class InterventoMedicazione extends HiveObject {
  @HiveField(0)
  final DateTime dataOra;

  @HiveField(1)
  final String tipoMedicazione;

  @HiveField(2)
  final String noteTrattamento;

  InterventoMedicazione({
    required this.dataOra,
    required this.tipoMedicazione,
    required this.noteTrattamento,
  });
}

@HiveType(typeId: 3)
class Paziente extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String cognome;

  @HiveField(3)
  String codiceFiscale;

  @HiveField(4)
  String indirizzo;

  @HiveField(5)
  String telefono;

  @HiveField(6)
  List<NotaDiario> diario;

  @HiveField(7)
  List<MisurazioneParametri> parametri;

  @HiveField(8)
  List<InterventoMedicazione> medicazioni;

  Paziente({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.codiceFiscale,
    required this.indirizzo,
    required this.telefono,
    List<NotaDiario>? diario,
    List<MisurazioneParametri>? parametri,
    List<InterventoMedicazione>? medicazioni,
  })  : diario = diario ?? [],
        parametri = parametri ?? [],
        medicazioni = medicazioni ?? [];
}
