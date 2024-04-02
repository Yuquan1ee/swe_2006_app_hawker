import 'package:flutter/material.dart';
import 'package:swe_2006_app_hawker/customer_favourite_page.dart';
import 'package:swe_2006_app_hawker/customer_order_page.dart';
import 'package:swe_2006_app_hawker/customer_settings_page.dart';
import 'package:swe_2006_app_hawker/customer_store_page.dart';
import 'package:swe_2006_app_hawker/login_page.dart';
import 'customer_home_controller.dart'; // Make sure to import your controller

class CustomerHomePage extends StatefulWidget {
  final String username;

  const CustomerHomePage({Key? key, required this.username}) : super(key: key);

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> hawkerCenterReviews = [];
  CustomerHomePageController _controller = CustomerHomePageController();

  List<Map<String, dynamic>> topReviewedStores = [];
  List<Map<String, dynamic>> filteredStores = [];
  List<Map<String, dynamic>> listOfCuisines = [];

  @override
  void initState() {
    super.initState();
    fetchHawkerCentresAndReviews();
    fetchTopReviewedStores();
    fetchAllCuisines(); // Fetch all cuisines
  }

  Future<void> fetchAllCuisines() async {
    try {
      listOfCuisines = await _controller.getAllCuisine();
      setState(() {});
    } catch (e) {
      print("Error fetching cuisines: $e");
    }
  }
  Future<void> fetchStoresByCuisine(String cuisine) async {
  // This method replaces the direct call to _controller.filterStoreByCuisine in the onTap of cuisineListView
    filteredStores = await _controller.filterStoreByCuisine(cuisine);
    setState(() {});
  }

  Future<void> fetchTopReviewedStores() async {
    try {
      List<Map<String, dynamic>> stores = await _controller.filterStoreByReview();
      setState(() {
        topReviewedStores = stores;
      });
    } catch (e) {
      print("Error fetching top reviewed stores: $e");
    }
  }

  Future<void> fetchHawkerCentresAndReviews() async {
    List<Map<String, dynamic>> hawkerCentres = await _controller.getHawkerCentrePlaceIds();
    List<Map<String, dynamic>> reviewsDataList = [];

    for (var hawkerCentre in hawkerCentres) {
      String placeId = hawkerCentre['placeId'];
      Map<String, dynamic> reviewsData = await _controller.getGooglePlaceReviews(placeId);
      if (reviewsData.isNotEmpty) {
        reviewsDataList.add({
          'name': reviewsData['name'], // Ensure this matches the key returned by your API
          "rating" : reviewsData["rating"],
          'reviews': reviewsData['reviews'], // Adjust according to your data structure
        });
      }
    }

    setState(() {
      hawkerCenterReviews = reviewsDataList;
    });
  }
  Widget _filteredStoresListView() {
    return Container(
      height: 120.0, // Set a fixed height for the horizontal list
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal, // Make the list scroll horizontally
        itemCount: filteredStores.length,
        itemBuilder: (context, index) {
          final store = filteredStores[index];
          return GestureDetector( // Use GestureDetector for tap interaction
            onTap: () {
              // Assuming CustomerStorePage is the correct destination and it accepts a username and storeName
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CustomerStorePage(
                  username: widget.username, 
                  storeName: store["Hawker name"],
                ),
              ));
            },
            child: Container(
              width: 200.0, // Specify a fixed width for each item
              child: Card(
                elevation: 4.0, // Optional: adds shadow for a more button-like feel
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          store['Hawker name'], // Assuming 'Hawker name' is a key in your store Map
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        "Cuisine: ${store['Cuisine']}", // Adjust based on your data structure
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget cuisineListView(List<Map<String, dynamic>> cuisines) {
    return Container(
      height: 120.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cuisines.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              fetchStoresByCuisine(cuisines[index]['name']);
            },
            child: Container(
              width: 200.0,
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: Card(
                child: Center(
                  child: Text(
                    cuisines[index]['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildhawkercentreReviewItem(BuildContext context, Map<String, dynamic> hawkerCenter) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hawkerCenter['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: (hawkerCenter['reviews'] as List).length,
                      itemBuilder: (BuildContext context, int index) {
                        var review = hawkerCenter['reviews'][index];
                        return ListTile(
                          title: Text('${review['author_name']} (${review['rating']} ⭐)'),
                          subtitle: Text(review['text']),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _controller.addToFavorites(hawkerCenter['name'], widget.username).then((_) {
                        Navigator.pop(context); // Close the modal after adding
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${hawkerCenter['name']} added to favorites")),
                        );
                      });
                    },
                    child: Text('Add to Favorites'),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        width: 200.0,
        child: Card(
          child: ListTile(
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${hawkerCenter['name']} ',
                    style: TextStyle(
                      color: Colors.black, // Specify the color to ensure it matches ListTile's title style
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '(${hawkerCenter["rating"]} ⭐ )', // Assuming rating is a string
                    style: TextStyle(
                      color: Colors.grey[600], // You can adjust the color as needed
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Text("Tap to see reviews"),
          ),
        ),
      )

    );
  }
  Widget topReviewByStore_ListView(List<Map<String, dynamic>> topReviewedStores) {
    return Container(
      height: 120.0,
      margin: EdgeInsets.only(top: 8.0), // Add some space above the list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topReviewedStores.length,
        itemBuilder: (context, index) {
          var store = topReviewedStores[index];
          return Container(
            width: 200.0, // Specify a fixed width for each card
            child: Card(
              elevation: 4.0, // Add some shadow for better visibility
              child: InkWell(
                onTap: () {
                  // Optionally, implement onTap action, such as showing details about the store
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        store['Hawker name'], // Assuming 'Hawker name' holds the name of the store
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      "Rating: ${store['Average rating'].toStringAsFixed(1)}", // Assuming 'Average rating' holds the rating value
                      style: TextStyle(fontSize: 14.0),
                    ),
                    // You can add more details or a list of reviews here
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.filter_list),
              tooltip: 'Filter',
              onPressed: () {
                // Implement filter logic
              },
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()), // Update with your LoginPage path
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Use SingleChildScrollView to avoid overflow when the content is too long
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Welcome, ${widget.username}!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            sectionTitle('Reviews for Hawker Centres'),
            hawkercentre_reviewsListView(hawkerCenterReviews),
            sectionTitle('Top picks by Reviews'),
            topReviewByStore_ListView(topReviewedStores),
            sectionTitle('Cuisine'),
            cuisineListView(listOfCuisines),
            if (filteredStores.isNotEmpty) ...[
              sectionTitle('Selected Cuisine Stores'),
              _filteredStoresListView(), // Display filtered stores here
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Pricing-specific reviews will go here'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 238, 234, 237),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(icon: Icon(Icons.home, color: Colors.blue), onPressed: () {}),
            IconButton(icon: Icon(Icons.reorder, color: Colors.blue), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerOrderPage(username: widget.username)))),
            IconButton(icon: Icon(Icons.favorite, color: Colors.blue), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerFavoritePage(username: widget.username)))),
            IconButton(icon: Icon(Icons.settings, color: Colors.blue), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerSettingsPage(username: widget.username)))),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );

  Widget hawkercentre_reviewsListView(List<Map<String, dynamic>> reviews) {
    // Here you would build your ListView.builder to display the hawker center reviews
    // For demonstration, returning a placeholder widget
    return Container(
      height: 120.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          return _buildhawkercentreReviewItem(context, reviews[index]);
        },
      ),
    );
  }


}