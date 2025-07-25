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
      if (user == null) throw Exception('User not authenticated');

      print('🔄 Completing quest $questIndex for user ${user.uid}');

      // Get current user data
      final userData = await getUserProfile();
      if (userData == null) throw Exception('User profile not found');

      final dailyQuests = userData['dailyQuests'] as Map<String, dynamic>? ?? {};
      final questKey = 'quest${questIndex}Completed';
      
      if (dailyQuests[questKey] == true) {
        print('⚠️ Quest $questIndex already completed');
        return;
      }

      // Mark quest as completed
      dailyQuests[questKey] = true;

      // 🔥 GUNAKAN addExperience method yang sama
      await addExperience(expGained);

      // Update quest completion
      final updatedData = await getUserProfile(); // Get fresh data
      if (updatedData != null) {
        updatedData['dailyQuests'] = dailyQuests;
        await UserPreferences.saveUserData(updatedData);
        
        await _firestore.collection('users').doc(user.uid).update({
          'dailyQuests': dailyQuests,
        });
      }

      print('✅ Quest $questIndex completed successfully!');
    } catch (e) {
      print('❌ Error completing quest: $e');
      rethrow;
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

  Future<void> addExperience(int expAmount) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('🔄 Adding $expAmount EXP to user ${user.uid}');

      // Get current user data
      final userData = await getUserProfile();
      if (userData == null) throw Exception('User profile not found');

      final currentExp = userData['currentLevelExp'] ?? 0;
      final newExp = currentExp + expAmount;
      
      // Calculate new level
      final newLevel = _calculateLevel(newExp);
      final nextLevelExp = _calculateNextLevelExp(newLevel);

      // Update local data first
      final updatedData = Map<String, dynamic>.from(userData);
      updatedData.addAll({
        'currentLevelExp': newExp,
        'totalExp': newExp,
        'level': newLevel,
        'nextLevelExp': nextLevelExp,
        'lastActivity': DateTime.now().toString(),
      });

      // Save to SharedPreferences
      await UserPreferences.saveUserData(updatedData);

      // Save to Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'currentLevelExp': newExp,
        'totalExp': newExp,
        'level': newLevel,
        'nextLevelExp': nextLevelExp,
        'lastActivity': FieldValue.serverTimestamp(),
      });

      print('✅ EXP added successfully: $currentExp → $newExp (+$expAmount)');
      print('📊 Level: ${userData['level']} → $newLevel');
    } catch (e) {
      print('❌ Error adding experience: $e');
      rethrow;
    }
  }

    // Helper method to calculate level from EXP
  int _calculateLevel(int exp) {
    return (exp / 100).floor() + 1;
  }

}
