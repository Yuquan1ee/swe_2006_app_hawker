import 'package:flutter/material.dart';
import 'package:swe_2006_app_hawker/customer_order_page.dart';
import 'customer_home_page.dart'; // Adjust import as needed
import 'customer_settings_page.dart'; // Adjust import as needed
import 'package:swe_2006_app_hawker/customer_favourite_controller.dart';
// Assuming CustomerFavoritePage is another placeholder you mentioned
// import 'some_orders_page.dart'; // Placeholder - Replace with actual imports

class CustomerFavoritePage extends StatefulWidget {
  final String username;
  const CustomerFavoritePage({Key? key, required this.username}) : super(key: key);

  @override
  _CustomerFavoritePageState createState() => _CustomerFavoritePageState();
}

class _CustomerFavoritePageState extends State<CustomerFavoritePage> {
  // Assuming there might be a list to display the user's favorite items
  List<String> _favorites = []; // Initialize as empty
  late FavouritePageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FavouritePageController(username: widget.username);
    _fetchAndSetFavorites();
  }

  void _fetchAndSetFavorites() async {
    var favorites = await _controller.fetchFavorites();
    setState(() {
      _favorites = favorites;
    });
  }

  void _removeFavorite(String favoriteName) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Remove Favorite'),
        content: Text('Are you sure you want to remove $favoriteName from your favorites?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Dismiss the dialog
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Dismiss the dialog
              await _controller.removeFavoriteByName(favoriteName); // Adjust based on your method's name
              _fetchAndSetFavorites(); // Refresh the favorites list
            },
            child: Text('Remove'),
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Favorites'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _favorites.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_favorites[index]),
              // Example of a trailing icon to represent some action on the favorite item
              trailing: Icon(Icons.delete, color: Colors.red),
              onTap: () => _removeFavorite(_favorites[index]),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 238, 234, 237),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(icon: Icon(Icons.home, color: Colors.blue), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerHomePage(username: widget.username)))),
            IconButton(icon: Icon(Icons.reorder, color: Colors.blue), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerOrderPage(username: widget.username)))),
            IconButton(icon: Icon(Icons.favorite, color: Colors.blue), onPressed: () {}), // this is already the favourite page
            IconButton(icon: Icon(Icons.settings, color: Colors.blue), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerSettingsPage(username: widget.username)))),
          ],
        ),
      ),
    );
  }
}
