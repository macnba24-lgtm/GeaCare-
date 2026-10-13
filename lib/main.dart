import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/paziente.dart';
import 'models/visita.dart';
import 'models/listino.dart';
import 'services/listino_initial_data.dart';
import 'screens/preventivi_screen.dart';
import 'screens/pazienti_screen.dart';
import 'screens/mappa_screen.dart';
import 'screens/listino_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(MisurazioneParametriAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(NotaDiarioAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(InterventoMedicazioneAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(PazienteAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(VisitaDomiciliareAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(VoceListinoAdapter());

    await Hive.openBox<Paziente>('pazientiBox');
    await Hive.openBox<VisitaDomiciliare>('visiteBox');
    
    final listinoBox = await Hive.openBox<VoceListino>('listinoBox');
    if (listinoBox.isEmpty) {
      for (var voce in tariffarioIniziale) {
        await listinoBox.put(voce.id, voce);
      }
    }
  } catch (e) {
    debugPrint('Errore caricamento Hive: $e');
  }

  runApp(const GeaCareApp());
}

class GeaCareApp extends StatelessWidget {
  const GeaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeaCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PreventiviScreen(),
    const PazientiScreen(),
    const MappaScreen(),
    const ListinoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Preventivi'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pazienti'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Giro Visite'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Listino'),
        ],
      ),
    );
  }
}
