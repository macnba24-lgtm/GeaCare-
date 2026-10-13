import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/listino.dart';
import '../services/pdf_service.dart';

class PreventiviScreen extends StatefulWidget {
  const PreventiviScreen({super.key});

  @override
  State<PreventiviScreen> createState() => _PreventiviScreenState();
}

class _PreventiviScreenState extends State<PreventiviScreen> {
  final _nomePazienteCtrl = TextEditingController();
  final List<VoceListino> _vociSelezionate = [];

  double get _totale => _vociSelezionate.fold(0.0, (sum, item) => sum + item.prezzo);

  void _selezionaVociDaListino() {
    final listinoBox = Hive.box<VoceListino>('listinoBox');
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ValueListenableBuilder(
          valueListenable: listinoBox.listenable(),
          builder: (context, Box<VoceListino> box, _) {
            final voci = box.values.toList();
            return ListView.builder(
              itemCount: voci.length,
              itemBuilder: (ctx, i) {
                final v = voci[i];
                final giaIncluso = _vociSelezionate.any((item) => item.id == v.id);
                return ListTile(
                  title: Text(v.nome),
                  subtitle: Text('€ ${v.prezzo.toStringAsFixed(2)}'),
                  trailing: Icon(
                    giaIncluso ? Icons.check_box : Icons.check_box_outline_blank,
                    color: giaIncluso ? Colors.teal : null,
                  ),
                  onTap: () {
                    setState(() {
                      if (giaIncluso) {
                        _vociSelezionate.removeWhere((item) => item.id == v.id);
                      } else {
                        _vociSelezionate.add(v);
                      }
                    });
                    Navigator.pop(ctx);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _generaPdf() async {
    if (_nomePazienteCtrl.text.isEmpty || _vociSelezionate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci il nome del paziente e almeno una voce.')),
      );
      return;
    }

    final bytes = await PdfService.generaPdfPreventivo(
      nomePaziente: _nomePazienteCtrl.text,
      vociSelezionate: _vociSelezionate,
      totale: _totale,
    );

    await PdfService.stampaOCondividiPdf(bytes, 'Preventivo_${_nomePazienteCtrl.text}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calcolatore Preventivi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nomePazienteCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome e Cognome Paziente',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _selezionaVociDaListino,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi Voce dal Listino'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _vociSelezionate.isEmpty
                  ? const Center(child: Text('Nessuna voce selezionata'))
                  : ListView.builder(
                      itemCount: _vociSelezionate.length,
                      itemBuilder: (ctx, i) {
                        final v = _vociSelezionate[i];
                        return ListTile(
                          title: Text(v.nome),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('€ ${v.prezzo.toStringAsFixed(2)}'),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _vociSelezionate.removeAt(i);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.teal.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTALE PREVENTIVO:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('€ ${_totale.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: _generaPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Genera e Stampa PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
