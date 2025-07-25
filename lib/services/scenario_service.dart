import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scenario_model.dart';
import 'user_preferences.dart';

class ScenarioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all active scenarios
  Future<List<ScenarioData>> getAllScenarios() async {
    try {
      final querySnapshot = await _firestore
          .collection('scenarios')
          .where('isActive', isEqualTo: true)
          .orderBy('requiredExp')
          .get();

      return querySnapshot.docs
          .map((doc) => ScenarioData.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting scenarios: $e');
      return [];
    }
  }

  // Get scenarios with user unlock status
  Future<List<ScenarioWithStatus>> getScenariosWithStatus() async {
    try {
      final scenarios = await getAllScenarios();
      final userData = await UserPreferences.getUserData();
      
      if (userData == null) return [];

      final userExp = userData['currentLevelExp'] ?? 0;
      final userLevel = userData['level'] ?? 1;

      return scenarios.map((scenario) => ScenarioWithStatus(
        scenario: scenario,
        isUnlocked: scenario.isUnlocked(userExp, userLevel),
        userExp: userExp,
        userLevel: userLevel,
      )).toList();
    } catch (e) {
      print('Error getting scenarios with status: $e');
      return [];
    }
  }

  // Get specific scenario by ID
  Future<ScenarioData?> getScenarioById(String id) async {
    try {
      final doc = await _firestore.collection('scenarios').doc(id).get();
      if (doc.exists) {
        return ScenarioData.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting scenario by ID: $e');
      return null;
    }
  }

  // Get scenario by title (for backward compatibility)
  Future<ScenarioData?> getScenarioByTitle(String title) async {
    try {
      final querySnapshot = await _firestore
          .collection('scenarios')
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ScenarioData.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting scenario by title: $e');
      return null;
    }
  }

  // Complete scenario and update user stats
  Future<void> completeScenario(String scenarioId, int livesRemaining) async {
    try {
      final userData = await UserPreferences.getUserData();
      if (userData == null) return;

      final scenario = await getScenarioById(scenarioId);
      if (scenario == null) return;

      // Calculate EXP based on performance
      int expGained = scenario.rewardExp;
      if (livesRemaining == 3) expGained += 20; // Perfect bonus
      if (livesRemaining == 2) expGained += 10; // Good bonus
      // No bonus for 1 life remaining

      // Update user stats in Firestore and SharedPreferences
      final currentExp = userData['currentLevelExp'] ?? 0;
      final totalScenarios = userData['totalScenarios'] ?? 0;
      
      final updateData = {
        'currentLevelExp': currentExp + expGained,
        'totalScenarios': totalScenarios + 1,
        'lastActivity': DateTime.now().toString(),
      };

      // Update in Firestore (assuming we have user service)
      // await _userService.updateUserStats(updateData);

      // Update in SharedPreferences
      final updatedUserData = Map<String, dynamic>.from(userData);
      updatedUserData.addAll(updateData);
      await UserPreferences.saveUserData(updatedUserData);

    } catch (e) {
      print('Error completing scenario: $e');
    }
  }

  // Admin function to seed scenarios (only for development)
  Future<void> seedScenarios() async {
    try {
      final scenarios = _getScenarioSeeds();
      
      for (final scenario in scenarios) {
        await _firestore
            .collection('scenarios')
            .doc(scenario.id)
            .set(scenario.toFirestore());
      }
      
      print('✅ Scenarios seeded successfully');
    } catch (e) {
      print('❌ Error seeding scenarios: $e');
    }
  }

  List<ScenarioData> _getScenarioSeeds() {
    return [
      // Beginner scenarios
      ScenarioData(
        id: 'interview_basics',
        title: 'Wawancara Kerja',
        category: 'Karier',
        tag: 'Beginner',
        iconName: 'record_voice_over',
        colorHex: '#FF6B6B',
        requiredExp: 0,
        requiredLevel: 1,
        isActive: true,
        rewardExp: 50,
        difficulty: 'Beginner',
        estimatedTime: 15,
        learningOutcomes: [
          'Persiapan wawancara yang efektif',
          'Menjawab pertanyaan umum dengan confidence',
          'Body language dan first impression',
          'Follow-up setelah wawancara'
        ],
        steps: [
          ScenarioStepData(
            story: 'Kamu duduk di ruang tunggu sebuah startup teknologi yang keren. Tanganmu sedikit berkeringat, jantung berdebar kencang. Ini adalah momen yang sudah kamu persiapkan berbulan-bulan!',
            characterEmoji: '😰',
            characterAlignment: 'center',
          ),
          ScenarioStepData(
            story: 'Pintu terbuka dan seorang wanita muda muncul dengan senyum ramah. "Hai! Kamu pasti Andi ya? Aku Sarah, HR Manager di sini. Siap untuk ngobrol santai?"',
            characterEmoji: '😊',
            characterAlignment: 'right',
          ),
          ScenarioStepData(
            story: 'Di ruang meeting yang nyaman, Sarah bertanya dengan antusias, "Jadi Andi, ceritakan dong tentang dirimu dan kenapa kamu tertarik join keluarga besar kami di sini?"',
            characterEmoji: '🤔',
            characterAlignment: 'right',
            choices: [
              ScenarioChoiceData(
                text: 'Langsung cerita tentang nilai IPK tinggi dan prestasi akademis',
                emoji: '🎓',
                isCorrect: false,
                feedback: 'Sarah terlihat kurang antusias. Dia lebih tertarik pada passion dan motivasimu.',
                reason: 'Pewawancara ingin melihat kepribadian dan kecocokan budaya, bukan hanya angka. Tunjukkan motivasi dan antusiasmemu!',
              ),
              ScenarioChoiceData(
                text: 'Bercerita tentang passion, lalu hubungkan dengan visi perusahaan',
                emoji: '✨',
                isCorrect: true,
                feedback: 'Sempurna! Mata Sarah berbinar-binar. Kamu menunjukkan riset yang mendalam dan minat yang tulus.',
                reason: 'Ini menunjukkan kamu proaktif dan benar-benar tertarik pada perusahaan, bukan sekadar mencari pekerjaan sembarangan.',
                expModifier: 10,
              ),
              ScenarioChoiceData(
                text: 'Cerita panjang tentang hobi gaming dan kehidupan sehari-hari',
                emoji: '🎮',
                isCorrect: false,
                feedback: 'Sarah terlihat bingung menghubungkan ceritamu dengan posisi pekerjaan.',
                reason: 'Meskipun kepribadian itu penting, tetap fokus pada hal-hal yang relevan dengan pekerjaan yang kamu lamar.',
                expModifier: -5,
              ),
            ],
          ),
          // Continue with more steps...
        ],
      ),

      ScenarioData(
        id: 'salary_negotiation',
        title: 'Negosiasi Gaji',
        category: 'Karier',
        tag: 'Intermediate',
        iconName: 'trending_up',
        colorHex: '#4ECDC4',
        requiredExp: 100,
        requiredLevel: 2,
        isActive: true,
        rewardExp: 75,
        difficulty: 'Intermediate',
        estimatedTime: 20,
        learningOutcomes: [
          'Riset market rate yang akurat',
          'Teknik negosiasi yang efektif',
          'Membangun value proposition',
          'Timing yang tepat untuk negosiasi'
        ],
        steps: [
          ScenarioStepData(
            story: 'Setelah 6 bulan bekerja di startup teknologi, kamu merasa kontribusimu sudah signifikan. Tim makin bergantung padamu, dan kamu sering lembur. Saatnya berbicara dengan boss tentang kenaikan gaji.',
            characterEmoji: '💪',
            characterAlignment: 'center',
          ),
          // Continue with salary negotiation steps...
        ],
      ),

      ScenarioData(
        id: 'budgeting_basics',
        title: 'Budgeting Bulanan',
        category: 'Keuangan',
        tag: 'Beginner',
        iconName: 'account_balance_wallet',
        colorHex: '#45B7D1',
        requiredExp: 50,
        requiredLevel: 1,
        isActive: true,
        rewardExp: 60,
        difficulty: 'Beginner',
        estimatedTime: 18,
        learningOutcomes: [
          'Prinsip budgeting 50-30-20',
          'Tracking pengeluaran efektif',
          'Emergency fund planning',
          'Investasi pemula'
        ],
        steps: [
          ScenarioStepData(
            story: 'Akhir bulan lagi, dan kamu menatap saldo rekening yang menipis. Padahal baru tanggal 25! "Kemana aja uang gue pergi sih?" gumammu sambil scrolling mobile banking.',
            characterEmoji: '😅',
            characterAlignment: 'center',
          ),
          // Continue with budgeting steps...
        ],
      ),

      ScenarioData(
        id: 'discrimination_handling',
        title: 'Menghadapi Diskriminasi',
        category: 'Sosial',
        tag: 'Intermediate',
        iconName: 'groups',
        colorHex: '#F7DC6F',
        requiredExp: 150,
        requiredLevel: 3,
        isActive: true,
        rewardExp: 80,
        difficulty: 'Intermediate',
        estimatedTime: 25,
        learningOutcomes: [
          'Mengenali bentuk diskriminasi',
          'Komunikasi assertif dan konstruktif',
          'Building allyship di workplace',
          'Formal reporting procedures'
        ],
        steps: [
          ScenarioStepData(
            story: 'Di kantor, kamu mendengar rekan kerja Alex membuat jokes yang menyinggung tentang background etnismu. Beberapa teman terlihat uncomfortable, tapi tidak ada yang speak up.',
            characterEmoji: '😔',
            characterAlignment: 'center',
          ),
          // Continue with discrimination steps...
        ],
      ),

      ScenarioData(
        id: 'housing_search',
        title: 'Mencari Tempat Tinggal',
        category: 'Lifestyle',
        tag: 'Intermediate',
        iconName: 'home',
        colorHex: '#96CEB4',
        requiredExp: 200,
        requiredLevel: 3,
        isActive: true,
        rewardExp: 70,
        difficulty: 'Intermediate',
        estimatedTime: 22,
        learningOutcomes: [
          'Location analysis dan prioritization',
          'Negotiation dengan landlord',
          'Legal aspects of renting',
          'Budget planning untuk housing'
        ],
        steps: [
          ScenarioStepData(
            story: 'Setelah 8 bulan ngekos, kamu memutuskan untuk cari tempat tinggal yang lebih proper. Budget limited tapi pengen tempat yang aman dan strategis. Time to hunt!',
            characterEmoji: '🏠',
            characterAlignment: 'center',
          ),
          // Continue with housing steps...
        ],
      ),

      // Advanced scenarios (locked initially)
      ScenarioData(
        id: 'debt_management',
        title: 'Manajemen Utang dan Pinjaman',
        category: 'Keuangan',
        tag: 'Advanced',
        iconName: 'credit_card_off',
        colorHex: '#E74C3C',
        requiredExp: 300,
        requiredLevel: 4,
        isActive: true,
        rewardExp: 100,
        difficulty: 'Advanced',
        estimatedTime: 30,
        learningOutcomes: [
          'Debt consolidation strategies',
          'Credit score management',
          'Emergency debt solutions',
          'Financial recovery planning'
        ],
        steps: [
          ScenarioStepData(
            story: 'Cicilan kartu kredit menumpuk, pinjaman online juga ada. Kamu mulai merasa tertekan dengan beban finansial. Saatnya ambil kontrol kembali!',
            characterEmoji: '😰',
            characterAlignment: 'center',
          ),
          ScenarioStepData(
            story: 'Kamu memutuskan untuk membuat list semua utang dan prioritasnya. Yang mana yang harus dibayar duluan?',
            characterEmoji: '📋',
            characterAlignment: 'center',
            choices: [
              ScenarioChoiceData(
                text: 'Bayar yang bunga paling tinggi dulu (avalanche method)',
                emoji: '🎯',
                isCorrect: true,
                feedback: 'Smart! Avalanche method secara matematis paling efisien untuk menghemat bunga.',
                reason: 'Debt avalanche method menghemat paling banyak uang dalam jangka panjang karena mengeliminasi bunga tertinggi dulu.',
                expModifier: 15,
              ),
              ScenarioChoiceData(
                text: 'Bayar yang jumlahnya paling kecil dulu (snowball method)',
                emoji: '⚡',
                isCorrect: false,
                feedback: 'Snowball method bagus untuk motivasi, tapi secara finansial kurang optimal dibanding avalanche.',
                reason: 'Meskipun snowball method baik untuk psychological wins, avalanche method lebih efisien secara finansial.',
                expModifier: 5,
              ),
              ScenarioChoiceData(
                text: 'Bayar semua utang dengan jumlah yang sama',
                emoji: '⚖️',
                isCorrect: false,
                feedback: 'Approach ini tidak optimal karena tidak mempertimbangkan tingkat bunga yang berbeda.',
                reason: 'Strategi ini tidak efektif karena mengabaikan perbedaan tingkat bunga antar utang.',
                expModifier: -10,
              ),
            ],
          ),
        ],
      ),

      ScenarioData(
        id: 'career_transition',
        title: 'Transisi Karier',
        category: 'Karier',
        tag: 'Advanced',
        iconName: 'swap_horiz',
        colorHex: '#9B59B6',
        requiredExp: 400,
        requiredLevel: 5,
        isActive: true,
        rewardExp: 120,
        difficulty: 'Advanced',
        estimatedTime: 35,
        learningOutcomes: [
          'Career transition planning',
          'Skill gap analysis',
          'Network building strategies',
          'Personal branding for career change'
        ],
        steps: [
          ScenarioStepData(
            story: 'Setelah 3 tahun di dunia marketing, kamu merasa passion-mu sebenarnya di tech. Tapi bagaimana cara transition yang smart tanpa membuang pengalaman yang sudah ada?',
            characterEmoji: '🤔',
            characterAlignment: 'center',
          ),
          // Continue with career transition steps...
        ],
      ),
    ];
  }
}

// Helper class for scenario with unlock status
class ScenarioWithStatus {
  final ScenarioData scenario;
  final bool isUnlocked;
  final int userExp;
  final int userLevel;

  ScenarioWithStatus({
    required this.scenario,
    required this.isUnlocked,
    required this.userExp,
    required this.userLevel,
  });

  int get expNeeded => scenario.requiredExp - userExp;
  int get levelsNeeded => scenario.requiredLevel - userLevel;
}