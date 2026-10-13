import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/visita.dart';

class MappaScreen extends StatefulWidget {
  const MappaScreen({super.key});

  @override
  State<MappaScreen> createState() => _MappaScreenState();
}

class _MappaScreenState extends State<MappaScreen> {
  late Box<VisitaDomiciliare> _visiteBox;

  @override
  void initState() {
    super.initState();
    _visiteBox = Hive.box<VisitaDomiciliare>('visiteBox');
  }

  Future<void> _apriGoogleMaps(String indirizzoDestinazione) async {
    final String origine = Uri.encodeComponent("Mereto di Capitolo, Santa Maria la Longa, UD");
    final String destinazione = Uri.encodeComponent(indirizzoDestinazione);
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$origine&destination=$destinazione&travelmode=driving',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _mostraDialogNuovaVisita() {
    final nomeCtrl = TextEditingController();
    final indirizzoCtrl = TextEditingController();
    final prestazioneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Programma Nuova Visita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome Paziente *')),
            TextField(controller: indirizzoCtrl, decoration: const InputDecoration(labelText: 'Indirizzo *')),
            TextField(controller: prestazioneCtrl, decoration: const InputDecoration(labelText: 'Prestazione')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              if (nomeCtrl.text.isEmpty || indirizzoCtrl.text.isEmpty) return;
              final nuovaVisita = VisitaDomiciliare(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                idPaziente: '0',
                nomePaziente: nomeCtrl.text,
                indirizzo: indirizzoCtrl.text,
                dataOra: DateTime.now(),
                prestazione: prestazioneCtrl.text.isNotEmpty ? prestazioneCtrl.text : 'Visita Domiciliare',
              );
              _visiteBox.put(nuovaVisita.id, nuovaVisita);
              Navigator.pop(ctx);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Giro Visite Domiciliari')),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _visiteBox.listenable(),
              builder: (context, Box<VisitaDomiciliare> box, _) {
                final visite = box.values.toList();
                if (visite.isEmpty) {
                  return const Center(child: Text('Nessuna visita programmata'));
                }
                return ListView.builder(
                  itemCount: visite.length,
                  itemBuilder: (ctx, index) {
                    final v = visite[index];
                    return ListTile(
                      title: Text('${timeFormat.format(v.dataOra)} - ${v.nomePaziente}'),
                      subtitle: Text('${v.prestazione}\n${v.indirizzo}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.navigation, color: Colors.teal),
                        onPressed: () => _apriGoogleMaps(v.indirizzo),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostraDialogNuovaVisita,
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}
