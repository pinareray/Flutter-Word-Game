import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/core/services/tts_service.dart';
import '../../core/services/firestore_service.dart';
import '../models/word.dart';
import 'quiz_screen.dart';

class ReviewTodayScreen extends StatefulWidget {
  const ReviewTodayScreen({super.key});

  @override
  State<ReviewTodayScreen> createState() => _ReviewTodayScreenState();
}

class _ReviewTodayScreenState extends State<ReviewTodayScreen> {
  late FirestoreService firestoreService;
  late Future<List<Word>> todayWords;
  final ttsService = TextToSpeechService(); // 🔈 TTS örneği

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      todayWords = Future.value([]);
    } else {
      firestoreService = FirestoreService(uid: uid);
      todayWords = firestoreService.getTodayReviewWords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bugünkü Tekrar Edilecek Kelimeler")),
      body: FutureBuilder<List<Word>>(
        future: todayWords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("❌ Hata: ${snapshot.error}"));
          }

          final words = snapshot.data ?? [];

          if (words.isEmpty) {
            return const Center(
              child: Text(
                "✅ Bugün tekrar edilmesi gereken kelime bulunamadı.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final word = words[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 4,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            word.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          word.eng,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Türkçesi: ${word.tur}"),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.volume_up,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () => ttsService.speak(word.eng),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(words: words),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Quiz'e Başla"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
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
          );
        },
      ),
    );
  }
}
