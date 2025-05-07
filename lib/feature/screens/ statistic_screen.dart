import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_word_game/core/services/firestore_service.dart';
import 'package:flutter_word_game/core/services/pdf_service.dart';
import 'package:flutter_word_game/feature/models/word.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  final int total;
  final int correct;
  final int incorrect;

  const StatisticsScreen({
    super.key,
    required this.total,
    required this.correct,
    required this.incorrect,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  double get accuracy {
    final totalAttempts = widget.correct + widget.incorrect;
    return totalAttempts == 0 ? 0 : (widget.correct / totalAttempts) * 100;
  }

  void _exportToPdf() async {
    final pdfService = PdfService();
    await pdfService.generateReportPdf(
      total: widget.total,
      correct: widget.correct,
      incorrect: widget.incorrect,
      accuracy: accuracy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📊 İstatistik Raporu")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Toplam Kelime: ${widget.total}"),
            Text("Toplam Doğru: ${widget.correct}"),
            Text("Toplam Yanlış: ${widget.incorrect}"),
            Text("Başarı Oranı: ${accuracy.toStringAsFixed(1)}%"),
            const SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: widget.correct.toDouble(),
                      title: 'Doğru',
                      color: Colors.green,
                    ),
                    PieChartSectionData(
                      value: widget.incorrect.toDouble(),
                      title: 'Yanlış',
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _exportToPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("PDF Olarak Dışa Aktar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 210, 188, 249),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
