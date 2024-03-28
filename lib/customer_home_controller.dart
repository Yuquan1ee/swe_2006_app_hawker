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

}
