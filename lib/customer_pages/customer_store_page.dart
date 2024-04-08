import 'package:flutter/material.dart';
import '../customer_controllers/customer_store_controller.dart'; // Ensure this path matches where your controller is located

class CustomerStorePage extends StatefulWidget {
  final String username;
  final String storeName;

  const CustomerStorePage({
    Key? key,
    required this.username,
    required this.storeName,
  }) : super(key: key);

  @override
  _CustomerStorePageState createState() => _CustomerStorePageState();
}

class _CustomerStorePageState extends State<CustomerStorePage> {
  final CustomerStoreController _controller = CustomerStoreController();

  Map<String, dynamic>? _storeDetails;
  List<Map<String, dynamic>> _storeReviews = [];
  List<Map<String,dynamic>> _mystoreReviews =[];
  bool _isLoading = true;
  bool _isFavourite = false;
  bool _isLoadingFavoriteStatus = true;   
  bool _showMyReview = false; // Added to toggle between all reviews and my review
  bool _isLoadingMenu = true;
  List<Map<String, dynamic>> _menuItems = [];


  @override
  void initState() {
    super.initState();
    _fetchStoreData();
    _checkFavoriteStatus();
  }
  
  Future<void> _fetchStoreData() async {
    try {
      final details = await _controller.getStoreDetails(widget.storeName);
      final reviews = await _controller.getStoreReview(widget.storeName);
      final myreviews = await _controller.getMyStoreReview(widget.storeName, widget.username);
      final menuitems = await _controller.fetchStoreMenu(widget.storeName);
      setState(() {
        _storeDetails = details;
        _storeReviews = reviews;
        _mystoreReviews = myreviews;
        _menuItems = menuitems;
        _isLoading = false;
        _isLoadingMenu = false;

      });
    } catch (e) {
      print("Error fetching store data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkFavoriteStatus() async {
    bool isFav = await _controller.isFavourite(widget.storeName, widget.username);
    setState(() {
      _isFavourite = isFav;
      _isLoadingFavoriteStatus = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavoriteStatus) return; // Prevent toggling while loading status

    setState(() {
      _isLoadingFavoriteStatus = true; // Indicate loading during operation
    });

    if (_isFavourite) {
      await _controller.removeFromFavorites(widget.storeName, widget.username);
    } else {
      await _controller.addToFavorites(widget.storeName, widget.username);
    }

    // Re-check favorite status after toggling
    _checkFavoriteStatus();
  }

  // Placeholder methods for review actions
  Future<void> _addReview() async {
  // First, check if the user already has a review for this store
    final userReviews = await _controller.getMyStoreReview(widget.storeName, widget.username);
    
    if (userReviews.isNotEmpty) {
      // User already has a review, show a dialog informing them
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Review Exists'),
            content: Text('You have already reviewed this store.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    } else {
      // User hasn't reviewed this store, proceed to show the add review dialog
      String reviewText = '';
      int rating = 0; // Adjust based on your rating scale

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Write a Review'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    reviewText = value;
                  },
                  decoration: InputDecoration(hintText: "Review Text"),
                ),
                TextField(
                  onChanged: (value) {
                    rating = int.tryParse(value) ?? 0;
                  },
                  decoration: InputDecoration(hintText: "Rating (e.g., 5)"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Submit'),
                onPressed: () async {
                  // Call the controller's addReview method
                  await _controller.addReview(widget.username, widget.storeName, reviewText, rating);

                  // Close the dialog
                  Navigator.of(context).pop();

                  // Refresh the data
                  await _fetchStoreData();
                },
              ),
            ],
          );
        },
      );
    }
  }



  Future<void> _editReview() async {
  // Assuming the user has only one review per store, and it's the first in _mystoreReviews
    if (_mystoreReviews.isEmpty) {
      print("No review found to edit.");
      return;
    }
    
    // Extracting the current review and rating
    final currentReview = _mystoreReviews.first['review'] as String;
    final currentRating = _mystoreReviews.first['ratings'] as int;

    // Temporary variables to hold the edited review text and rating
    String editedReviewText = currentReview;
    int editedRating = currentRating;

    // Show dialog to edit review text and rating
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Your Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: TextEditingController()..text = currentReview,
                onChanged: (value) {
                  editedReviewText = value;
                },
                decoration: InputDecoration(hintText: "Review Text"),
              ),
              TextField(
                controller: TextEditingController()..text = currentRating.toString(),
                onChanged: (value) {
                  editedRating = int.tryParse(value) ?? currentRating; // Keep current rating if parse fails
                },
                decoration: InputDecoration(hintText: "Rating (e.g., 5)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save Changes'),
              onPressed: () async {
                // Assuming editMyReview is implemented in your controller
                await _controller.editMyReview(
                  widget.storeName, 
                  widget.username, 
                  editedReviewText, 
                  editedRating
                );

                // Close the dialog
                Navigator.of(context).pop();

                // Refresh the data to reflect the edit
                await _fetchStoreData();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReview() async {
  // Assuming the username and storeName are available via widget.username and widget.storeName
    await _controller.deleteReviewByUserNameAndStore(widget.storeName, widget.username);

    // After deleting the review, fetch the reviews again to update the UI
    await _fetchStoreData(); // This method already updates both _storeReviews and _mystoreReviews
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Loading...' : _storeDetails?['Hawker name'] ?? "Store"),
        actions: <Widget>[
          _isLoadingFavoriteStatus
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
              : IconButton(
                  icon: Icon(_isFavourite ? Icons.favorite : Icons.favorite_border),
                  color: _isFavourite ? Colors.red : Colors.blue,
                  onPressed: _toggleFavorite,
                ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _storeDetails == null
              ? Center(child: Text("Store not found"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Location: ${_storeDetails!['Location']}', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                            Text('Opening Hours: ${_storeDetails!['Opening hours']}', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                            Text('Cuisine: ${_storeDetails!['Cuisine']}', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                            Text('Pricing: ${_storeDetails!['Pricing']}', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      Divider(),
                      ToggleButtons(
                        children: <Widget>[
                          Padding(padding: const EdgeInsets.all(8), child: Text('All Reviews')),
                          Padding(padding: const EdgeInsets.all(8), child: Text('My Review')),
                        ],
                        isSelected: [_showMyReview == false, _showMyReview],
                        onPressed: (int index) {
                          setState(() {
                            _showMyReview = index == 1;
                          });
                        },
                      ),
                      _showMyReview ? _buildMyReviewSection() : _buildAllReviewsSection(),
                      Divider(), // Optionally add a visual separation
                      _buildMenuSection(), // Add the menu section here
                    ],
                  ),
                ),
    );
  }

  Widget _buildMenuSection() {
    if (_isLoadingMenu) {
      return Center(child: CircularProgressIndicator());
    } else if (_menuItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("No menu items found", style: TextStyle(fontSize: 16)),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Menu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(), // to disable ListView's own scrolling
            shrinkWrap: true, // necessary for ListView inside Column/ScrollView
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final menuItem = _menuItems[index];
              return ListTile(
                title: Text(menuItem['Name'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(menuItem['Description']),
                trailing: Text('\$${menuItem['Price']}'),
              );
            },
          ),
        ],
      );
    }
  }

  Widget _buildAllReviewsSection() {
  // Check if there are any reviews in _storeReviews
    if (_storeReviews.isEmpty) {
      // No reviews, display a message instead
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("There are no reviews for this store yet.", style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: _addReview,
            child: Text('Add Review'),
          ),
        ],
      );
    } else {
      // Reviews are present, build the list as before
      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _storeReviews.length, // Use _storeReviews for itemCount
            itemBuilder: (context, index) {
              final review = _storeReviews[index]; // Using _storeReviews
              return ListTile(
                title: Text(review['customer_username'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(review['review']),
                trailing: Text('${review['ratings']} ⭐'),
              );
            },
          ),
          ElevatedButton(
            onPressed: _addReview,
            child: Text('Add Review'),
          ),
        ],
      );
    }
  }


  Widget _buildMyReviewSection() {
  // Check if there are any reviews in _mystoreReviews
    if (_mystoreReviews.isEmpty) {
      // No reviews, display a message instead
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("You have not reviewed this store yet.", style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: _addReview, // Make sure to implement this function to handle review addition
            child: Text('Add Review'),
          ),
        ],
      );
    } else {
      // Reviews are present, build the list as before
      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _mystoreReviews.length,
            itemBuilder: (context, index) {
              final review = _mystoreReviews[index];
              return ListTile(
                title: Text(review['customer_username'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(review['review']),
                trailing: Wrap(
                  spacing: 12, // space between two icons
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editReview(), // Pass the review to be edited
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReview(), // Assuming each review has a unique 'id'
                    ),
                  ],
                ),
              );
            },
          ),
          // Hide the 'Add Review' button if a review exists
        ],
      );
    }
  }

}
