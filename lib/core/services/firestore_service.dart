import 'package:cloud_firestore/cloud_firestore.dart';
import '../../feature/models/word.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  FirestoreService({required this.uid});

  CollectionReference<Map<String, dynamic>> get _userWordsRef =>
      _db.collection('users').doc(uid).collection('words');

  DocumentReference<Map<String, dynamic>> get _userSettingsRef => _db
      .collection('users')
      .doc(uid)
      .collection('settings')
      .doc('preferences');

  /// Yeni kelime ekleme işlemini yaptım
  Future<void> addWord(Word word) async {
    try {
      await _userWordsRef.doc(word.id).set(word.toMap());
      print("Firestore'a başarıyla eklendi: ${word.eng}");
    } catch (e) {
      print("Firestore HATA (addWord): $e");
    }
  }

  /// Günlük tekrar sayısı kadar kelimeyi getirdik
  Future<List<Word>> getTodayReviewWords() async {
    try {
      final snapshot = await _userWordsRef.get();
      final allWords =
          snapshot.docs.map((doc) => Word.fromMap(doc.data())).toList();

      final now = DateTime.now();

      print(" Şu an: $now");
      print(" Kelime sayısı: ${allWords.length}");

      final dueWords =
          allWords.where((word) {
            print(
              "👉 ${word.eng} - nextReviewAt: ${word.nextReviewAt}, success: ${word.successCount}",
            );

            if (word.successCount >= 6) return false;
            return word.nextReviewAt == null ||
                word.nextReviewAt!.isBefore(now);
          }).toList();

      print(" Tekrar edilmesi gereken kelime sayısı: ${dueWords.length}");

      final settings = await getUserSettings();
      final limit = settings['dailyLimit'] ?? 10;

      return dueWords.take(limit).toList();
    } catch (e) {
      print("Firestore HATA (getTodayReviewWords): $e");
      return [];
    }
  }

  /// Quiz sonucunu güncelleriz
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
      print("Firestore HATA (updateWordProgress): $e");
    }
  }

  /// Zamanlama aralığı
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
      print("Firestore HATA (getAllWords): $e");
      return [];
    }
  }

  /// Kullanıcı ayarlarını getir (varsayılan: günlük limit 10)
  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      final doc = await _userSettingsRef.get();
      return doc.exists ? doc.data() ?? {} : {'dailyLimit': 10};
    } catch (e) {
      print("Firestore HATA (getUserSettings): $e");
      return {'dailyLimit': 10};
    }
  }

  /// Kullanıcı ayarlarını güncelle
  Future<void> updateUserSettings({required int dailyLimit}) async {
    try {
      await _userSettingsRef.set({'dailyLimit': dailyLimit});
      print("Kullanıcı ayarları güncellendi");
    } catch (e) {
      print("Firestore HATA (updateUserSettings): $e");
    }
  }

  /// Öğrenilmiş kelimeleri getir (successCount >= 6)
  Future<List<Word>> getLearnedWords() async {
    try {
      final snapshot =
          await _userWordsRef
              .where('successCount', isGreaterThanOrEqualTo: 6)
              .get();

      return snapshot.docs.map((doc) => Word.fromMap(doc.data())).toList();
    } catch (e) {
      print("Firestore HATA (getLearnedWords): $e");
      return [];
    }
  }

  /// Word Chain hikayesini ve görsel URL'sini kaydeder
  Future<void> saveWordChainStory({
    required List<String> words,
    required String story,
    required String imageUrl,
  }) async {
    try {
      await _db.collection('users').doc(uid).collection('word_chains').add({
        'words': words,
        'story': story,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
      });

      print("Word Chain hikayesi kaydedildi");
    } catch (e) {
      print("Firestore HATA (saveWordChainStory): $e");
    }
  }
}
