import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/core/services/tts_service.dart';
import '../models/word.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({super.key});

  Stream<List<Word>> getWordsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('words')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Word.fromMap(doc.data())).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final ttsService = TextToSpeechService(); // 🔈 TTS servisi

    return Scaffold(
      appBar: AppBar(
        title: const Text("📚 Kayıtlı Kelimeler"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Word>>(
        stream: getWordsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Hata oluştu: ${snapshot.error}"));
          }

          final words = snapshot.data ?? [];

          if (words.isEmpty) {
            return const Center(child: Text("Henüz hiç kelime eklenmemiş."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: SizedBox(
                    width: 60,
                    height: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        word.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  title: Text(
                    word.eng,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Türkçesi: ${word.tur}"),
                      const SizedBox(height: 4),
                      Text(
                        "Örnek: ${word.samples.isNotEmpty ? word.samples.first : "Yok"}",
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => ttsService.speak(word.eng),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
