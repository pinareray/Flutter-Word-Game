import 'package:cloud_firestore/cloud_firestore.dart';
import '../../feature/models/word.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addWord(Word word) async {
    try {
      await _db.collection('words').doc(word.id).set(word.toMap());
      print("Firestore'a başarıyla eklendi: ${word.eng}");
    } catch (e) {
      print("Firestore HATA: $e");
    }
  }
}
