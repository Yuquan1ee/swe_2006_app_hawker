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


  Future<List<Map<String, dynamic>>> getMyStoreReview(String storeName, String username) async {
  // Attempt to query the collection for documents where 'Hawker name' matches storeName and 'username' matches the provided username
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reviews') // Use the actual collection name for reviews
        .where('Hawker name', isEqualTo: storeName) // Query condition to match the hawker stall name
        .where('customer_username', isEqualTo: username) // Additional query condition to match the user's username
        .get();

    // Check if the query returned any documents
    if (querySnapshot.docs.isNotEmpty) {
      // Convert the QuerySnapshot into a List of Maps. Each map represents a review.
      List<Map<String, dynamic>> myReview = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return myReview;
    } else {
      // If no matching documents are found, return an empty list
      // or handle this scenario differently depending on your application needs.
      return [];
    }
  }


  Future<void> deleteReviewByUserNameAndStore(String storeName, String username) async {
    final collection = FirebaseFirestore.instance.collection('reviews');
    try {
      // Query to find the review document by storeName and username
      final querySnapshot = await collection
          .where('Hawker name', isEqualTo: storeName)
          .where('customer_username', isEqualTo: username)
          .get();

      // Check if the query returned any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Assuming a user can only leave one review per store,
        // there should only be one document to delete.
        await collection.doc(querySnapshot.docs.first.id).delete();
        // Handle post-deletion logic here, e.g., showing a success message
        print("Review deleted successfully.");
      } else {
        print("No matching review found to delete.");
      }
    } catch (e) {
      // Handle any errors that occur during deletion
      print("Error deleting review: $e");
    }
  }


  Future<void> addReview(String username, String storeName, String review, int rating) async {
    final collection = FirebaseFirestore.instance.collection('reviews');

    try {
      // Create a new document in the 'reviews' collection
      await collection.add({
        'customer_username': username,
        'Hawker name': storeName,
        'review': review,
        'ratings': rating,
      });

      // Handle post-addition logic here, e.g., showing a success message
      print("Review added successfully.");
    } catch (e) {
      // Handle any errors that occur during the addition
      print("Error adding review: $e");
    }
  }


  Future<void> editMyReview(String storeName, String username, String newReviewText, int newRating) async {
    final collection = FirebaseFirestore.instance.collection('reviews');
    
    try {
      // Query to find the review document by storeName and username
      final querySnapshot = await collection
          .where('Hawker name', isEqualTo: storeName)
          .where('customer_username', isEqualTo: username)
          .get();

      // Check if the query returned any documents (reviews)
      if (querySnapshot.docs.isNotEmpty) {
        // Assuming a user can only leave one review per store,
        // there should only be one document to update.
        final docId = querySnapshot.docs.first.id;

        // Update the review with new text and rating
        await collection.doc(docId).update({
          'review': newReviewText,
          'ratings': newRating,
        });

        print("Review updated successfully.");
      } else {
        print("No matching review found to update.");
      }
    } catch (e) {
      // Handle any errors that occur during the update
      print("Error updating review: $e");
    }
  }


  Future<List<Map<String, dynamic>>> fetchStoreMenu(String storeName) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      // Step 1: Query the 'menu' collection to find the document where 'Hawker name' matches 'storeName'
      QuerySnapshot hawkerQuery = await db.collection('menu')
          .where('Hawker Name', isEqualTo: storeName)
          .get();

      // Check if any documents were found
      if (hawkerQuery.docs.isEmpty) {
        print('No hawker found with the given name matching the store name.');
        return [];
      }

      // Assuming the first document found is the correct one (assuming unique names)
      DocumentSnapshot hawkerDoc = hawkerQuery.docs.first;

      // Step 2: Access the subcollection named after the storeName within the found document to retrieve the menu
      QuerySnapshot menuSnapshot = await db.collection('menu')
          .doc(hawkerDoc.id)
          .collection(storeName)
          .get();

      // Convert the QuerySnapshot to a list of Map<String, dynamic> representing menu items
      List<Map<String, dynamic>> menuItems = menuSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      return menuItems;
    } catch (e) {
      print('Error fetching store menu: $e');
      return [];
    }
  }




}
