import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_word_game/core/services/firestore_service.dart';
import 'package:flutter_word_game/feature/models/word.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class QuizScreen extends StatefulWidget {
  final List<Word> words;
  const QuizScreen({super.key, required this.words});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final FirestoreService firestoreService;

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
            title: const Text("Quiz Bitti!"),
            content: Text(
              "Doğru sayısı: $correctCount / ${widget.words.length}",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("Ana Sayfaya Dön"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: const Center(child: Text("Bugün tekrarlanacak kelime yok.")),
      );
    }

    final word = widget.words[currentIndex];
    final progress = (currentIndex + 1) / widget.words.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Zamanı"),
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
              backgroundColor: Colors.grey[300],
              progressColor: Colors.blueAccent,
              center: Text(
                "%${(progress * 100).round()}",
                style: const TextStyle(fontSize: 10),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Image.network(word.imageUrl, height: 150)),
            const SizedBox(height: 16),
            Text(
              "${word.eng} - ${word.tur}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Örnekler:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...word.samples.map((e) => Text("- $e")),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _submitAnswer(true),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text("Biliyordum"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _submitAnswer(false),
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: const Text("Bilmiyordum"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
