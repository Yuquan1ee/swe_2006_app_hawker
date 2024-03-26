import 'package:flutter/material.dart';
import 'package:swe_2006_app_hawker/customer_favourite_page.dart';
import 'package:swe_2006_app_hawker/customer_order_page.dart';
import 'customer_settings_page.dart';
import 'login_page.dart';

class CustomerHomePage extends StatefulWidget {
  final String username;

  const CustomerHomePage({Key? key, required this.username}) : super(key: key);

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _filterOption = 'byname'; // Default filter option

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
            PopupMenuButton<String>(
              onSelected: (String value) {
                setState(() {
                  _filterOption = value;
                  // Add your filtering logic here based on the _filterOption
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'byname',
                  child: Text('By Name'),
                ),
                const PopupMenuItem<String>(
                  value: 'bylocation',
                  child: Text('By Location'),
                ),
                const PopupMenuItem<String>(
                  value: 'byreview',
                  child: Text('By Review'),
                ),
              ],
              icon: Icon(Icons.filter_list),
              tooltip: 'Filter',
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, ${widget.username}!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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


