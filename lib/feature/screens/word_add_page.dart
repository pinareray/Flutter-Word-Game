import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/product/widgets/custom_text_field.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:flutter_word_game/product/constants/texts/app_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/services/firestore_service.dart';
import '../models/word.dart';

class WordAddScreen extends StatefulWidget {
  const WordAddScreen({super.key});

  @override
  State<WordAddScreen> createState() => _WordAddScreenState();
}

class _WordAddScreenState extends State<WordAddScreen> {
  final engController = TextEditingController();
  final turController = TextEditingController();
  final samplesController = TextEditingController();
  File? _selectedImage;
  bool _isSaving = false;
  late FirestoreService firestoreService;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      firestoreService = FirestoreService(uid: uid);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<String> uploadImageToFirebase(File imageFile, String fileName) async {
    final ref = FirebaseStorage.instance.ref().child('word_images/$fileName');
    final uploadTask = await ref.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<bool> isWordAlreadyExists(String eng) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('words')
            .where('eng', isEqualTo: eng.trim())
            .get();

    return snapshot.docs.isNotEmpty;
  }

  void saveWord() async {
    if (_isSaving) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    if (engController.text.isEmpty ||
        turController.text.isEmpty ||
        samplesController.text.isEmpty ||
        _selectedImage == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text(WordAddTexts.fillAllFields)),
      );
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    if (await isWordAlreadyExists(engController.text)) {
      messenger.showSnackBar(
        const SnackBar(content: Text(WordAddTexts.duplicateWord)),
      );
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    try {
      final id = const Uuid().v4();
      final fileName = '${engController.text.trim().toLowerCase()}_$id.jpg';
      final imageUrl = await uploadImageToFirebase(_selectedImage!, fileName);
      final now = DateTime.now();

      final newWord = Word(
        id: id,
        eng: engController.text.trim(),
        tur: turController.text.trim(),
        samples:
            samplesController.text.split(',').map((e) => e.trim()).toList(),
        imageUrl: imageUrl,
        audioUrl: null,
        repeatCount: 0,
        nextReviewAt: now.add(const Duration(days: 1)),
        successCount: 0,
        failCount: 0,
        lastSeen: now,
      );

      await firestoreService.addWord(newWord);

      messenger.showSnackBar(
        const SnackBar(content: Text(WordAddTexts.success)),
      );

      engController.clear();
      turController.clear();
      samplesController.clear();
      if (mounted) {
        setState(() => _selectedImage = null);
      }
    } catch (e) {
      print("❌ HATA: $e");
      messenger.showSnackBar(
        SnackBar(content: Text("${WordAddTexts.error}: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    engController.dispose();
    turController.dispose();
    samplesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(WordAddTexts.newWord),
        backgroundColor: ColorUtils.appbarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(
                hintText: WordAddTexts.englishLabel,
                controller: engController,
                suffixIcon: Icons.language,
              ),
              CustomTextField(
                hintText: WordAddTexts.turkishLabel,
                controller: turController,
                suffixIcon: Icons.translate,
              ),
              CustomTextField(
                hintText: WordAddTexts.sampleLabel,
                controller: samplesController,
                suffixIcon: Icons.edit,
              ),
              const SizedBox(height: 16),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 150)
                  : const Text(WordAddTexts.noImageSelected),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text(WordAddTexts.pickImage),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSaving ? null : saveWord,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                ),
                child:
                    _isSaving
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(WordAddTexts.saveWord),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
