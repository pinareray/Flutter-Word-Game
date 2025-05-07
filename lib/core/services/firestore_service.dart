import 'package:cloud_firestore/cloud_firestore.dart';
import '../../feature/models/word.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  FirestoreService({required this.uid});

  CollectionReference<Map<String, dynamic>> get _userWordsRef =>
      _db.collection('users').doc(uid).collection('words');

  /// Yeni kelime ekler
  Future<void> addWord(Word word) async {
    try {
      await _userWordsRef.doc(word.id).set(word.toMap());
      print("✅ Firestore'a başarıyla eklendi: ${word.eng}");
    } catch (e) {
      print("❌ Firestore HATA (addWord): $e");
    }
  }

  /// Bugün tekrar edilmesi gereken kelimeleri getir
  Future<List<Word>> getTodayReviewWords() async {
    try {
      final snapshot = await _userWordsRef.get();
      final allWords =
          snapshot.docs.map((doc) => Word.fromMap(doc.data())).toList();

      final now = DateTime.now();
      final dueWords =
          allWords.where((word) {
            if (word.successCount >= 6) return false;
            return word.nextReviewAt == null ||
                word.nextReviewAt!.isBefore(now);
          }).toList();

      return dueWords;
    } catch (e) {
      print("❌ Firestore HATA (getTodayReviewWords): $e");
      return [];
    }
  }

  /// Quiz sonucu günceller (başarı/başarısızlık durumuna göre)
  Future<void> updateWordProgress({
    required String wordId,
    required bool isCorrect,
  }) async {
    final ref = _userWordsRef.doc(wordId);

    try {
      final doc = await ref.get();
      if (!doc.exists) return;

      final word = Word.fromMap(doc.data()!);

      final updatedWord = Word(
        id: word.id,
        eng: word.eng,
        tur: word.tur,
        samples: word.samples,
        imageUrl: word.imageUrl,
        audioUrl: word.audioUrl,
        repeatCount: isCorrect ? word.repeatCount + 1 : 0,
        successCount: isCorrect ? word.successCount + 1 : word.successCount,
        failCount: isCorrect ? word.failCount : word.failCount + 1,
        nextReviewAt: DateTime.now().add(
          Duration(days: isCorrect ? getNextInterval(word.repeatCount + 1) : 1),
        ),
        lastSeen: DateTime.now(),
      );

      await ref.set(updatedWord.toMap());
    } catch (e) {
      print("❌ Firestore HATA (updateWordProgress): $e");
    }
  }

  /// Tekrar zamanlaması için gün aralıkları
  int getNextInterval(int count) {
    const intervals = [1, 7, 30, 90, 180, 365];
    return (count >= intervals.length) ? 365 : intervals[count];
  }

  /// Tüm kelimeleri getir (listeleme)
  Future<List<Word>> getAllWords() async {
    try {
      final snapshot = await _userWordsRef.get();
      return snapshot.docs.map((doc) => Word.fromMap(doc.data())).toList();
    } catch (e) {
      print("❌ Firestore HATA (getAllWords): $e");
      return [];
    }
  }
}
