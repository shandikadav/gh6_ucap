import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_preferences.dart'; // Import UserPreferences

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '1065339553754-sejn30l56gnbtrn90l3g595lanij1vmg.apps.googleusercontent.com',
  );

  // Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String fullname,
    required String createdAt,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Data user lengkap
      final userData = {
        'uid': userCredential.user!.uid,
        'email': email,
        'fullname': fullname,
        'exp': 0,
        'level': 1,
        'currentLevelExp': 0,
        'nextLevelExp': 250,
        'createdAt': createdAt,
        'lastLogin': DateTime.now().toString(),
        'totalScenarios': 0,
        'totalArticles': 0,
        'forumPosts': 0,
        'streakDays': 1,
        'dailyQuests': {
          'quest1Completed': false,
          'quest2Completed': false,
          'quest3Completed': false,
        },
        'lastQuestReset': DateTime.now().toString(),
        'achievements': {
          'jobHunter': false,
          'budgetPro': false,
          'socialButterfly': false,
          'stressMaster': false,
          'articleMaster': false,
          'discussionKing': false,
        },
        'theme': 'light',
        'notifications': {
          'questReminders': true,
          'achievementAlerts': true,
          'weeklyReports': true,
        },
        'onboardingCompleted': false,
        'firstTimeUser': true,
      };

      // Simpan ke Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      // ✅ Simpan ke SharedPreferences
      await UserPreferences.saveUserData(userData);

      print('User created and saved successfully');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error creating user: $e';
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google sign-in aborted';
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user == null) {
        throw 'User is null after Google sign-in';
      }

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      Map<String, dynamic> userData;

      if (!userDoc.exists) {
        userData = {
          'uid': user.uid,
          'email': user.email,
          'fullname': user.displayName ?? '',
          'exp': 0,
          'level': 1,
          'currentLevelExp': 0,
          'nextLevelExp': 250,
          'createdAt': DateTime.now().toString(),
          'lastLogin': DateTime.now().toString(),
          'totalScenarios': 0,
          'totalArticles': 0,
          'forumPosts': 0,
          'streakDays': 1,
          'dailyQuests': {
            'quest1Completed': false,
            'quest2Completed': false,
            'quest3Completed': false,
          },
          'lastQuestReset': DateTime.now().toString(),
          'achievements': {
            'jobHunter': false,
            'budgetPro': false,
            'socialButterfly': false,
            'stressMaster': false,
            'articleMaster': false,
            'discussionKing': false,
          },
          'theme': 'light',
          'notifications': {
            'questReminders': true,
            'achievementAlerts': true,
            'weeklyReports': true,
          },
          'onboardingCompleted': false,
          'firstTimeUser': true,
        };
        await _firestore.collection('users').doc(user.uid).set(userData);
      } else {
        userData = userDoc.data() as Map<String, dynamic>;
        userData['lastLogin'] = DateTime.now().toString();
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': DateTime.now().toString(),
        });
      }

      // ✅ Simpan ke SharedPreferences
      await UserPreferences.saveUserData(userData);

      print("Google sign-in successful");
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      print('Error signing in with Google: $e');
    }
    return null;
  }

  // Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ Ambil data user dari Firestore dan simpan ke SharedPreferences
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        userData['lastLogin'] = DateTime.now().toString();

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'lastLogin': DateTime.now().toString()});

        await UserPreferences.saveUserData(userData);
      }

      print('User signed in successfully');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error signing in: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      // ✅ Clear SharedPreferences
      await UserPreferences.clearUserData();
      print('User signed out successfully');
    } catch (e) {
      throw 'Error signing out: $e';
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
