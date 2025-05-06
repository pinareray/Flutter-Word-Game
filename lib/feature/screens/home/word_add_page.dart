import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../../../core/services/firestore_service.dart';
import '../../models/word.dart';

class WordAddScreen extends StatefulWidget {
  @override
  _WordAddScreenState createState() => _WordAddScreenState();
}

class _WordAddScreenState extends State<WordAddScreen> {
  final engController = TextEditingController();
  final turController = TextEditingController();
  final samplesController = TextEditingController();

  final firestoreService = FirestoreService();

  // ASSET GÖRSELİ YÜKLEYEN FONKSİYON
  Future<String> _uploadAssetImage(String assetPath, String fileName) async {
    try {
      print("📦 Asset yükleniyor: $assetPath");

      final byteData = await rootBundle.load(assetPath);
      final Uint8List data = byteData.buffer.asUint8List();

      final ref = FirebaseStorage.instance.ref().child('word_images/$fileName');
      final uploadTask = await ref.putData(data);

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print("✅ Asset görsel yüklendi: $downloadUrl");
        return downloadUrl;
      } else {
        throw Exception("❌ Firebase yükleme başarısız.");
      }
    } catch (e) {
      print("❌ Asset yükleme hatası: $e");
      rethrow;
    }
  }

  void saveWord() async {
    try {
      final id = Uuid().v4();

      // 🔁 ASSET'TEN YÜKLEME YAPIYORUZ
      final imageUrl = await _uploadAssetImage(
        'assets/banana.jpg',
        'banana_$id.jpg',
      );

      final newWord = Word(
        id: id,
        eng: engController.text,
        tur: turController.text,
        samples: samplesController.text.split(','),
        imageUrl: imageUrl,
      );

      await firestoreService.addWord(newWord);
      print("✅ Firestore'a kelime eklendi: ${newWord.eng}");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Kelime eklendi!")));

      engController.clear();
      turController.clear();
      samplesController.clear();
    } catch (e) {
      print("❌ HATA oluştu: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata oluştu: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kelime Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: engController,
                decoration: InputDecoration(labelText: "İngilizce"),
              ),
              TextField(
                controller: turController,
                decoration: InputDecoration(labelText: "Türkçe"),
              ),
              TextField(
                controller: samplesController,
                decoration: InputDecoration(
                  labelText: "Örnekler (virgülle ayır)",
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveWord,
                child: Text("Kaydet (Asset Görselli)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
