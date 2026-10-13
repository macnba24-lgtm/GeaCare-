import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/listino.dart';

class ListinoScreen extends StatefulWidget {
  const ListinoScreen({super.key});

  @override
  State<ListinoScreen> createState() => _ListinoScreenState();
}

class _ListinoScreenState extends State<ListinoScreen> {
  late Box<VoceListino> _listinoBox;
  String _queryRicerca = '';

  @override
  void initState() {
    super.initState();
    _listinoBox = Hive.box<VoceListino>('listinoBox');
  }

  void _mostraDialogVoce({VoceListino? voceEsistente}) {
    final nomeCtrl = TextEditingController(text: voceEsistente?.nome ?? '');
    final prezzoCtrl = TextEditingController(
        text: voceEsistente != null ? voceEsistente.prezzo.toStringAsFixed(2) : '');
    String categoria = voceEsistente?.categoria ?? 'servizio';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(voceEsistente == null ? 'Nuova Voce Listino' : 'Modifica Voce'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeCtrl,
                decoration: const InputDecoration(labelText: 'Descrizione Servizio / Materiale *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: prezzoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Prezzo (€) *', prefixText: '€ '),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: categoria,
                items: const [
                  DropdownMenuItem(value: 'servizio', child: Text('Prestazione / Servizio')),
                  DropdownMenuItem(value: 'materiale', child: Text('Materiale')),
                ],
                onChanged: (val) {
                  if (val != null) categoria = val;
                },
                decoration: const InputDecoration(labelText: 'Tipologia'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              final double p = double.tryParse(prezzoCtrl.text.replaceAll(',', '.')) ?? 0.0;
              if (nomeCtrl.text.isEmpty || p <= 0) return;

              if (voceEsistente == null) {
                final nuova = VoceListino(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  nome: nomeCtrl.text,
                  prezzo: p,
                  categoria: categoria,
                );
                _listinoBox.put(nuova.id, nuova);
              } else {
                voceEsistente.nome = nomeCtrl.text;
                voceEsistente.prezzo = p;
                voceEsistente.categoria = categoria;
                voceEsistente.save();
              }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listino Prezzi & Materiali'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca voce nel tariffario...',
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
              valueListenable: _listinoBox.listenable(),
              builder: (context, Box<VoceListino> box, _) {
                final lista = box.values.where((v) {
                  return v.nome.toLowerCase().contains(_queryRicerca.toLowerCase());
                }).toList();

                if (lista.isEmpty) {
                  return const Center(child: Text('Nessuna voce trovata'));
                }

                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (ctx, i) {
                    final item = lista[i];
                    return ListTile(
                      title: Text(item.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Categoria: ${item.categoria.toUpperCase()}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '€ ${item.prezzo.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                            onPressed: () => _mostraDialogVoce(voceEsistente: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => item.delete(),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostraDialogVoce(),
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi Voce'),
      ),
    );
  }
}
