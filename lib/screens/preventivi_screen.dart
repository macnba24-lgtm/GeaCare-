import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/paziente.dart';
import '../models/listino.dart';

class PreventiviScreen extends StatefulWidget {
  const PreventiviScreen({super.key});

  @override
  State<PreventiviScreen> createState() => _PreventiviScreenState();
}

class _PreventiviScreenState extends State<PreventiviScreen> {
  final TextEditingController _pazienteController = TextEditingController();
  Paziente? _pazienteSelezionato;

  DateTime? _dataAppuntamento = DateTime.now();
  TimeOfDay? _oraAppuntamento = TimeOfDay.now();

  final List<VoceListino> _vociSelezionate = [];
  
  double _costoMateriali = 0.0;
  double _kmSoloAndata = 0.0;
  double _costoRifiuti = 0.0;
  bool _applicaEnpapi = true;

  // Calcoli
  double get _totalePrestazioni => _vociSelezionate.fold(0.0, (sum, item) => sum + item.prezzo);
  double get _rimborsoKm => (_kmSoloAndata * 2) * 0.50; // A/R da Mereto di Capitolo
  double get _imponibile => _totalePrestazioni + _costoMateriali + _costoRifiuti;
  double get _rivalsaEnpapi => _applicaEnpapi ? (_imponibile * 0.04) : 0.0;
  double get _subtotale => _imponibile + _rimborsoKm + _rivalsaEnpapi;
  double get _bollo => (_subtotale > 77.47) ? 2.0 : 0.0;
  double get _totalePreventivo => _subtotale + _bollo;

  @override
  Widget build(BuildContext context) {
    final pazientiBox = Hive.box<Paziente>('pazientiBox');
    final listaPazienti = pazientiBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calcolatore Preventivi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. AUTOCOMPLETE PAZIENTE
            Autocomplete<Paziente>(
              displayStringForOption: (Paziente p) => '${p.nome} ${p.cognome}',
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Paziente>.empty();
                }
                return listaPazienti.where((Paziente p) {
                  final nomeCompleto = '${p.nome} ${p.cognome}'.toLowerCase();
                  return nomeCompleto.contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (Paziente p) {
                setState(() {
                  _pazienteSelezionato = p;
                  _pazienteController.text = '${p.nome} ${p.cognome}';
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Cerca o inserisci Paziente',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_search),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // 2. DATA E ORA APPUNTAMENTO (Non incluse nel PDF)
            Card(
              elevation: 0,
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_month, color: Colors.teal),
                        label: Text(
                          _dataAppuntamento == null
                              ? 'Data Appuntamento'
                              : '${_dataAppuntamento!.day}/${_dataAppuntamento!.month}/${_dataAppuntamento!.year}',
                          style: const TextStyle(color: Colors.teal),
                        ),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (d != null) setState(() => _dataAppuntamento = d);
                        },
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.access_time, color: Colors.teal),
                        label: Text(
                          _oraAppuntamento == null
                              ? 'Ora'
                              : _oraAppuntamento!.format(context),
                          style: const TextStyle(color: Colors.teal),
                        ),
                        onPressed: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (t != null) setState(() => _oraAppuntamento = t);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. SEZIONE COSTI DEDICATI
            const Text('Dettagli e Costi Extra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            // Materiali
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Materiali (€)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              onChanged: (val) => setState(() => _costoMateriali = double.tryParse(val) ?? 0.0),
            ),
            const SizedBox(height: 10),

            // Rimborso Km A/R da Mereto
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Distanza solo andata (km)',
                helperText: 'Partenza: Mereto di Capitolo | Calcolo A/R 0,50€/km = ${_rimborsoKm.toStringAsFixed(2)} €',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.directions_car),
              ),
              onChanged: (val) => setState(() => _kmSoloAndata = double.tryParse(val) ?? 0.0),
            ),
            const SizedBox(height: 10),

            // Rifiuti Speciali
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Smaltimento Rifiuti Speciali (€)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.delete_outline),
              ),
              onChanged: (val) => setState(() => _costoRifiuti = double.tryParse(val) ?? 0.0),
            ),
            const SizedBox(height: 10),

            // Rivalsa ENPAPI 4%
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Rivalsa ENPAPI (4%)'),
              subtitle: Text('Importo: ${_rivalsaEnpapi.toStringAsFixed(2)} €'),
              value: _applicaEnpapi,
              onChanged: (val) => setState(() => _applicaEnpapi = val),
            ),

            if (_bollo > 0)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.sticky_note_2, color: Colors.teal),
                title: const Text('Marca da Bollo'),
                subtitle: const Text('Applicata automaticamente (superati 77,47 €)'),
                trailing: Text('${_bollo.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),

            const SizedBox(height: 20),

            // TOTALE PREVENTIVO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTALE PREVENTIVO:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    '€ ${_totalePreventivo.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.teal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  // Azione Stampa/Generazione PDF
                },
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text('Genera e Stampa PDF', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
