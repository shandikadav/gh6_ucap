import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gh6_ucap/models/community_model.dart';
import 'package:gh6_ucap/services/profile_service.dart';
import 'package:gh6_ucap/services/user_preferences.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore;
  final ProfileService _profileService = ProfileService();

  CommunityRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ForumQuestion>> fetchForumQuestions() async {
    try {
      final snapshot = await _firestore
          .collection('forums')
          .orderBy('createdAt', descending: true)
          .get();

      // Handle empty collection dengan sample data
      if (snapshot.docs.isEmpty) {
        return _getSampleQuestions();
      }

      return snapshot.docs
          .map((doc) => ForumQuestion.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching forum questions: $e');
      // Return sample data on error
      return _getSampleQuestions();
    }
  }

  Future<List<Mentor>> fetchMentors() async {
    try {
      final snapshot = await _firestore.collection('mentors').get();

      // Handle empty collection dengan sample data
      if (snapshot.docs.isEmpty) {
        return _getSampleMentors();
      }

      return snapshot.docs.map((doc) => Mentor.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching mentors: $e');
      // Return sample data on error
      return _getSampleMentors();
    }
  }

  /// FUNGSI BARU: Menambahkan pertanyaan baru ke koleksi 'forums'.
  Future<void> createForumQuestion({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    required bool isAnonymous,
  }) async {
    try {
      final userData = await UserPreferences.getUserData();
      final realUserId = userData?['uid'] ?? authorId;
      await _firestore.collection('forums').add({
        'title': title,
        'content': content,
        'authorId': realUserId,
        'authorName': isAnonymous ? 'Anonim' : authorName,
        'isAnonymous': isAnonymous,
        'replyCount': 0, // Pertanyaan baru belum ada balasan
        'tags': [], // Bisa ditambahkan nanti
        'createdAt': FieldValue.serverTimestamp(), // Timestamp dari server
      });

      await _profileService.updateForumActivity();
    } catch (e) {
      print('Error creating forum question: $e');
      throw Exception('Gagal mengirim pertanyaan');
    }
  }

  // Sample data untuk demo ketika collection kosong
  List<ForumQuestion> _getSampleQuestions() {
    return [
      ForumQuestion(
        id: 'sample_1',
        title: 'Bagaimana cara negosiasi gaji saat fresh graduate?',
        content:
            'Aku baru lulus dan dapat tawaran kerja. Tapi gajinya di bawah ekspektasi. Boleh ga sih nego gaji? Takut malah ditolak...',
        authorName: 'Anonim',
        isAnonymous: true,
        replyCount: 12,
        createdAt: Timestamp.fromDate(
          DateTime.now().subtract(Duration(hours: 2)),
        ),
        authorId: "",
      ),
      ForumQuestion(
        id: 'sample_2',
        title: 'Tips menghadapi diskriminasi di tempat kerja?',
        content:
            'Ada yang pernah ngalamin diperlakukan beda karena background kita? Gimana cara ngatasinya ya?',
        authorName: 'Anonim',
        authorId: "",
        isAnonymous: true,
        replyCount: 8,
        createdAt: Timestamp.fromDate(
          DateTime.now().subtract(Duration(hours: 5)),
        ),
      ),
      ForumQuestion(
        id: 'sample_3',
        title: 'Rekomendasi tempat kos yang aman dan murah?',
        content:
            'Lagi cari kos di area Jakarta Selatan budget 1-1.5 juta. Ada yang punya rekomendasi?',
        authorName: 'Sarah M.',
        isAnonymous: false,
        replyCount: 15,
        createdAt: Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 1)),
        ),
        authorId: "",
      ),
      ForumQuestion(
        id: 'sample_4',
        title: 'Bagaimana cara balance antara kerja dan kuliah?',
        content:
            'Saya kuliah sambil kerja part-time. Tapi akhir-akhir ini susah banget manage waktunya. Ada tips?',
        authorName: 'Budi P.',
        isAnonymous: false,
        replyCount: 6,
        createdAt: Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 2)),
        ),
        authorId: "",
      ),
    ];
  }

  List<Mentor> _getSampleMentors() {
    return [
      Mentor(
        id: 'sample_mentor_1',
        name: 'Budi Santoso',
        title: 'HR Manager & Career Coach',
        bio:
            'HR Manager dengan 10+ tahun pengalaman di berbagai industri. Spesialis career development untuk fresh graduate.',
        profilePictureUrl: '',
        isOnline: true,
        skills: [
          'Review CV',
          'Interview Prep',
          'Career Planning',
          'Salary Negotiation',
        ],
      ),
      Mentor(
        id: 'sample_mentor_2',
        name: 'Sarah Wijaya',
        title: 'Financial Planner',
        bio:
            'Certified Financial Planner dengan fokus membantu young professional mengelola keuangan.',
        profilePictureUrl: '',
        isOnline: false,
        skills: [
          'Budgeting',
          'Investment',
          'Financial Planning',
          'Debt Management',
        ],
      ),
      Mentor(
        id: 'sample_mentor_3',
        name: 'Rendi Pratama',
        title: 'Corporate Trainer',
        bio:
            'Corporate Trainer & Life Coach yang berpengalaman 8 tahun mengembangkan soft skills profesional.',
        profilePictureUrl: '',
        isOnline: true,
        skills: [
          'Communication',
          'Leadership',
          'Public Speaking',
          'Team Management',
        ],
      ),
      Mentor(
        id: 'sample_mentor_4',
        name: 'Dewi Lestari',
        title: 'Psychologist',
        bio:
            'Psikolog klinis yang membantu mengatasi stress kerja dan masalah mental health di workplace.',
        profilePictureUrl: '',
        isOnline: true,
        skills: [
          'Mental Health',
          'Stress Management',
          'Work-Life Balance',
          'Counseling',
        ],
      ),
      Mentor(
        id: 'sample_mentor_5',
        name: 'Agus Rahman',
        title: 'Senior Software Engineer',
        bio:
            'Senior developer dengan 12+ tahun pengalaman. Mentor untuk junior developer dan fresh graduate IT.',
        profilePictureUrl: '',
        isOnline: false,
        skills: ['Coding', 'Tech Career', 'System Design', 'Code Review'],
      ),
    ];
  }

  // Method untuk create sample data ke Firebase (optional)
  Future<void> createSampleData() async {
    try {
      // Check if collections are empty
      final forumsSnapshot = await _firestore
          .collection('forums')
          .limit(1)
          .get();
      final mentorsSnapshot = await _firestore
          .collection('mentors')
          .limit(1)
          .get();

      // Create sample questions if collection is empty
      if (forumsSnapshot.docs.isEmpty) {
        final sampleQuestions = _getSampleQuestions();
        for (final question in sampleQuestions) {
          await _firestore.collection('forums').add({
            'title': question.title,
            'content': question.content,
            'authorName': question.authorName,
            'isAnonymous': question.isAnonymous,
            'replyCount': question.replyCount,
            'tags': [],
            'createdAt': question.createdAt,
          });
        }
        print('Sample questions created successfully');
      }

      // Create sample mentors if collection is empty
      if (mentorsSnapshot.docs.isEmpty) {
        final sampleMentors = _getSampleMentors();
        for (final mentor in sampleMentors) {
          await _firestore.collection('mentors').add({
            'name': mentor.name,
            'title': mentor.title,
            'bio': mentor.bio,
            'profilePictureUrl': mentor.profilePictureUrl,
            'isOnline': mentor.isOnline,
            'skills': mentor.skills,
          });
        }
        print('Sample mentors created successfully');
      }
    } catch (e) {
      print('Error creating sample data: $e');
    }
  }

  Future<void> addForum(String title, String content, bool isAnonymous) async {
    try {
      final CollectionReference forumCollection = _firestore.collection(
        'forums',
      );
      await forumCollection.add({
        'title': title,
        'content': content,
        'isAnonymous': isAnonymous,
        'authorName': "Budi",
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Forum question added successfully');
    } catch (e) {
      print('Error adding forum question: $e');
      throw Exception('Failed to add forum question');
    }
  }
}
