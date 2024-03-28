import 'package:flutter/material.dart';
import 'package:swe_2006_app_hawker/customer_favourite_page.dart';
import 'package:swe_2006_app_hawker/customer_order_page.dart';
import 'package:swe_2006_app_hawker/customer_settings_page.dart';
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

  @override
  void initState() {
    super.initState();
    fetchHawkerCentresAndReviews();
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

  Widget _buildReviewItem(BuildContext context, Map<String, dynamic> hawkerCenter) {
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
  @override
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, ${widget.username}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Reviews for Hawker Centres',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 120.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hawkerCenterReviews.length,
              itemBuilder: (context, index) {
                return _buildReviewItem(context, hawkerCenterReviews[index]);
              },
            ),
          ),
        ],
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
}



