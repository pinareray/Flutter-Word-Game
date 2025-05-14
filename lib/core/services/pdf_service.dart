import 'dart:io';
import 'package:flutter_word_game/product/constants/size_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> generateReportPdf({
    required int total,
    required int correct,
    required int incorrect,
    required double accuracy,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Kelime Ezberleme Başarı Raporu", style: pw.TextStyle(fontSize: Numbers.medium)),
            pw.SizedBox(height: 20),
            pw.Text("Toplam kelime sayısı: $total"),
            pw.Text("Doğru cevap sayısı: $correct"),
            pw.Text("Yanlış cevap sayısı: $incorrect"),
            pw.Text("Başarı oranı: %${accuracy.toStringAsFixed(1)}"),
            pw.SizedBox(height: 20),
            pw.Text("Hazırlanma tarihi: ${DateTime.now()}"),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
