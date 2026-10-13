import 'package:hive/hive.dart';

part 'visita.g.dart';

@HiveType(typeId: 4)
class VisitaDomiciliare extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String idPaziente;

  @HiveField(2)
  final String nomePaziente;

  @HiveField(3)
  final String indirizzo;

  @HiveField(4)
  final DateTime dataOra;

  @HiveField(5)
  final String prestazione;

  @HiveField(6)
  bool completata;

  VisitaDomiciliare({
    required this.id,
    required this.idPaziente,
    required this.nomePaziente,
    required this.indirizzo,
    required this.dataOra,
    required this.prestazione,
    this.completata = false,
  });
}
