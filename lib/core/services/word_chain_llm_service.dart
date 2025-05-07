class WordChainLLMService {
  Future<String> generateStory(List<String> words) async {
    return Future.delayed(
      const Duration(seconds: 1),
      () => "Bir gün ${words[0]} ile başlayan bir yolculuk "
          "${words[1]} şehrinde devam etti. Orada ${words[2]} adlı bir "
          "yaratıkla karşılaştı. Neyse ki ${words[3]} ona yardım etti ve "
          "${words[4]} ile dost oldu.",
    );
  }

  Future<String> generateImagePrompt(List<String> words) async {
    return Future.delayed(
      const Duration(milliseconds: 500),
      () => "A magical forest where ${words.join(', ')} are characters in an adventure.",
    );
  }

  Future<String> generateImageFromPrompt(String prompt) async {
    return Future.delayed(
      const Duration(seconds: 1),
      () => "https://placehold.co/600x300?text=LLM+Image",
    );
  }
}
