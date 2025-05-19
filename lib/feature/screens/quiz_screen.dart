import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_word_game/core/services/firestore_service.dart';
import 'package:flutter_word_game/core/services/tts_service.dart';
import 'package:flutter_word_game/feature/models/word.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:flutter_word_game/product/constants/texts/app_text.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class QuizScreen extends StatefulWidget {
  final List<Word> words;
  const QuizScreen({super.key, required this.words});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final FirestoreService firestoreService;
  final ttsService = TextToSpeechService();

  int currentIndex = 0;
  int correctCount = 0;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      firestoreService = FirestoreService(uid: uid);
    } else {
      throw Exception("Kullanıcı oturumu yok. UID bulunamadı.");
    }
  }

  void _submitAnswer(bool known) async {
    final word = widget.words[currentIndex];
    await firestoreService.updateWordProgress(
      wordId: word.id,
      isCorrect: known,
    );

    if (known) correctCount++;

    if (currentIndex + 1 < widget.words.length) {
      setState(() => currentIndex++);
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text(QuizTexts.quizOver),
            content: Text(
              "Doğru sayısı: $correctCount / ${widget.words.length}",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(AppTexts.backHome),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppTexts.quiz)),
        body: const Center(child: Text(QuizTexts.noWord)),
      );
    }

    final word = widget.words[currentIndex];
    final progress = (currentIndex + 1) / widget.words.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(QuizTexts.quizTime),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearPercentIndicator(
              lineHeight: 14.0,
              percent: progress,
              backgroundColor: ColorUtils.grey,
              progressColor: ColorUtils.lightBlue,
              center: Text(
                "%${(progress * 100).round()}",
                style: const TextStyle(fontSize: 10),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Image.network(word.imageUrl, height: 150)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${word.eng} - ${word.tur}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: ColorUtils.deepPurple),
                  onPressed: () => ttsService.speak(word.eng),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              AppTexts.example,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...word.samples.map(
              (sample) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• "),
                  Expanded(child: Text(sample)),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 18),
                    onPressed: () => ttsService.speak(sample),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _submitAnswer(true),
              icon: const Icon(
                Icons.check_circle,
                color: ColorUtils.loginWhite,
              ),
              label: const Text("Biliyorum"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorUtils.trueColor,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _submitAnswer(false),
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: const Text("Bilmiyorum"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorUtils.falseColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
