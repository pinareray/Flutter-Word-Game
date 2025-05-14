import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';
import '../models/word.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  String _message = 'Öğrenilen kelime bulunamadı';
  late FirestoreService firestoreService;
  List<List<String>> grid = List.generate(
    5,
    (_) => List.generate(5, (_) => ''),
  );
  List<String> learnedWords = [];
  String targetWord = '';
  String message = '';
  final guessController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      firestoreService = FirestoreService(uid: uid);
      _initPuzzle();
    }
  }

  Future<void> _initPuzzle() async {
    final allWords = await firestoreService.getAllWords();
    learnedWords =
        allWords
            .where(
              (w) =>
                  w.successCount >= 6 && w.eng.length >= 2 && w.eng.length <= 5,
            )
            .map((w) => w.eng.toUpperCase())
            .toList();

    if (learnedWords.isEmpty) {
      setState(() {
        message = _message;
        isLoading = false;
      });
      return;
    }

    targetWord = (learnedWords.toList()..shuffle()).first;
    _fillGridWithTarget(targetWord);
    setState(() => isLoading = false);
  }

  void _fillGridWithTarget(String word) {
    final rand = Random();
    final horizontal = rand.nextBool();
    final row = rand.nextInt(5);
    final col = rand.nextInt(5 - word.length + 1);

    // Puzzle rastgele harflerle dolduruluyor
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        grid[i][j] = String.fromCharCode(65 + rand.nextInt(26));
      }
    }

    // Hedef kelimeyi yerleştir
    if (horizontal) {
      for (int i = 0; i < word.length; i++) {
        grid[row][col + i] = word[i];
      }
    } else {
      for (int i = 0; i < word.length; i++) {
        grid[col + i][row] = word[i];
      }
    }
  }

  void _checkGuess() async {
    final guess = guessController.text.trim().toUpperCase();

    if (guess == targetWord) {
      message = '🎉 Doğru tahmin!';
    } else {
      message = '❌ Yanlış. Doğru kelime: $targetWord';
    }

    guessController.clear();

    await Future.delayed(const Duration(seconds: 1)); // kısa bir bekleme

    // Yeni kelime seçme ve yeni grid oluşturma
    setState(() {
      targetWord = (learnedWords.toList()..shuffle()).first;
      _fillGridWithTarget(targetWord);
    });
  }

  @override
  void dispose() {
    guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🍀 Kelime Bulmacası')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    _buildGrid(),
                    const SizedBox(height: 20),
                    TextField(
                      controller: guessController,
                      decoration: const InputDecoration(
                        labelText: "Tahmininizi yazın",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _checkGuess,
                      child: const Text("Tahmin Et"),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildGrid() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          grid
              .map(
                (row) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      row
                          .map(
                            (letter) => Container(
                              margin: const EdgeInsets.all(4),
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                color: Colors.deepPurple.shade50,
                              ),
                              child: Text(
                                letter,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              )
              .toList(),
    );
  }
}
