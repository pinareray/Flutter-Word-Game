class Word {
  final String id;
  final String eng;
  final String tur;
  final List<String> samples;
  final String imageUrl;
  final String? audioUrl;

  Word({
    required this.id,
    required this.eng,
    required this.tur,
    required this.samples,
    required this.imageUrl,
    this.audioUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eng': eng,
      'tur': tur,
      'samples': samples,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
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
    );
  }
}
