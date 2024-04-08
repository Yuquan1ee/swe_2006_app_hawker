import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerHomePageController {
  static const String _apiKey = 'AIzaSyAvP9Eg9PSWtHDssjC4SAMnjvmfCoMqkAA'; // Consider securing this

  CustomerHomePageController();

  Future<Map<String, dynamic>> getGooglePlaceReviews(String placeId) async {
    final String endpointUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
    final Map<String, String> params = {
      'place_id': placeId,
      'key': _apiKey,
      'fields': 'name,rating,reviews',
    };

    final uri = Uri.parse(endpointUrl).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> placeDetails = json.decode(response.body);
      if (placeDetails['status'] == 'OK') {
        final placeInfo = placeDetails['result'];
        List<Map<String, dynamic>> reviews = placeInfo['reviews']?.map<Map<String, dynamic>>((review) {
          return {
            'author_name': review['author_name'],
            'rating': review['rating'],
            'text': review['text'],
          };
        })?.toList() ?? [];

        return {
          'name': placeInfo['name'],
          'rating': placeInfo['rating'].toString(),
          'reviews': reviews,
        };
      } else {
        throw Exception('Failed to get place details. Status: ${placeDetails['status']}');
      }
    } else {
      throw Exception('Failed to make the request to the API. Status code: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getHawkerCentrePlaceIds() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('hawker_centre')
        .get();

    return querySnapshot.docs
        .map((doc) {
          // Safely access data, ensuring we always work with a non-null Map
          var data = doc.data() as Map<String, dynamic>? ?? {};
          // Check if 'place id' exists in the document data
          if (data.containsKey('place id')) {
            return {'placeId': data['place id']};
          }
          return null;
        })
        .where((item) => item != null) // Remove nulls that were added by documents without a 'place id'
        .cast<Map<String, dynamic>>() // Cast back to a non-nullable Map list
        .toList();
  }
  

  Future<List<Map<String, dynamic>>> getAllReviews() async {
  // Fetch the 'reviews' collection from Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .get();

    // Map each document to a Map<String, dynamic>, representing its data
    return querySnapshot.docs
        .map((doc) {
          // Safely access data, ensuring we always work with a non-null Map
          return doc.data() as Map<String, dynamic>? ?? {};
        })
        .toList(); // Convert the result to a List<Map<String, dynamic>>
  }

  Future<List<Map<String, dynamic>>> getAllstores() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('hawker_stall')
        .get();

    // Map each document to a Map<String, dynamic>, representing its data
    return querySnapshot.docs
        .map((doc) {
          // Safely access data, ensuring we always work with a non-null Map
          return doc.data() as Map<String, dynamic>? ?? {};
        })
        .toList(); // Convert the result to a List<Map<String, dynamic>>
  }
  Future<List<Map<String, dynamic>>> filterStoreByReview() async {
  // Step 1: Fetch all reviews
    List<Map<String, dynamic>> allReviews = await getAllReviews();

    // Step 2: Group reviews by store name
    Map<String, List<double>> storeRatings = {};
    for (var review in allReviews) {
      // Ensure the review has both a name and a rating
      if (review.containsKey('Hawker name') && review.containsKey('ratings')) {
        final storeName = review['Hawker name'];
        final rating = double.tryParse(review['ratings'].toString()) ?? 0;

        storeRatings.putIfAbsent(storeName, () => []).add(rating);
      }
    }

    // Step 3: Calculate the average rating for each store
    List<Map<String, dynamic>> storesWithAverageRatings = storeRatings.entries.map((entry) {
      final averageRating = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return {
        'Hawker name': entry.key,
        'Average rating': averageRating,
      };
    }).toList();

    // Step 4: Sort the stores by their average rating in descending order and take the top 5
    storesWithAverageRatings.sort((a, b) => b['Average rating'].compareTo(a['Average rating']));
    List<Map<String, dynamic>> topStores = storesWithAverageRatings.take(5).toList();

    // Step 5: Return the top 5 stores
    return topStores;
  }
  Future<List<Map<String, dynamic>>> getAllCuisine() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('List_of_Cuisine')
        .get();

    // Map each document to a Map<String, dynamic>, representing its data
    return querySnapshot.docs
        .map((doc) {
          // Safely access data, ensuring we always work with a non-null Map
          return doc.data() as Map<String, dynamic>? ?? {};
        })
        .toList(); // Convert the result to a List<Map<String, dynamic>>
  }
  
  Future<List<Map<String, dynamic>>> filterStoreByCuisine(String cuisine) async {
  // Step 1: Fetch all stores
    List<Map<String, dynamic>> allStores = await getAllstores();

    // Step 2: Initialize an empty list to store filtered stores
    List<Map<String, dynamic>> filteredStores = [];

    // Step 3: Loop through all stores and filter by cuisine
    for (var store in allStores) {
      // Assuming each store has a 'Cuisine' field and it's a String
      // Adjust this check if 'Cuisine' is structured differently (e.g., a list)
      if (store['Cuisine'] != null && store['Cuisine'] == cuisine) {
        filteredStores.add(store);
      }
    }

    // Step 4: Return the filtered list of stores
    return filteredStores;
  }


}





