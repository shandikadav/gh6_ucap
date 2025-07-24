import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final String userId;

  UserService(this.userId);

  Future insertUserData(String fullname, String email, String createdAt) async {
    final CollectionReference userCollection = FirebaseFirestore.instance
        .collection('users');
    try {
      await userCollection.doc(userId).set({
        'fullname': fullname,
        'email': email,
        'exp': 0,
        'createdAt': createdAt,
      });
      print('User data inserted successfully');
    } catch (e) {
      print('Error inserting user data: $e');
    }
  }
}
