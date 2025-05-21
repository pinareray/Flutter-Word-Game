import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_word_game/core/services/firestore_service.dart';
import 'package:flutter_word_game/core/services/pdf_service.dart';
import 'package:flutter_word_game/feature/models/word.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:flutter_word_game/product/constants/size_utils.dart';
import 'package:flutter_word_game/product/widgets/app_button.dart';

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
        padding: AppPaddings.mdAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Toplam Kelime: ${widget.total}"),
            Text("Toplam Doğru: ${widget.correct}"),
            Text("Toplam Yanlış: ${widget.incorrect}"),
            Text("Başarı Oranı: ${accuracy.toStringAsFixed(1)}%"),
            AppSizedBoxes.md,
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: widget.correct.toDouble(),
                      title: 'Doğru',
                      color: ColorUtils.trueColor,
                    ),
                    PieChartSectionData(
                      value: widget.incorrect.toDouble(),
                      title: 'Yanlış',
                      color: ColorUtils.falseColor,
                    ),
                  ],
                ),
              ),
            ),
            AppSizedBoxes.md,
            Center(
              child: AppButton(
                text: "PDF Olarak Dışa Aktar",
                icon: Icons.picture_as_pdf,
                onPressed: _exportToPdf,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
