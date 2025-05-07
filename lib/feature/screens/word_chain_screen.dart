import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/word_chain_llm_service.dart';
import '../models/word.dart';

class WordChainScreen extends StatefulWidget {
  const WordChainScreen({super.key});

  @override
  State<WordChainScreen> createState() => _WordChainScreenState();
}

class _WordChainScreenState extends State<WordChainScreen> {
  late FirestoreService firestoreService;
  final llmService = WordChainLLMService();
  List<String> selectedWords = [];
  String story = '';
  String? imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      firestoreService = FirestoreService(uid: uid);
      _generateStoryAndImage();
    }
  }

  Future<void> _generateStoryAndImage() async {
    final allWords = await firestoreService.getLearnedWords();
    if (allWords.length < 5) {
      setState(() {
        story = "📭 En az 5 öğrenilmiş kelimeye ihtiyacınız var.";
        isLoading = false;
      });
      return;
    }

    allWords.shuffle();
    selectedWords = allWords.take(5).map((e) => e.eng).toList();

    story = await llmService.generateStory(selectedWords);
    final prompt = await llmService.generateImagePrompt(selectedWords);
    imageUrl = await llmService.generateImageFromPrompt(prompt);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📚 Word Chain Story")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Seçilen Kelimeler:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            selectedWords
                                .map((word) => Chip(label: Text(word)))
                                .toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Otomatik Oluşan Hikaye:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(story),
                      const SizedBox(height: 24),
                      if (imageUrl != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Üretilen Hikaye Görseli:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(imageUrl!),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}
