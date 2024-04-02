import 'package:cloud_firestore/cloud_firestore.dart';

class FavouritePageController {
  final String username;

  FavouritePageController({required this.username});
  
  Future<void> removeFavoriteByName(String favoriteName) async {
  try {
    // Query for the favorite based on username and favourite name
    var querySnapshot = await FirebaseFirestore.instance
        .collection('Favourites')
        .where('username', isEqualTo: username)
        .where('favourite', isEqualTo: favoriteName)
        .get();

    // If the document exists, delete it
    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('Favourites')
            .doc(doc.id)
            .delete();
      }
      print("Favorite removed successfully.");
    } else {
      print("No matching favorite found.");
    }
  } catch (e) {
    print("Error removing favorite: $e");
  }
}

  Future<List<String>> fetchFavorites() async {
  List<String> favoritesList = [];
  
  try {
    var favoritesSnapshot = await FirebaseFirestore.instance
        .collection('Favourites')
        .where('username', isEqualTo: username)
        .get();
    
    favoritesList = favoritesSnapshot.docs
        .map((doc) => doc.data()['favourite'].toString())
        .toList();
  } catch (e) {
    print("Error fetching favorites: $e");
  }

  return favoritesList;
}
}