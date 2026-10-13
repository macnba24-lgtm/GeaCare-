import 'package:hive/hive.dart';

part 'listino.g.dart';

@HiveType(typeId: 5)
class VoceListino extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  double prezzo;

  @HiveField(3)
  String categoria;

  VoceListino({
    required this.id,
    required this.nome,
    required this.prezzo,
    required this.categoria,
  });
}
