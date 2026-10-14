import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generaPreventivoPdf({
    required String numeroPreventivo,
    required String dataEmissione,
    required String nomePaziente,
    required String indirizzoPaziente,
    required List<Map<String, dynamic>> servizi,
    required double costoMateriali,
    required double costoRifiuti,
    required double rimborsoKm,
    required double subtotale,
    required double enpapi,
    required double bollo,
    required double totaleComplessivo,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            cross: pw.CrossAxisAlignment.start,
            children: [
              // INTESTAZIONE GEACARE
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    cross: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'GeaCare - Assistenza Domiciliare',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Infermieristica Domiciliare Basso Friuli'),
                    ],
                  ),
                  pw.Column(
                    cross: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('PREVENTIVO', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('N° $numeroPreventivo'),
                      pw.Text('Data: $dataEmissione'),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 12),

              // DATI DELLE PARTI
              pw.Row(
                cross: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      cross: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PRESTATORE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Dott. Alessandro Bon'),
                        pw.Text('Qualifica: Infermiere Libero Professionista'),
                        pw.Text('P. IVA: 03076370307'),
                        pw.Text('Iscrizione OPI: n. 6850 (Udine)'),
                        pw.Text('Sede: Mereto di Capitolo (UD)'),
                        pw.Text('PEC: bon.alessandro@cert.ordine-opi.it'),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      cross: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('CLIENTE / PAZIENTE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Nome/Cognome: $nomePaziente'),
                        pw.Text('Indirizzo: ${indirizzoPaziente.isEmpty ? "Domicilio Assistito" : indirizzoPaziente}'),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // TABELLA SERVIZI E COSTI
              pw.Text('OGGETTO E DETTAGLIO ECONOMICO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.SizedBox(height: 6),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Descrizione Servizio / Attività', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Prezzo (€)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  ...servizi.map(
                    (s) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(s['titolo'] ?? 'Prestazione Infermieristica'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text((s['prezzo'] as double).toStringAsFixed(2), textAlign: pw.TextAlign.right),
                        ),
                      ],
                    ),
                  ),
                  if (costoMateriali > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Spese per materiali e consumabili')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(costoMateriali.toStringAsFixed(2), textAlign: pw.TextAlign.right)),
                      ],
                    ),
                  if (costoRifiuti > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Smaltimento rifiuti sanitari pericolosi')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(costoRifiuti.toStringAsFixed(2), textAlign: pw.TextAlign.right)),
                      ],
                    ),
                  if (rimborsoKm > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Spese di viaggio / Rimborso chilometrico (A/R da Mereto di Capitolo)')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(rimborsoKm.toStringAsFixed(2), textAlign: pw.TextAlign.right)),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 12),

              // RIEPILOGO TOTALI
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 240,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotale Imponibile:'),
                            pw.Text('€ ${subtotale.toStringAsFixed(2)}'),
                          ],
                        ),
                        if (enpapi > 0)
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Rivalsa ENPAPI (4%):'),
                              pw.Text('€ ${enpapi.toStringAsFixed(2)}'),
                            ],
                          ),
                        if (bollo > 0)
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Imposta di Bollo:'),
                              pw.Text('€ ${bollo.toStringAsFixed(2)}'),
                            ],
                          ),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('TOTALE PREVENTIVO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('€ ${totaleComplessivo.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // ACCETTAZIONE DEL PREVENTIVO E FIRME
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Column(
                  cross: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ACCETTAZIONE DEL PREVENTIVO E CLAUSOLE VESSATORIE',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Il Cliente dichiara di aver preso visione e di accettare integralmente le tariffe e le condizioni riportate nel presente preventivo.',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.SizedBox(height: 24),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          cross: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Firma del Professionista Sanitario', style: const pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(height: 20),
                            pw.Text('________________________', style: const pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                        pw.Column(
                          cross: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Firma per Accettazione (Il Cliente)', style: const pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(height: 20),
                            pw.Text('________________________', style: const pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                        pw.Column(
                          cross: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Data Accettazione', style: const pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(height: 20),
                            pw.Text('____ / ____ / ________', style: const pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
