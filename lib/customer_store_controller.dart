import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerStoreController {
  // Function to fetch details of a hawker stall by name from Firestore
  Future<Map<String, dynamic>> getStoreDetails(String storeName) async {
    // Attempt to query the collection for a document where 'Hawker name' matches storeName
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('hawker_stall') // Replace with your actual collection name
        .where('Hawker name', isEqualTo: storeName) // Query condition
        .get();

    // Check if the query returned any documents
    if (querySnapshot.docs.isNotEmpty) {
      // Assuming we're interested in the first match
      var doc = querySnapshot.docs.first;
      return doc.data() as Map<String, dynamic>;
    } else {
      // If no matching document is found, throw an exception or handle accordingly
      throw Exception("Store not found");
    }
  }


  Future<List<Map<String, dynamic>>> getStoreReview(String storeName) async {
  // Attempt to query the collection for documents where 'Hawker name' matches storeName
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reviews') // Use the actual collection name for reviews
        .where('Hawker name', isEqualTo: storeName) // Query condition to match the hawker stall name
        .get();

    // Check if the query returned any documents
    if (querySnapshot.docs.isNotEmpty) {
      // Convert the QuerySnapshot into a List of Maps. Each map represents a review.
      List<Map<String, dynamic>> reviews = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return reviews;
    } else {
      // If no matching documents are found, you might want to return an empty list
      // or handle this scenario differently depending on your application needs.
      return [];
    }

    
  }

  Future<void> addToFavorites(String favourite, String username) async {
    try {
      // Add a new document to the 'favourites' collection
      await FirebaseFirestore.instance.collection('Favourites').add({
        'favourite': favourite,
        'username': username,
      });
      print("Added to favourites successfully.");
    } catch (e) {
      print("Error adding to favourites: $e");
    }
  }

  Future<bool> isFavourite(String favourite, String username) async {
    try {
      // Query the 'Favourites' collection for a document matching both 'favourite' and 'username'
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Favourites')
          .where('favourite', isEqualTo: favourite)
          .where('username', isEqualTo: username)
          .limit(1) // We only need to check if at least one document exists
          .get();

      // If the query returns at least one document, then the store is a favourite
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking favourites: $e");
      return false; // In case of an error, you might want to handle this differently
    }
  }


  Future<void> removeFromFavorites(String favourite, String username) async {
    try {
      // Query for the document to delete
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Favourites')
          .where('favourite', isEqualTo: favourite)
          .where('username', isEqualTo: username)
          .get();

      // If the document exists, delete it
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance.collection('Favourites').doc(doc.id).delete();
      }

      print("Removed from favourites successfully.");
    } catch (e) {
      print("Error removing from favourites: $e");
    }
  }




  
  




}
