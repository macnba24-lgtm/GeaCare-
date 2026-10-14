import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/paziente.dart';
import '../models/listino.dart';
import '../services/pdf_service.dart';

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

  final List<Map<String, dynamic>> _vociPreventivo = [];

  double _costoMateriali = 0.0;
  double _kmSoloAndata = 0.0;
  double _costoRifiuti = 0.0;
  bool _applicaEnpapi = true;

  double get _totaleServizi => _vociPreventivo.fold(0.0, (sum, item) => sum + (item['prezzo'] as double));
  double get _kmTotaliAR => _kmSoloAndata * 2;
  double get _rimborsoKm => _kmTotaliAR * 0.50;
  double get _imponibile => _totaleServizi + _costoMateriali + _costoRifiuti;
  double get _rivalsaEnpapi => _applicaEnpapi ? (_imponibile * 0.04) : 0.0;
  double get _subtotale => _imponibile + _rimborsoKm + _rivalsaEnpapi;
  double get _bollo => (_subtotale > 77.47) ? 2.0 : 0.0;
  double get _totalePreventivo => _subtotale + _bollo;

  @override
  Widget build(BuildContext context) {
    final pazientiBox = Hive.isBoxOpen('pazientiBox') ? Hive.box<Paziente>('pazientiBox') : null;
    final listinoBox = Hive.isBoxOpen('listinoBox') ? Hive.box<VoceListino>('listinoBox') : null;

    final listaPazienti = pazientiBox?.values.toList() ?? [];
    final listaListino = listinoBox?.values.toList() ?? [];

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
            Autocomplete<Paziente>(
              displayStringForOption: (Paziente p) => '${p.nome} ${p.cognome}',
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<Paziente>.empty();
                return listaPazienti.where((Paziente p) {
                  return '${p.nome} ${p.cognome}'.toLowerCase().contains(textEditingValue.text.toLowerCase());
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
            Card(
              elevation: 0,
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_month, color: Colors.teal),
                        label: Text(
                          _dataAppuntamento == null ? 'Data Appuntamento' : DateFormat('dd/MM/yyyy').format(_dataAppuntamento!),
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
                          _oraAppuntamento == null ? 'Ora' : _oraAppuntamento!.format(context),
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
            const Text('Aggiungi Servizi dal Listino', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Autocomplete<VoceListino>(
              displayStringForOption: (VoceListino v) => '${v.titolo} (€ ${v.prezzo.toStringAsFixed(2)})',
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<VoceListino>.empty();
                return listaListino.where((VoceListino v) {
                  return v.titolo.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (VoceListino v) {
                setState(() {
                  _vociPreventivo.add({
                    'titolo': v.titolo,
                    'prezzo': v.prezzo,
                  });
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Cerca Servizio / Prestazione',
                    hintText: 'Inizia a digitare...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            if (_vociPreventivo.isNotEmpty) ...[
              const Text('Voci selezionate:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _vociPreventivo.length,
                itemBuilder: (context, index) {
                  final voce = _vociPreventivo[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(voce['titolo']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('€ ${(voce['prezzo'] as double).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => _vociPreventivo.removeAt(index)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            const Text('Costi Aggiuntivi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Materiali e Consumabili (€)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              onChanged: (val) => setState(() => _costoMateriali = double.tryParse(val) ?? 0.0),
            ),
            const SizedBox(height: 10),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Distanza solo andata (km)',
                helperText: 'Partenza: Mereto | Totale A/R: ${_kmTotaliAR.toStringAsFixed(1)} km = ${_rimborsoKm.toStringAsFixed(2)} €',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.directions_car),
              ),
              onChanged: (val) => setState(() => _kmSoloAndata = double.tryParse(val) ?? 0.0),
            ),
            const SizedBox(height: 10),
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
                subtitle: const Text('Applicata automaticamente (> 77,47 €)'),
                trailing: Text('${_bollo.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 16),
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
                  Text('€ ${_totalePreventivo.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.teal)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () async {
                  final numero = '2026/${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                  final dataStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
                  await PdfService.generaPreventivoPdf(
                    numeroPreventivo: numero,
                    dataEmissione: dataStr,
                    nomePaziente: _pazienteController.text.isEmpty
                        ? (_pazienteSelezionato != null ? '${_pazienteSelezionato!.nome} ${_pazienteSelezionato!.cognome}' : 'Cliente Domiciliare')
                        : _pazienteController.text,
                    indirizzoPaziente: _pazienteSelezionato?.indirizzo ?? '',
                    servizi: _vociPreventivo,
                    costoMateriali: _costoMateriali,
                    costoRifiuti: _costoRifiuti,
                    rimborsoKm: _rimborsoKm,
                    subtotale: _imponibile,
                    enpapi: _rivalsaEnpapi,
                    bollo: _bollo,
                    totaleComplessivo: _totalePreventivo,
                  );
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
