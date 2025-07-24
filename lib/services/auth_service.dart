import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      // Create user dengan Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Simpan data user ke Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullname': fullname,
        'exp': 0,
        'createdAt': createdAt,
        'lastLogin': DateTime.now().toString(),
      });

      print('User created and saved to Firestore successfully');
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

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'fullname': user.displayName ?? '',
          'exp': 0,
          'createdAt': DateTime.now().toString(),
          'lastLogin': DateTime.now().toString(),
        });
      } else {
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': DateTime.now().toString(),
        });
      }

      print("GOOGLE BERHASIL BOSS");
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

      // Update last login di Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).update(
        {'lastLogin': DateTime.now().toString()},
      );

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

  // Handle Firebase Auth exceptions
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
