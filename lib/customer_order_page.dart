import 'package:flutter/material.dart';
import 'customer_home_page.dart'; // Adjust this import as needed
import 'customer_favourite_page.dart'; // Adjust this import as needed
import 'customer_settings_page.dart'; // Adjust this import as needed

class CustomerOrderPage extends StatefulWidget {
  final String username;
  const CustomerOrderPage({Key? key, required this.username}) : super(key: key);

  @override
  _CustomerOrderPageState createState() => _CustomerOrderPageState();
}

class _CustomerOrderPageState extends State<CustomerOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: Center(
        child: Text('Customer orders content goes here'),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 238, 234, 237),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(icon: Icon(Icons.home, color: Colors.blue), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerHomePage(username: widget.username)))),
            IconButton(icon: Icon(Icons.reorder, color: Colors.blue), onPressed: () {}), // This is already the order page
            IconButton(icon: Icon(Icons.favorite, color: Colors.blue), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerFavoritePage(username: widget.username)))),
            IconButton(icon: Icon(Icons.settings, color: Colors.blue), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerSettingsPage(username: widget.username)))),
          ],
        ),
      ),
    );
  }
}