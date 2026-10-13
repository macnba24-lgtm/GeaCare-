import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/paziente.dart';

class PazientiScreen extends StatefulWidget {
  const PazientiScreen({super.key});

  @override
  State<PazientiScreen> createState() => _PazientiScreenState();
}

class _PazientiScreenState extends State<PazientiScreen> {
  String _queryRicerca = '';
  late Box<Paziente> _pazientiBox;

  @override
  void initState() {
    super.initState();
    _pazientiBox = Hive.box<Paziente>('pazientiBox');
  }

  List<Paziente> _getListaFiltrata(List<Paziente> tuttiIPazienti) {
    List<Paziente> lista = tuttiIPazienti.where((p) {
      final completo = '${p.cognome} ${p.nome}'.toLowerCase();
      return completo.contains(_queryRicerca.toLowerCase());
    }).toList();

    lista.sort((a, b) => '${a.cognome} ${a.nome}'.compareTo('${b.cognome} ${b.nome}'));
    return lista;
  }

  void _mostraDialogNuovoPaziente() {
    final nomeCtrl = TextEditingController();
    final cognomeCtrl = TextEditingController();
    final cfCtrl = TextEditingController();
    final indirizzoCtrl = TextEditingController();
    final telCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuovo Paziente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: cognomeCtrl, decoration: const InputDecoration(labelText: 'Cognome *')),
              TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome *')),
              TextField(controller: cfCtrl, decoration: const InputDecoration(labelText: 'Codice Fiscale')),
              TextField(controller: indirizzoCtrl, decoration: const InputDecoration(labelText: 'Indirizzo')),
              TextField(controller: telCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefono')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              if (nomeCtrl.text.isEmpty || cognomeCtrl.text.isEmpty) return;
              final nuovoPaziente = Paziente(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                nome: nomeCtrl.text,
                cognome: cognomeCtrl.text,
                codiceFiscale: cfCtrl.text,
                indirizzo: indirizzoCtrl.text,
                telefono: telCtrl.text,
              );
              
              _pazientiBox.put(nuovoPaziente.id, nuovoPaziente);
              Navigator.pop(ctx);
            },
            child: const Text('Salva'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anagrafica Pazienti'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca per Cognome o Nome...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (val) {
                setState(() {
                  _queryRicerca = val;
                });
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _pazientiBox.listenable(),
              builder: (context, Box<Paziente> box, _) {
                final tutti = box.values.toList();
                final lista = _getListaFiltrata(tutti);

                if (lista.isEmpty) {
                  return const Center(child: Text('Nessun paziente presente in archivio'));
                }

                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (ctx, i) {
                    final p = lista[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(p.cognome.isNotEmpty ? p.cognome.substring(0, 1).toUpperCase() : '?'),
                      ),
                      title: Text('${p.cognome} ${p.nome}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${p.indirizzo} • Tel: ${p.telefono}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SchedaPazienteDettaglioScreen(paziente: p),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostraDialogNuovoPaziente,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuovo Paziente'),
      ),
    );
  }
}

class SchedaPazienteDettaglioScreen extends StatefulWidget {
  final Paziente paziente;

  const SchedaPazienteDettaglioScreen({super.key, required this.paziente});

  @override
  State<SchedaPazienteDettaglioScreen> createState() => _SchedaPazienteDettaglioScreenState();
}

class _SchedaPazienteDettaglioScreenState extends State<SchedaPazienteDettaglioScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  void _aggiungiNotaDiario() {
    final testoCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuova Nota Diario'),
        content: TextField(
          controller: testoCtrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Inserisci la nota infermieristica...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              if (testoCtrl.text.isEmpty) return;
              setState(() {
                widget.paziente.diario.insert(
                  0,
                  NotaDiario(
                    dataOra: DateTime.now(),
                    testo: testoCtrl.text,
                    operatore: 'Dott. Bon Alessandro',
                  ),
                );
              });
              widget.paziente.save();
              Navigator.pop(ctx);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  void _aggiungiParametri() {
    final pressCtrl = TextEditingController();
    final fcCtrl = TextEditingController();
    final spo2Ctrl = TextEditingController();
    final glicCtrl = TextEditingController();
    final tempCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rileva Parametri Vitali'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: pressCtrl, decoration: const InputDecoration(labelText: 'Pressione (es. 120/80)')),
              TextField(controller: fcCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Freq. Cardiaca (bpm)')),
              TextField(controller: spo2Ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'SpO2 (%)')),
              TextField(controller: glicCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Glicemia (mg/dL)')),
              TextField(controller: tempCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Temperatura (°C)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.paziente.parametri.insert(
                  0,
                  MisurazioneParametri(
                    dataOra: DateTime.now(),
                    pressione: pressCtrl.text.isNotEmpty ? pressCtrl.text : null,
                    frequenzaCardiaca: int.tryParse(fcCtrl.text),
                    spo2: int.tryParse(spo2Ctrl.text),
                    glicemia: double.tryParse(glicCtrl.text),
                    temperatura: double.tryParse(tempCtrl.text),
                  ),
                );
              });
              widget.paziente.save();
              Navigator.pop(ctx);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  void _aggiungiMedicazione() {
    final tipoCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuova Medicazione'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: tipoCtrl, decoration: const InputDecoration(labelText: 'Tipo Medicazione / Lesione')),
            TextField(controller: noteCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Note sul Trattamento')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              if (tipoCtrl.text.isEmpty) return;
              setState(() {
                widget.paziente.medicazioni.insert(
                  0,
                  InterventoMedicazione(
                    dataOra: DateTime.now(),
                    tipoMedicazione: tipoCtrl.text,
                    noteTrattamento: noteCtrl.text,
                  ),
                );
              });
              widget.paziente.save();
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
    final p = widget.paziente;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${p.cognome} ${p.nome}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () {
                p.delete();
                Navigator.pop(context);
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'Diario'),
              Tab(icon: Icon(Icons.monitor_heart), text: 'PV'),
              Tab(icon: Icon(Icons.healing), text: 'Medicazioni'),
              Tab(icon: Icon(Icons.receipt), text: 'Preventivi'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: _aggiungiNotaDiario,
                child: const Icon(Icons.add_comment),
              ),
              body: p.diario.isEmpty
                  ? const Center(child: Text('Nessuna nota nel diario'))
                  : ListView.builder(
                      itemCount: p.diario.length,
                      itemBuilder: (ctx, i) {
                        final nota = p.diario[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(nota.testo),
                            subtitle: Text('${_dateFormat.format(nota.dataOra)} • ${nota.operatore}'),
                          ),
                        );
                      },
                    ),
            ),
            Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: _aggiungiParametri,
                child: const Icon(Icons.add),
              ),
              body: p.parametri.isEmpty
                  ? const Center(child: Text('Nessuna misurazione registrata'))
                  : ListView.builder(
                      itemCount: p.parametri.length,
                      itemBuilder: (ctx, i) {
                        final pv = p.parametri[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_dateFormat.format(pv.dataOra), style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 12,
                                  children: [
                                    if (pv.pressione != null) Text('PA: ${pv.pressione}'),
                                    if (pv.frequenzaCardiaca != null) Text('FC: ${pv.frequenzaCardiaca} bpm'),
                                    if (pv.spo2 != null) Text('SpO2: ${pv.spo2}%'),
                                    if (pv.glicemia != null) Text('Glicemia: ${pv.glicemia} mg/dL'),
                                    if (pv.temperatura != null) Text('Temp: ${pv.temperatura} °C'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: _aggiungiMedicazione,
                child: const Icon(Icons.add),
              ),
              body: p.medicazioni.isEmpty
                  ? const Center(child: Text('Nessuna medicazione registrata'))
                  : ListView.builder(
                      itemCount: p.medicazioni.length,
                      itemBuilder: (ctx, i) {
                        final m = p.medicazioni[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(m.tipoMedicazione, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${m.noteTrattamento}\n${_dateFormat.format(m.dataOra)}'),
                          ),
                        );
                      },
                    ),
            ),
            const Center(child: Text('Storico preventivi collegati')),
          ],
        ),
      ),
    );
  }
}
