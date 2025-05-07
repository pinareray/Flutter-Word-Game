import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/feature/screens/rewiew_today_screen.dart';
import 'package:flutter_word_game/feature/screens/word_add_page.dart';
import 'package:flutter_word_game/feature/screens/word_listen_screen.dart';
import 'package:flutter_word_game/feature/screens/quiz_screen.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firestore_service.dart';
import '../models/word.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    if (doc.exists) {
      setState(() {
        userName = doc['userName'];
      });
    }
  }

  Future<void> _startQuiz(BuildContext context) async {
    final firestoreService = FirestoreService(uid: user.uid); // ✅ GÜNCELLENDİ
    final todayWords = await firestoreService.getTodayReviewWords();

    if (todayWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bugün tekrarlanacak kelime yok.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizScreen(words: todayWords)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ana Sayfa"),
        backgroundColor: ColorUtils.appbarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Giriş yaptınız: ${userName ?? user.email}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),

            _buildButton(
              icon: Icons.add,
              label: "Kelime Ekle",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WordAddScreen(),
                    ),
                  ),
            ),
            const SizedBox(height: 16),

            _buildButton(
              icon: Icons.list,
              label: "Kelimeleri Listele",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WordListScreen(),
                    ),
                  ),
            ),
            const SizedBox(height: 16),

            _buildButton(
              icon: Icons.repeat,
              label: "Bugünkü Tekrarlar",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReviewTodayScreen(),
                    ),
                  ),
            ),
            const SizedBox(height: 16),

            _buildButton(
              icon: Icons.play_arrow,
              label: "Quiz'e Başla",
              onTap: () => _startQuiz(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorUtils.appColor,
        minimumSize: const Size.fromHeight(45),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
