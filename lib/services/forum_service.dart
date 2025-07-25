import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_preferences.dart';
import 'profile_service.dart';

class ForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfileService _profileService = ProfileService();

  // Get current user data from SharedPreferences
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    return await UserPreferences.getUserData();
  }

  // Add reply dengan user data yang tepat
  Future<void> addReply({
    required String questionId,
    required String content,
    required bool isAnonymous,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      // ✅ Ambil data user dari SharedPreferences
      final userData = await UserPreferences.getUserData();
      final userName = userData?['fullname'] ?? 'User';
      final userId = userData?['uid'] ?? user.uid;

      await _firestore
          .collection('forums')
          .doc(questionId)
          .collection('replies')
          .add({
            'content': content,
            'authorId': userId,
            'authorName': isAnonymous ? 'Anonim' : userName,
            'isAnonymous': isAnonymous,
            'isEdited': false,
            'likes': 0,
            'likedBy': [],
            'createdAt': FieldValue.serverTimestamp(),
          });

      // ✅ Update forum activity
      await _profileService.updateForumActivity();

      // Update reply count in the question document
      await _firestore.collection('forums').doc(questionId).update({
        'replyCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error adding reply: $e');
      throw 'Failed to add reply';
    }
  }

  // Get replies stream
  Stream<List<ForumReply>> getReplies(String questionId) {
    return _firestore
        .collection('forums')
        .doc(questionId)
        .collection('replies')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ForumReply.fromFirestore(doc))
              .toList(),
        );
  }

  // Toggle reply like
  Future<void> toggleReplyLike(String questionId, String replyId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      final replyRef = _firestore
          .collection('forums')
          .doc(questionId)
          .collection('replies')
          .doc(replyId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(replyRef);
        if (!snapshot.exists) throw 'Reply not found';

        final data = snapshot.data()!;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        final currentLikes = data['likes'] ?? 0;

        if (likedBy.contains(user.uid)) {
          // Unlike
          likedBy.remove(user.uid);
          transaction.update(replyRef, {
            'likedBy': likedBy,
            'likes': currentLikes - 1,
          });
        } else {
          // Like
          likedBy.add(user.uid);
          transaction.update(replyRef, {
            'likedBy': likedBy,
            'likes': currentLikes + 1,
          });
        }
      });
    } catch (e) {
      print('Error toggling like: $e');
      throw 'Failed to toggle like';
    }
  }
}

// ForumReply model
class ForumReply {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final bool isAnonymous;
  final bool isEdited;
  final int likes;
  final List<String> likedBy;
  final Timestamp createdAt;

  ForumReply({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.isAnonymous,
    required this.isEdited,
    required this.likes,
    required this.likedBy,
    required this.createdAt,
  });

  factory ForumReply.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ForumReply(
      id: doc.id,
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonim',
      isAnonymous: data['isAnonymous'] ?? false,
      isEdited: data['isEdited'] ?? false,
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
