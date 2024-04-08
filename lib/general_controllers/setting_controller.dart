import 'package:cloud_firestore/cloud_firestore.dart';

class SettingController {              //contains 3 functions: changePassword(String username, String newPassword), change Username (String oldUsername, String newUsername), changeemail(String, username, String newemail)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> changePassword(String username, String newPassword) async {
    try {
      // Fetch the document ID for the user with the given username
      final QuerySnapshot userQuery = await _firestore
          .collection('user_credential')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        // No user found with this username
        return false;
      }

      // Assuming usernames are unique, there should only be one document
      final String userId = userQuery.docs.first.id;

      // Update the password in the user's document
      // IMPORTANT: In a real application, ensure newPassword is hashed and salted
      await _firestore.collection('user_credential').doc(userId).update({
        'password': newPassword, // Placeholder for hashed password
      });

      return true; // Password change successful
    } catch (e) {
      print('Error changing password: $e');
      return false; // Password change failed
    }
  }
   Future<bool> changeUsername(String oldUsername, String newUsername) async {
    try {
      // Check if the new username already exists
      final QuerySnapshot newUserQuery = await _firestore
          .collection('user_credential')
          .where('username', isEqualTo: newUsername)
          .limit(1)
          .get();

      if (newUserQuery.docs.isNotEmpty) {
        // New username already exists
        return false;
      }

      // Fetch the document ID for the user with the old username
      final QuerySnapshot userQuery = await _firestore
          .collection('user_credential')
          .where('username', isEqualTo: oldUsername)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        // No user found with the old username
        return false;
      }

      // Assuming usernames are unique, there should only be one document
      final String userId = userQuery.docs.first.id;

      // Update the username in the user's document
      await _firestore.collection('user_credential').doc(userId).update({
        'username': newUsername,
      });

      return true; // Username change successful
    } catch (e) {
      print('Error changing username: $e');
      return false; // Username change failed
    }
  }

  Future<bool> changeEmail(String username, String newEmail) async {
    try {
      // Check if the new email already exists
      final QuerySnapshot newEmailQuery = await _firestore
          .collection('user_credential')
          .where('email', isEqualTo: newEmail)
          .limit(1)
          .get();

      if (newEmailQuery.docs.isNotEmpty) {
        // New email already exists
        return false;
      }

      // Fetch the document ID for the user with the given username
      final QuerySnapshot userQuery = await _firestore
          .collection('user_credential')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        // No user found with this username
        return false;
      }

      // Assuming usernames are unique, there should only be one document
      final String userId = userQuery.docs.first.id;

      // Update the email in the user's document
      await _firestore.collection('user_credential').doc(userId).update({
        'email': newEmail,
      });

      return true; // Email change successful
    } catch (e) {
      print('Error changing email: $e');
      return false; // Email change failed
    }
  }

}