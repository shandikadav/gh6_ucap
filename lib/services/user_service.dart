import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final String userId;

  UserService(this.userId);

  Future insertUserData(String name, String role, String createdAt) async {
    final CollectionReference userCollection = FirebaseFirestore.instance
        .collection('users');

    try {
      await userCollection.doc(userId).set({
        'name': name,
        'email': role,
        'createdAt': createdAt,
      });
      print('User data inserted successfully');
    } catch (e) {
      print('Error inserting user data: $e');
    }
  }
}
