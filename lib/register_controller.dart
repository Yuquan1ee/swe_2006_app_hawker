import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> createNewUser({
    required String username, 
    required String password, 
    required String email, 
    required String usertype,
  }) async {
    try {
      // Check if user already exists based on email or username
      final QuerySnapshot existingUsersByEmail = await _firestore
          .collection('user_credential')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      final QuerySnapshot existingUsersByUsername = await _firestore
          .collection('user_credential')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (existingUsersByEmail.docs.isNotEmpty || existingUsersByUsername.docs.isNotEmpty) {
        // User already exists, return false
        return false;
      }

      // Insert new user credentials into Firestore
      await _firestore.collection('user_credential').add({
        'username': username,
        'email': email,
        'password': password, // Reminder: Store hashed and salted password, not plaintext
        'usertype': usertype,
      });

      // User was successfully created, return true
      return true;
    } catch (e) {
      // An error occurred, return false
      print(e.toString()); // Consider removing or replacing with a logging mechanism in production
      return false;
    }
  }
}