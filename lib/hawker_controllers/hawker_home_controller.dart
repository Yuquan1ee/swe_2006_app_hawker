import 'package:cloud_firestore/cloud_firestore.dart';

class HawkerHomeController {
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

  Future<bool> changeStoreDetails({
    required String storeName,
    String? newLocation,
    String? newOpeningHours,
    String? newCuisine,
    int? newPricing,
  }) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      // Step 1: Query the 'hawker_stall' collection to find the document where 'Hawker name' matches 'storeName'
      QuerySnapshot storeQuery = await db.collection('hawker_stall')
          .where('Hawker name', isEqualTo: storeName)
          .get();

      // Check if the store was found
      if (storeQuery.docs.isEmpty) {
        print('Store not found with the given name.');
        return false;
      }

      // Assuming the first document found is the correct one
      DocumentSnapshot storeDoc = storeQuery.docs.first;

      // Step 2: Update the document with new details
      Map<String, dynamic> updateData = {};
      if (newLocation != null) updateData['Location'] = newLocation;
      if (newOpeningHours != null) updateData['Opening hours'] = newOpeningHours;
      if (newCuisine != null) updateData['Cuisine'] = newCuisine;
      if (newPricing != null) updateData['Pricing'] = newPricing;

      // Only proceed if there's something to update
      if (updateData.isNotEmpty) {
        await db.collection('hawker_stall').doc(storeDoc.id).update(updateData);
        print('Store details updated successfully.');
        return true;
      } else {
        print('No changes provided to update the store.');
        return false;
      }
    } catch (e) {
      print('Error updating store details: $e');
      return false;
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

  Future<bool> addToMenu(String storeName, String itemName, String description, double price) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    
    try {
      QuerySnapshot storeQuery = await db.collection('menu')
          .where('Hawker Name', isEqualTo: storeName)
          .get();

      if (storeQuery.docs.isEmpty) {
        print('Store not found.');
        return false;
      }
      
      String docId = storeQuery.docs.first.id;
      
      Map<String, dynamic> menuItem = {
        'Name': itemName,
        'Description': description,
        'Price': price
      };

      await db.collection('menu').doc(docId).collection(storeName).add(menuItem);
      print('Menu item added successfully.');
      return true;
    } catch (e) {
      print('Error adding menu item: $e');
      return false;
    }
  }

 Future<bool> deleteMenuItem(String storeName, String itemName) async {
  FirebaseFirestore db = FirebaseFirestore.instance;

  try {
    // First, find the document for the given store name in the 'menu' collection.
    QuerySnapshot storeQuery = await db.collection('menu')
        .where('Hawker Name', isEqualTo: storeName)
        .get();

    if (storeQuery.docs.isEmpty) {
      print('Store not found.');
      return false;
    }
    
    // Assuming storeName is unique and correctly identifies the document.
    String docId = storeQuery.docs.first.id;

    // Find the menu item by name to get its document ID.
    QuerySnapshot menuItemQuery = await db.collection('menu').doc(docId).collection(storeName)
        .where('Name', isEqualTo: itemName)
        .get();

    if (menuItemQuery.docs.isEmpty) {
      print('Menu item not found.');
      return false;
    }

    // Assuming itemName is unique within the store's menu, get the document ID of the menu item.
    String menuItemDocId = menuItemQuery.docs.first.id;

    // Now, delete the menu item using its document ID.
    await db.collection('menu').doc(docId).collection(storeName).doc(menuItemDocId).delete();
    
    print('Menu item deleted successfully.');
    return true;
  } catch (e) {
    print('Error deleting menu item: $e');
    return false;
  }
}


  Future<bool> editMenuItem(String storeName, String itemName, String newDescription, double newPrice) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      // First, find the document for the given store name in the 'menu' collection.
      QuerySnapshot storeQuery = await db.collection('menu')
          .where('Hawker Name', isEqualTo: storeName)
          .get();

      if (storeQuery.docs.isEmpty) {
        print('Store not found.');
        return false;
      }

      // Assuming storeName is unique and correctly identifies the document.
      String docId = storeQuery.docs.first.id;

      // Find the menu item by name within the store's menu subcollection.
      QuerySnapshot menuItemQuery = await db.collection('menu').doc(docId).collection(storeName)
          .where('Name', isEqualTo: itemName)
          .get();

      if (menuItemQuery.docs.isEmpty) {
        print('Menu item not found.');
        return false;
      }

      // Assuming itemName is unique within the menu, update the found item.
      String menuItemDocId = menuItemQuery.docs.first.id;
      await db.collection('menu').doc(docId).collection(storeName).doc(menuItemDocId).update({
        'Description': newDescription,
        'Price': newPrice,
      });

      print('Menu item updated successfully.');
      return true;
    } catch (e) {
      print('Error updating menu item: $e');
      return false;
    }
  }

}

