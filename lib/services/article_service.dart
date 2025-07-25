import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gh6_ucap/models/articles_model.dart';
import 'package:gh6_ucap/services/profile_service.dart';
import 'user_preferences.dart';

class ArticleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileService _profileService = ProfileService();

  // Get user stats
  Future<Map<String, int>> getUserStats() async {
    try {
      final userData = await UserPreferences.getUserData();
      return {
        'level': userData?['level'] ?? 1,
        'exp': userData?['currentLevelExp'] ?? 0,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {'level': 1, 'exp': 0};
    }
  }

  // Get user completed articles
  Future<List<String>> getUserCompletedArticles() async {
    try {
      final userData = await UserPreferences.getUserData();
      return List<String>.from(userData?['completedArticles'] ?? []);
    } catch (e) {
      return [];
    }
  }

  // Get categories with completion status
  Future<List<Map<String, dynamic>>> getCategoriesWithStatus() async {
    try {
      final completedArticleIds = await getUserCompletedArticles();

      final snapshot = await _firestore
          .collection('article_categories')
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get();

      List<Map<String, dynamic>> categories = [];

      for (var doc in snapshot.docs) {
        final category = ArticleCategory.fromFirestore(doc);

        // Get articles count for this category
        final articlesSnapshot = await _firestore
            .collection('articles')
            .where('categoryId', isEqualTo: category.id)
            .where('isActive', isEqualTo: true)
            .get();

        final totalArticles = articlesSnapshot.docs.length;
        final completedCount = articlesSnapshot.docs
            .where((doc) => completedArticleIds.contains(doc.id))
            .length;

        categories.add({
          'category': category,
          'totalArticles': totalArticles,
          'completedCount': completedCount,
          'completionPercentage': totalArticles > 0
              ? (completedCount / totalArticles * 100).round()
              : 0,
        });
      }

      return categories;
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // Get articles by category
  Future<List<Map<String, dynamic>>> getArticlesByCategory(
    String categoryId,
  ) async {
    try {
      final completedArticleIds = await getUserCompletedArticles();

      final snapshot = await _firestore
          .collection('articles')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt')
          .get();

      return snapshot.docs.map((doc) {
        final article = Article.fromFirestore(doc);
        return {
          'article': article,
          'isCompleted': completedArticleIds.contains(article.id),
        };
      }).toList();
    } catch (e) {
      print('Error getting articles: $e');
      return [];
    }
  }

  // Complete article and give EXP
  Future<void> completeArticle(String articleId) async {
    try {
      print('🔄 Starting article completion: $articleId');

      // Check if already completed first
      final completedArticles = await getUserCompletedArticles();
      if (completedArticles.contains(articleId)) {
        print('⚠️ Article already completed: $articleId');
        return;
      }

      // Get article details from Firestore
      final articleDoc = await _firestore
          .collection('articles')
          .doc(articleId)
          .get();
      if (!articleDoc.exists) {
        print('❌ Article not found in Firestore: $articleId');
        throw Exception('Article not found');
      }

      final article = Article.fromFirestore(articleDoc);
      print('📖 Article found: ${article.title} (+${article.expReward} EXP)');

      // 🔥 SAVE EXP MENGGUNAKAN ProfileService (sama seperti daily quest)
      await _profileService.addExperience(article.expReward);
      print('✅ EXP saved via ProfileService: +${article.expReward}');

      // 🔥 UPDATE completed articles list
      final userData = await UserPreferences.getUserData();
      if (userData != null) {
        final updatedCompletedArticles = List<String>.from(
          userData['completedArticles'] ?? [],
        );
        updatedCompletedArticles.add(articleId);

        final totalArticles = userData['totalArticlesRead'] ?? 0;

        final updatedData = Map<String, dynamic>.from(userData);
        updatedData.addAll({
          'completedArticles': updatedCompletedArticles,
          'totalArticlesRead': totalArticles + 1,
          'lastActivity': DateTime.now().toString(),
          'lastArticleCompleted': article.title,
        });

        await UserPreferences.saveUserData(updatedData);
        print('✅ Article completion saved to UserPreferences');
      }

      print('🎉 Article completion process finished successfully!');
    } catch (e) {
      print('❌ Error completing article: $e');
      rethrow;
    }
  }

  // Seed articles to Firestore
  Future<void> seedArticles() async {
    try {
      // Check if already seeded
      final existingSnapshot = await _firestore
          .collection('article_categories')
          .limit(1)
          .get();
      if (existingSnapshot.docs.isNotEmpty) {
        print('✅ Articles already seeded');
        return;
      }

      // Seed categories
      final categories = _getArticleCategories();
      for (final category in categories) {
        await _firestore
            .collection('article_categories')
            .doc(category.id)
            .set(category.toFirestore());
      }

      // Seed articles
      final articles = _getArticleSeeds();
      for (final article in articles) {
        await _firestore.collection('articles').add(article.toFirestore());
      }

      print(
        '✅ Successfully seeded ${categories.length} categories and ${articles.length} articles',
      );
    } catch (e) {
      print('❌ Error seeding articles: $e');
    }
  }

  List<ArticleCategory> _getArticleCategories() {
    return [
      ArticleCategory(
        id: 'karier',
        name: 'Karier',
        description: 'Tips dan panduan untuk mengembangkan karier',
        iconName: 'work',
        colorHex: '#2196F3',
        sortOrder: 1,
        isActive: true,
        totalArticles: 3,
      ),
      ArticleCategory(
        id: 'keuangan',
        name: 'Keuangan',
        description: 'Mengelola keuangan pribadi dengan bijak',
        iconName: 'account_balance_wallet',
        colorHex: '#4CAF50',
        sortOrder: 2,
        isActive: true,
        totalArticles: 3,
      ),
      ArticleCategory(
        id: 'sosial',
        name: 'Sosial',
        description: 'Membangun hubungan sosial yang sehat',
        iconName: 'groups',
        colorHex: '#FF9800',
        sortOrder: 3,
        isActive: true,
        totalArticles: 2,
      ),
      ArticleCategory(
        id: 'praktis',
        name: 'Praktis',
        description: 'Tips praktis kehidupan sehari-hari',
        iconName: 'lightbulb',
        colorHex: '#9C27B0',
        sortOrder: 4,
        isActive: true,
        totalArticles: 2,
      ),
    ];
  }

  List<Article> _getArticleSeeds() {
    return [
      // Karier
      Article(
        id: '',
        title: 'Tips Sukses Wawancara Kerja',
        content: '''# Tips Sukses Wawancara Kerja

## Persiapan Sebelum Wawancara
- Riset tentang perusahaan
- Persiapkan jawaban untuk pertanyaan umum
- Siapkan pertanyaan untuk interviewer

## Saat Wawancara
- Datang tepat waktu
- Berpakaian rapi dan profesional
- Tunjukkan antusiasme dan percaya diri

## Follow-up
- Kirim email thank you dalam 24 jam
- Tanyakan timeline proses seleksi''',
        categoryId: 'karier',
        type: 'article',
        expReward: 15,
        readTime: 5,
        isActive: true,
        createdAt: DateTime.now(),
      ),

      Article(
        id: '',
        title: 'Cara Negosiasi Gaji yang Efektif',
        content: '''# Cara Negosiasi Gaji yang Efektif

## Riset Market Rate
- Gunakan situs seperti Glassdoor atau JobStreet
- Tanyakan ke teman di industri yang sama
- Pertimbangkan lokasi dan level pengalaman

## Timing yang Tepat
- Setelah mendapat job offer
- Saat performance review
- Setelah menyelesaikan proyek besar

## Tips Negosiasi
- Fokus pada value yang kamu berikan
- Berikan range, bukan angka pasti
- Pertimbangkan benefit selain gaji''',
        categoryId: 'karier',
        type: 'article',
        expReward: 20,
        readTime: 7,
        isActive: true,
        createdAt: DateTime.now(),
      ),

      // Keuangan
      Article(
        id: '',
        title: 'Budgeting 50-30-20 untuk Pemula',
        content: '''# Budgeting 50-30-20 untuk Pemula

## Apa itu Rule 50-30-20?
- 50% untuk kebutuhan (needs)
- 30% untuk keinginan (wants)  
- 20% untuk tabungan dan investasi

## Kategori Kebutuhan (50%)
- Sewa/cicilan rumah
- Makanan pokok
- Transport
- Tagihan listrik, air, internet

## Kategori Keinginan (30%)
- Entertainment
- Makan di luar
- Shopping
- Hobi

## Tabungan & Investasi (20%)
- Emergency fund
- Investasi jangka panjang
- Dana pensiun''',
        categoryId: 'keuangan',
        type: 'article',
        expReward: 18,
        readTime: 6,
        isActive: true,
        createdAt: DateTime.now(),
      ),

      Article(
        id: '',
        title: 'Membangun Emergency Fund',
        content: '''# Membangun Emergency Fund

## Kenapa Penting?
- Proteksi dari kejadian tak terduga
- Menghindari hutang saat darurat
- Memberikan ketenangan pikiran

## Berapa Jumlahnya?
- Minimal 3-6 bulan pengeluaran
- Untuk freelancer: 6-12 bulan
- Mulai dari yang kecil dulu

## Tips Mengumpulkan
- Otomatis transfer ke rekening terpisah
- Gunakan aplikasi micro-investing
- Kurangi pengeluaran yang tidak perlu''',
        categoryId: 'keuangan',
        type: 'article',
        expReward: 15,
        readTime: 5,
        isActive: true,
        createdAt: DateTime.now(),
      ),

      // Sosial
      Article(
        id: '',
        title: 'Menghadapi Konflik di Tempat Kerja',
        content: '''# Menghadapi Konflik di Tempat Kerja

## Identifikasi Penyebab
- Perbedaan pendapat
- Miscommunication
- Personality clash
- Kompetisi tidak sehat

## Cara Mengatasi
- Tetap tenang dan objektif
- Dengarkan sudut pandang lain
- Fokus pada solusi, bukan masalah
- Libatkan mediator jika perlu

## Prevention Tips
- Komunikasi yang jelas
- Set expectations yang realistis
- Build relationship dengan kolega''',
        categoryId: 'sosial',
        type: 'article',
        expReward: 16,
        readTime: 6,
        isActive: true,
        createdAt: DateTime.now(),
      ),

      // Praktis
      Article(
        id: '',
        title: 'Tips Mencari Kost yang Aman',
        content: '''# Tips Mencari Kost yang Aman

## Riset Lokasi
- Cek keamanan lingkungan
- Akses ke transport umum
- Fasilitas sekitar (minimarket, laundry)

## Yang Harus Dicek
- Kondisi kamar dan fasilitas
- Aturan kost
- Harga dan sistem pembayaran
- CCTV dan sistem keamanan

## Red Flags
- Harga terlalu murah
- Pemilik tidak mau show around
- Tidak ada kontrak jelas
- Lingkungan tidak aman''',
        categoryId: 'praktis',
        type: 'article',
        expReward: 12,
        readTime: 4,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
