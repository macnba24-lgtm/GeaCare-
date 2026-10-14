import 'package:flutter/material.dart';

// Configurazione Dati Professionista
const String kInfiereNome = "Alessandro Bon";
const String kInfierePiva = "IT03076370307";
const String kInfiereAlbo = "OPI 6850";

class PreventiviScreen extends StatefulWidget {
  const PreventiviScreen({super.key});

  @override
  State<PreventiviScreen> createState() => _PreventiviScreenState();
}

class _PreventiviScreenState extends State<PreventiviScreen> {
  // Dati Paziente
  final TextEditingController _nomePazienteController = TextEditingController();
  final TextEditingController _cfPazienteController = TextEditingController();
  final TextEditingController _indirizzoPazienteController = TextEditingController();
  DateTime? _dataAppuntamento;
  TimeOfDay? _oraAppuntamento;

  // Economia / Servizi
  final TextEditingController _prestazioneController = TextEditingController();
  final TextEditingController _prezzoPrestazioneController = TextEditingController();

  final TextEditingController _materialiController = TextEditingController();
  final TextEditingController _prezzoMaterialiController = TextEditingController();

  final TextEditingController _costoRifiutiController = TextEditingController();
  final TextEditingController _kmTrattaController = TextEditingController();

  bool _applicaEnpapi = true;
  bool _applicaBollo = false;

  // Calcoli
  double get _costoKm {
    final km = double.tryParse(_kmTrattaController.text) ?? 0.0;
    return km * 2 * 0.50; // A/R da Mereto di Capitolo (Santa Maria la Longa)
  }

  double get _subtotale {
    final p = double.tryParse(_prezzoPrestazioneController.text) ?? 0.0;
    final m = double.tryParse(_prezzoMaterialiController.text) ?? 0.0;
    final r = double.tryParse(_costoRifiutiController.text) ?? 0.0;
    return p + m + r + _costoKm;
  }

  double get _quotaEnpapi => _applicaEnpapi ? (_subtotale * 0.04) : 0.0;
  double get _quotaBollo => _applicaBollo ? 2.00 : 0.0;
  double get _totaleFinale => _subtotale + _quotaEnpapi + _quotaBollo;

  Future<void> _selezionaData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (d != null) setState(() => _dataAppuntamento = d);
  }

  Future<void> _selezionaOra() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => _oraAppuntamento = t);
  }

  void _generaPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'PDF in generazione per ${_nomePazienteController.text.isEmpty ? "Paziente" : _nomePazienteController.text} | Emesso da: $kInfiereNome (P.IVA $kInfierePiva, $kInfiereAlbo) | Totale: ${_totaleFinale.toStringAsFixed(2)} €',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo Preventivo GeaCare'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // DATI PROFESSIONISTA
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '$kInfiereNome - Infermiere Libero Professionista',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('P.IVA: $kInfierePiva | Albo: $kInfiereAlbo'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // SEZIONE PAZIENTE
            const Text('Dati Paziente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nomePazienteController,
              decoration: const InputDecoration(labelText: 'Nome e Cognome Paziente', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cfPazienteController,
              decoration: const InputDecoration(labelText: 'Codice Fiscale', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _indirizzoPazienteController,
              decoration: const InputDecoration(labelText: 'Indirizzo Paziente', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selezionaData,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_dataAppuntamento == null
                        ? 'Data Appuntamento'
                        : '${_dataAppuntamento!.day}/${_dataAppuntamento!.month}/${_dataAppuntamento!.year}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selezionaOra,
                    icon: const Icon(Icons.access_time),
                    label: Text(_oraAppuntamento == null
                        ? 'Ora Appuntamento'
                        : _oraAppuntamento!.format(context)),
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // SEZIONE PRESTAZIONE & MATERIALI
            const Text('Prestazione & Dettagli Economici', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                                    }
                                        return listaPrestazioni.where((String option) {
                                              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                                                  });
                                                    },
                                                      onSelected: (String selection) {
                                                          _prestazioneController.text = selection;
                                                            },
                                                              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                                                  return TextField(
                                                                        controller: controller,
                                                                              focusNode: focusNode,
                                                                                    decoration: const InputDecoration(
                                                                                            labelText: 'Prestazione',
                                                                                                    border: OutlineInputBorder(),
                                                                                                          ),
                                                                                                              );
                                                                                                                },
                                                                                                                )
                  )
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _prezzoPrestazioneController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Prezzo (€)', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _materialiController,
                    decoration: const InputDecoration(labelText: 'Materiali Impiegati', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _prezzoMaterialiController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Costo (€)', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _costoRifiutiController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Smaltimento Rifiuti Speciali (€)', border: OutlineInputBorder()),
            ),

            const SizedBox(height: 12),
            // RIMBORSO CHILOMETRICO
            TextField(
              controller: _kmTrattaController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Chilometri tratta singola (da Mereto di Capitolo)',
                helperText: 'Calcolo A/R x 0,50 €/km: ${_costoKm.toStringAsFixed(2)} €',
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            // RIVALSA & BOLLO
            SwitchListTile(
              title: const Text('Rivalsa ENPAPI (4%)'),
              subtitle: Text('Quota: ${_quotaEnpapi.toStringAsFixed(2)} €'),
              value: _applicaEnpapi,
              onChanged: (v) => setState(() => _applicaEnpapi = v),
            ),
            SwitchListTile(
              title: const Text('Marca da Bollo (2,00 €)'),
              value: _applicaBollo,
              onChanged: (v) => setState(() => _applicaBollo = v),
            ),

            const Divider(height: 32),

            // TOTALE & GENERAZIONE PDF
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTALE PREVENTIVO:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${_totaleFinale.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _generaPdf,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('GENERA PDF PREVENTIVO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
