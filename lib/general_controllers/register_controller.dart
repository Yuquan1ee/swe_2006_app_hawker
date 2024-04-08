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





  Future<bool> createstallandmenu( String Cuisine, String Hawkerid, String Stallname, String Location, String Openinghours, int Pricing) async{
    try {
      // Check if user already exists based on email or username
      final QuerySnapshot existingUsersByhawkerid = await _firestore
          .collection('hawker_stall')
          .where('Hawker UserID', isEqualTo: Hawkerid)
          .limit(1)
          .get();

      final QuerySnapshot existingUsersBystallid = await _firestore
          .collection('hawker_stall')
          .where('Hawker name', isEqualTo: Stallname)
          .limit(1)
          .get();

      if (existingUsersBystallid.docs.isNotEmpty || existingUsersByhawkerid.docs.isNotEmpty) {
        // User already exists, return false
        return false;
      }

      // Insert new user credentials into Firestore
      await _firestore.collection('hawker_stall').add({
        'Cuisine': Cuisine,
        'Hawker UserID': Hawkerid,
        'Hawker name': Stallname, // Reminder: Store hashed and salted password, not plaintext
        'Location': Location,
        'Opening hours': Openinghours,
        'Pricing': Pricing
      });
      await _firestore.collection("menu").add({
        'Hawker Name': Stallname,
        'Hawker UserID': Hawkerid,
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