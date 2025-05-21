import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/feature/screens/%20statistic_screen.dart';
import 'package:flutter_word_game/feature/screens/puzzle_screen.dart';
import 'package:flutter_word_game/feature/screens/rewiew_today_screen.dart';
import 'package:flutter_word_game/feature/screens/setting_page.dart';
import 'package:flutter_word_game/feature/screens/word_add_page.dart';
import 'package:flutter_word_game/feature/screens/word_chain_screen.dart';
import 'package:flutter_word_game/feature/screens/word_listen_screen.dart';
import 'package:flutter_word_game/feature/screens/quiz_screen.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_word_game/product/constants/size_utils.dart';
import 'package:flutter_word_game/product/constants/texts/app_text.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/firestore_service.dart';

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
    final firestoreService = FirestoreService(uid: user.uid);
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

  Future<void> _openStatistics(BuildContext context) async {
    final firestoreService = FirestoreService(uid: user.uid);
    final words = await firestoreService.getAllWords();

    final total = words.length;
    final correct = words.fold(0, (sum, word) => sum + word.successCount);
    final incorrect = words.fold(0, (sum, word) => sum + word.failCount);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => StatisticsScreen(
              total: total,
              correct: correct,
              incorrect: incorrect,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorUtils.appbarColor,
        title: Text(
          '🎮 Kelime Oyunu',
          style: GoogleFonts.permanentMarker(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/game.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppSizedBoxes.md3,
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${AppTexts.welcome}, ${userName ?? user.email}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            AppSizedBoxes.xs1,
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildGameCard(Icons.add, AppTexts.addWord, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WordAddScreen()),
                    );
                  }),
                  _buildGameCard(Icons.list, AppTexts.listWord, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WordListScreen()),
                    );
                  }),
                  _buildGameCard(Icons.repeat, AppTexts.repeatToday, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReviewTodayScreen(),
                      ),
                    );
                  }),
                  _buildGameCard(
                    Icons.play_arrow,
                    AppTexts.quiz,
                    () => _startQuiz(context),
                  ),
                  _buildGameCard(
                    Icons.bar_chart,
                    AppTexts.istatistic,
                    () => _openStatistics(context),
                  ),
                  _buildGameCard(Icons.extension, AppTexts.puzzle, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PuzzleScreen()),
                    );
                  }),
                  _buildGameCard(Icons.auto_stories, AppTexts.wordChain, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WordChainScreen(),
                      ),
                    );
                  }),
                  _buildGameCard(Icons.settings, AppTexts.settings, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.deepPurple.shade300,
        elevation: 6,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
