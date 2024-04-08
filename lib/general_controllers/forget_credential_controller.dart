import 'package:cloud_firestore/cloud_firestore.dart';

class ForgetCredentialsController {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Example data source function; replace with your actual data retrieval method
  Future<List<Map<String, dynamic>>> getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user_credential') // Replace with your collection name
        .get();
    
    // Convert the query snapshot into a list of maps
    List<Map<String, dynamic>> documents = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    return documents;
  }

  Future<bool> verifyUser(String username, String email) async {
    List<Map<String, dynamic>> data = await getData();
    for (var user in data) {
      if ((user['username'] == username && user['email'] == email)) {
        return true;
      }
    }
    return false;
  }

  Future<bool> resetpassword(String username, String newPassword) async {
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


}

