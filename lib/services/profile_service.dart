import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Merge with default values if fields don't exist
        return {
          'uid': user.uid,
          'email': user.email ?? '',
          'fullname': userData['fullname'] ?? 'User',
          'exp': userData['exp'] ?? 0,
          'level': _calculateLevel(userData['exp'] ?? 0),
          'nextLevelExp': _calculateNextLevelExp(userData['exp'] ?? 0),
          'currentLevelExp': _calculateCurrentLevelExp(userData['exp'] ?? 0),
          'createdAt': userData['createdAt'] ?? '',
          'lastLogin': userData['lastLogin'] ?? '',
          'profileImageUrl': userData['profileImageUrl'] ?? '',

          // Stats (with defaults)
          'totalScenarios': userData['totalScenarios'] ?? 0,
          'totalArticles': userData['totalArticles'] ?? 0,
          'forumPosts': userData['forumPosts'] ?? 0,
          'streakDays': userData['streakDays'] ?? 1,

          // Daily quests
          'dailyQuests': userData['dailyQuests'] ?? _getDefaultDailyQuests(),
          'lastQuestReset':
              userData['lastQuestReset'] ?? DateTime.now().toString(),

          // Achievements
          'achievements': userData['achievements'] ?? _getDefaultAchievements(),
        };
      } else {
        // Create default user data if doesn't exist
        final defaultData = {
          'uid': user.uid,
          'email': user.email ?? '',
          'fullname': user.displayName ?? 'User',
          'exp': 0,
          'createdAt': DateTime.now().toString(),
          'lastLogin': DateTime.now().toString(),
          'profileImageUrl': '',
          'totalScenarios': 0,
          'totalArticles': 0,
          'forumPosts': 0,
          'streakDays': 1,
          'dailyQuests': _getDefaultDailyQuests(),
          'lastQuestReset': DateTime.now().toString(),
          'achievements': _getDefaultAchievements(),
        };

        await _firestore.collection('users').doc(user.uid).set(defaultData);

        return {
          ...defaultData,
          'level': 1,
          'nextLevelExp': 1000,
          'currentLevelExp': 0,
        };
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return _getSampleUserData();
    }
  }

  // Update user experience points
  Future<void> updateUserExp(int expGained) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(user.uid);
        final userDoc = await transaction.get(userRef);

        if (userDoc.exists) {
          final currentExp = userDoc.data()?['exp'] ?? 0;
          final newExp = currentExp + expGained;

          transaction.update(userRef, {
            'exp': newExp,
            'lastLogin': DateTime.now().toString(),
          });
        }
      });
    } catch (e) {
      print('Error updating user exp: $e');
    }
  }

  // Complete daily quest
  Future<void> completeQuest(int questIndex, int expGained) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(user.uid);
        final userDoc = await transaction.get(userRef);

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final currentExp = userData['exp'] ?? 0;
          final dailyQuests = Map<String, dynamic>.from(
            userData['dailyQuests'] ?? _getDefaultDailyQuests(),
          );

          // Check if quest should be reset (new day)
          final lastReset =
              DateTime.tryParse(userData['lastQuestReset'] ?? '') ??
              DateTime.now();
          final now = DateTime.now();
          final shouldReset = now.difference(lastReset).inDays >= 1;

          // if (shouldReset) {
          //   dailyQuests = _getDefaultDailyQuests();
          // }

          // Mark quest as completed
          dailyQuests['quest${questIndex}Completed'] = true;

          // Update stats based on quest type
          Map<String, dynamic> updateData = {
            'exp': currentExp + expGained,
            'dailyQuests': dailyQuests,
            'lastQuestReset': shouldReset
                ? now.toString()
                : userData['lastQuestReset'],
            'lastLogin': now.toString(),
          };

          // Update specific stats based on quest
          switch (questIndex) {
            case 1: // Read article
              updateData['totalArticles'] =
                  (userData['totalArticles'] ?? 0) + 1;
              break;
            case 2: // Forum participation
              updateData['forumPosts'] = (userData['forumPosts'] ?? 0) + 1;
              break;
            case 3: // Complete scenario
              updateData['totalScenarios'] =
                  (userData['totalScenarios'] ?? 0) + 1;
              break;
          }

          transaction.update(userRef, updateData);
        }
      });
    } catch (e) {
      print('Error completing quest: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? fullname,
    String? profileImageUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      Map<String, dynamic> updateData = {
        'lastLogin': DateTime.now().toString(),
      };

      if (fullname != null) updateData['fullname'] = fullname;
      if (profileImageUrl != null)
        updateData['profileImageUrl'] = profileImageUrl;

      await _firestore.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Failed to sign out');
    }
  }

  // Helper methods
  int _calculateLevel(int exp) {
    if (exp < 1000) return 1;
    return (exp / 1000).floor() + 1;
  }

  int _calculateNextLevelExp(int exp) {
    final level = _calculateLevel(exp);
    return level * 1000;
  }

  int _calculateCurrentLevelExp(int exp) {
    final level = _calculateLevel(exp);
    return exp - ((level - 1) * 1000);
  }

  Map<String, dynamic> _getDefaultDailyQuests() {
    return {
      'quest1Completed': false,
      'quest2Completed': false,
      'quest3Completed': false,
    };
  }

  Map<String, dynamic> _getDefaultAchievements() {
    return {
      'jobHunter': false,
      'budgetPro': false,
      'socialButterfly': false,
      'stressMaster': false,
      'articleMaster': false,
      'discussionKing': false,
    };
  }

  // Sample data for fallback
  Map<String, dynamic> _getSampleUserData() {
    return {
      'uid': 'sample_user',
      'email': 'user@example.com',
      'fullname': 'Andi Pratama',
      'exp': 750,
      'level': 5,
      'nextLevelExp': 1000,
      'currentLevelExp': 750,
      'createdAt': DateTime.now().toString(),
      'lastLogin': DateTime.now().toString(),
      'profileImageUrl': '',
      'totalScenarios': 23,
      'totalArticles': 47,
      'forumPosts': 12,
      'streakDays': 7,
      'dailyQuests': {
        'quest1Completed': false,
        'quest2Completed': true,
        'quest3Completed': false,
      },
      'lastQuestReset': DateTime.now().toString(),
      'achievements': {
        'jobHunter': true,
        'budgetPro': true,
        'socialButterfly': false,
        'stressMaster': false,
        'articleMaster': false,
        'discussionKing': false,
      },
    };
  }
}
