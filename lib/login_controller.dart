import 'package:cloud_firestore/cloud_firestore.dart';

class LoginController {

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

  Future<bool> authenticator(String username, String password) async {
    // Await the completion of getData to get the user credentials
    List<Map<String, dynamic>> data = await getData();
    for (var user in data) {
      // Check if the username and password match
      if (user['username'] == username && user['password'] == password) {
        return true;
      }
    }
    return false;
  }







}


