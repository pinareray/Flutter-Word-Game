class Word {
  final String id;
  final String eng;
  final String tur;
  final List<String> samples;
  final String imageUrl;
  final String? audioUrl;
  final int repeatCount; // Tekrar algoritması için
  final int successCount; //  Toplam doğru sayısı
  final int failCount; //  Toplam yanlış sayısı
  final DateTime nextReviewAt; //  Ne zaman tekrar edilecek
  final DateTime lastSeen; //  En son ne zaman gösterildi

  Word({
    required this.id,
    required this.eng,
    required this.tur,
    required this.samples,
    required this.imageUrl,
    this.audioUrl,
    required this.repeatCount,
    required this.successCount,
    required this.failCount,
    required this.nextReviewAt,
    required this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eng': eng,
      'tur': tur,
      'samples': samples,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'repeatCount': repeatCount,
      'successCount': successCount,
      'failCount': failCount,
      'nextReviewAt': nextReviewAt.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      eng: map['eng'],
      tur: map['tur'],
      samples: List<String>.from(map['samples']),
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      repeatCount: map['repeatCount'] ?? 0,
      successCount: map['successCount'] ?? 0,
      failCount: map['failCount'] ?? 0,
      nextReviewAt: DateTime.parse(map['nextReviewAt']),
      lastSeen: DateTime.parse(map['lastSeen']),
    );
  }
}
