import 'package:cloud_firestore/cloud_firestore.dart';

class HawkerReviewController {
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
 
  Future<String> getStallName(String username) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('hawker_stall') // Use the actual collection name
        .where('Hawker UserID', isEqualTo: username) // Query condition
        .get();

    // Check if the query found any documents
    if (querySnapshot.docs.isNotEmpty) {
      // Safely access the 'Hawker name' field with a null check
      var docData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      return docData['Hawker name'] ?? 'Stall name not found'; // Provide a default value in case it's null
    } else {
      // Return a default value or handle the case where no stall is found
      return 'Stall name not found';
    }
  }

}