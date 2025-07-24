import 'package:firebase_auth/firebase_auth.dart';
import 'package:gh6_ucap/services/user_service.dart';

class AuthService {
  Future signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    required String createdAt,
  }) async {
    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final updateData = await UserService(
        result.user!.uid,
      ).insertUserData(name, email, createdAt);
      print('result : $result');
      print('update data : $updateData');
      print('uid user : ${result.user!.uid}');
      return result;
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = "The Password provided is too weak";
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email';
      }
    }
  }
}
