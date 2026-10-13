class VocePreventivo {
  String descrizione;
  double prezzoUnitario;
  int quantita;
  String categoria;

  VocePreventivo({
    required this.descrizione,
    required this.prezzoUnitario,
    this.quantita = 1,
    this.categoria = 'prestazione',
  });

  double get totale => prezzoUnitario * quantita;
}

class CalcolatorePreventivo {
  static const String puntoPartenza = "Mereto di Capitolo, Santa Maria la Longa, 33050 (UD)";
  static const double costoPerKm = 0.50;

  static const String nomePrestatore = "Dott. Bon Alessandro";
  static const String qualificaPrestatore = "Infermiere Libero Professionista";
  static const String pivaPrestatore = "IT03076370307";
  static const String opiPrestatore = "n. 6850 (Udine)";

  String nomePaziente = "";
  String codiceFiscalePaziente = "";
  String indirizzoPaziente = "";
  DateTime? dataOraAppuntamento;

  List<VocePreventivo> voci = [];
  double kmSoloAndata = 0.0;
  bool applicaRifiutiSpeciali = false;
  double costoRifiutiSpeciali = 0.0;

  double get rimborsoChilometrico => (kmSoloAndata * 2) * costoPerKm;

  double get imponibileServizi {
    double somma = voci.fold(0.0, (sum, item) => sum + item.totale);
    somma += rimborsoChilometrico;
    if (applicaRifiutiSpeciali) somma += costoRifiutiSpeciali;
    return somma;
  }

  double get rivalsaEnpapi => imponibileServizi * 0.04;
  double get totaleLordo => imponibileServizi + rivalsaEnpapi;
  double get marcaDaBollo => totaleLordo > 77.47 ? 2.00 : 0.0;
  double get totaleFinale => totaleLordo + marcaDaBollo;
}
