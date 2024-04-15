import 'package:flutter/material.dart';
import 'package:swe_2006_app_hawker/customer_pages/customer_store_page.dart';
import 'customer_home_page.dart';
import 'customer_settings_page.dart';
import 'package:swe_2006_app_hawker/customer_controllers/customer_favourite_controller.dart';

class CustomerFavoritePage extends StatefulWidget {
  final String username;
  const CustomerFavoritePage({Key? key, required this.username}) : super(key: key);

  @override
  _CustomerFavoritePageState createState() => _CustomerFavoritePageState();
}

class _CustomerFavoritePageState extends State<CustomerFavoritePage> {
  List<String> _favorites = [];
  late FavouritePageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FavouritePageController();
    _fetchAndSetFavorites();
  }

  void _fetchAndSetFavorites() async {
    var favorites = await _controller.fetchFavorites(widget.username);
    setState(() {
      _favorites = favorites;
    });
  }

  Widget _buildFavoriteItem(String favoriteName) {
    return ListTile(
      title: Text(favoriteName),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () => _removeFavorite(favoriteName),
      ),
      onTap: () {
        // Assuming CustomerStorePage exists and takes a storeName and username
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => CustomerStorePage(username: widget.username, storeName: favoriteName),
        ));
      },
    );
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog
                await _controller.removeFavoriteByName(widget.username, favoriteName);
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
        child: _favorites.isEmpty
            ? Center(
                child: Text(
                  'No favorited hawker stall yet.',
                  style: TextStyle(fontSize: 18.0),
                ),
              )
            : ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  return _buildFavoriteItem(_favorites[index]);
                },
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 238, 234, 237),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.home, color: Colors.blue),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerHomePage(username: widget.username)))),
            IconButton(icon: Icon(Icons.favorite, color: Colors.blue), onPressed: () {}),
            IconButton(
                icon: Icon(Icons.settings, color: Colors.blue),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerSettingsPage(username: widget.username)))),
          ],
        ),
      ),
    );
  }
}
