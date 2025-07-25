import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_preferences.dart'; // Import UserPreferences

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user profile with local fallback
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Coba ambil dari Firestore terlebih dahulu
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final userData = doc.data()!;
        // ✅ Update SharedPreferences dengan data terbaru
        await UserPreferences.saveUserData(userData);
        return userData;
      } else {
        // Fallback ke SharedPreferences
        return await UserPreferences.getUserData();
      }
    } catch (e) {
      print('Error getting user profile: $e');
      // Fallback ke SharedPreferences jika ada error
      return await UserPreferences.getUserData();
    }
  }

  // Complete quest with local update
  Future<void> completeQuest(int questIndex, int expGained) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userRef = _firestore.collection('users').doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) return;

        final userData = snapshot.data()!;
        final dailyQuests =
            userData['dailyQuests'] as Map<String, dynamic>? ?? {};

        // Update quest completion
        String questKey = 'quest${questIndex}Completed';
        if (dailyQuests[questKey] == true) return; // Already completed

        Map<String, dynamic> updateData = {'dailyQuests.$questKey': true};

        // Add EXP and level calculation
        int currentExp = userData['currentLevelExp'] ?? 0;
        int newExp = currentExp + expGained;
        int level = userData['level'] ?? 1;
        int nextLevelExp = userData['nextLevelExp'] ?? 250;

        if (newExp >= nextLevelExp) {
          level++;
          newExp = newExp - nextLevelExp;
          nextLevelExp = _calculateNextLevelExp(level);
        }

        updateData.addAll({
          'currentLevelExp': newExp,
          'level': level,
          'nextLevelExp': nextLevelExp,
        });

        // Update specific quest stats
        switch (questIndex) {
          case 1: // Read article
            updateData['totalArticles'] = (userData['totalArticles'] ?? 0) + 1;
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

        // ✅ Update SharedPreferences
        final updatedUserData = Map<String, dynamic>.from(userData);
        updateData.forEach((key, value) {
          if (key.contains('.')) {
            // Handle nested keys like 'dailyQuests.quest1Completed'
            final keys = key.split('.');
            if (keys.length == 2) {
              updatedUserData[keys[0]][keys[1]] = value;
            }
          } else {
            updatedUserData[key] = value;
          }
        });

        await UserPreferences.saveUserData(updatedUserData);
      });
    } catch (e) {
      print('Error completing quest: $e');
    }
  }

  // Update forum activity (call this when user posts to forum)
  Future<void> updateForumActivity() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userRef = _firestore.collection('users').doc(user.uid);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = snapshot.data()!;
        final currentPosts = userData['forumPosts'] ?? 0;

        final updateData = {
          'forumPosts': currentPosts + 1,
          'lastActivity': DateTime.now().toString(),
        };

        await userRef.update(updateData);

        // ✅ Update SharedPreferences
        final updatedUserData = Map<String, dynamic>.from(userData);
        updatedUserData.addAll(updateData);
        await UserPreferences.saveUserData(updatedUserData);
      }
    } catch (e) {
      print('Error updating forum activity: $e');
    }
  }

  // Calculate next level EXP requirement
  int _calculateNextLevelExp(int level) {
    return 250 + (level - 1) * 50; // Increases by 50 each level
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

      // ✅ Update SharedPreferences
      final currentUserData = await UserPreferences.getUserData();
      if (currentUserData != null) {
        currentUserData.addAll(updateData);
        await UserPreferences.saveUserData(currentUserData);
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
  }
}
