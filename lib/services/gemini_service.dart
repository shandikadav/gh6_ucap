import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = "AIzaSyAMlHahCrhr7BhDKh4vyPTjTOzE2C-P3UA";
  final GenerativeModel _model;

  GeminiService()
    : _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

  /// Generate personalized feedback based on user's reasoning
  Future<String> generateFeedback({
    required String scenarioContext,
    required String userChoice,
    required String userReason,
  }) async {
    try {
      // Enhanced prompt for better feedback
      final prompt =
          '''
        Kamu adalah AI Mentor yang bijak dan empati dalam aplikasi "Ucap" untuk anak muda Indonesia yang berada di panti asuhan. 
        Tugasmu memberikan feedback yang personal, konstruktif, dan menyemangati.

        KONTEKS SKENARIO:
        "$scenarioContext"

        PILIHAN USER:
        "$userChoice"

        ALASAN USER:
        "$userReason"

        INSTRUKSI FEEDBACK:
        1. Analisis alasan user dengan empati - apakah logis? Apa strength dan area improvement?
        2. Berikan feedback maksimal 2-3 kalimat yang:
           - Personal (sesuai alasan mereka)
           - Konstruktif (beri insight baru)
           - Positif (meskipun salah, tetap encouraging)
           - Pakai bahasa casual tapi respectful
           - Gunakan emoji yang tepat
        3. Fokus pada proses berpikir, bukan hanya hasil
        4. Akhiri dengan actionable insight atau encouragement

        GAYA BAHASA:
        - Panggil user dengan "kamu"
        - Bahasa Indonesia casual tapi sopan
        - Gunakan emoji 1-2 buah yang relevan
        - Tone seperti kakak yang supportive

        CONTOH GOOD FEEDBACK:
        "Pemikiranmu tentang prioritas keuangan sudah bagus! 💰 Kamu sudah mempertimbangkan aspek jangka panjang, itu menunjukkan maturity. Next time coba juga pertimbangkan faktor risiko ya!"

        Berikan feedback sekarang:
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      // Clean up response
      String feedback =
          response.text ?? "Maaf, ada gangguan teknis. Tetap semangat ya!";

      // Remove any unwanted formatting
      feedback = feedback.trim();
      if (feedback.startsWith('"') && feedback.endsWith('"')) {
        feedback = feedback.substring(1, feedback.length - 1);
      }

      return feedback;
    } catch (e) {
      print("Error generating feedback: $e");
      return _getEmergencyFallback(userReason);
    }
  }

  // Emergency fallback based on reasoning analysis
  String _getEmergencyFallback(String userReason) {
    final reason = userReason.toLowerCase();

    // Simple keyword-based fallback
    if (reason.contains('pengalaman') || reason.contains('pernah')) {
      return "Bagus! 🌟 Kamu menggunakan pengalaman sebagai wisdom. Learning from experience itu powerful banget!";
    } else if (reason.contains('logis') || reason.contains('masuk akal')) {
      return "Excellent! 🧠 Pendekatan logical thinking-mu keren. Terus kembangkan analytical skill seperti ini!";
    } else if (reason.contains('feeling') || reason.contains('rasa')) {
      return "Nice! 💫 Gut feeling yang terasah adalah skill berharga. Balance dengan data juga ya!";
    } else if (reason.contains('tidak tahu') || reason.contains('bingung')) {
      return "It's okay! 🤗 Ketidakpastian adalah bagian dari learning. Keep exploring dan jangan takut salah!";
    } else {
      return "Good thinking! ✨ Setiap reasoning adalah step menuju wisdom. Terus kembangkan critical thinking ya!";
    }
  }

  // Alternative method untuk feedback yang lebih spesifik berdasarkan kategori
  Future<String> generateCategorySpecificFeedback({
    required String category,
    required String userChoice,
    required String userReason,
    required bool isCorrect,
  }) async {
    final categoryPrompts = {
      'Wawancara Kerja':
          'Fokus pada professional communication dan self-presentation',
      'Negosiasi Gaji': 'Fokus pada value proposition dan win-win solution',
      'Budgeting Bulanan':
          'Fokus pada financial literacy dan long-term planning',
      'Menghadapi Diskriminasi':
          'Fokus pada assertiveness dan constructive conflict resolution',
      'Mencari Tempat Tinggal':
          'Fokus pada practical decision making dan risk assessment',
    };

    final specificContext = categoryPrompts[category] ?? 'general life skills';

    return await generateFeedback(
      scenarioContext:
          'Skenario tentang $category dengan fokus pada $specificContext',
      userChoice: userChoice,
      userReason: userReason,
    );
  }
}
