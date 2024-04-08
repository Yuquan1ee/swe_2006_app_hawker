import 'package:flutter/material.dart';
import 'package:swe_2006_app_hawker/general_pages/login_page.dart';
import 'package:swe_2006_app_hawker/hawker_controllers/Hawker_home_controller.dart';
import 'package:swe_2006_app_hawker/hawker_pages/hawker_review_page.dart';
import 'package:swe_2006_app_hawker/hawker_pages/hawker_setting_page.dart';

class HawkerHomePage extends StatefulWidget {
  final String username;

  const HawkerHomePage({Key? key, required this.username}) : super(key: key);

  @override
  _HawkerHomePageState createState() => _HawkerHomePageState();
}

class _HawkerHomePageState extends State<HawkerHomePage> {
  late String stallName = '';
  Map<String, dynamic> storeDetails = {};
  List<Map<String, dynamic>> menuItems = []; // Added for menu items
  final _controller = HawkerHomeController();

  @override
  void initState() {
    super.initState();
    fetchStallAndStoreDetails();
  }

  void _editStoreDetails() {
  final _locationController = TextEditingController(text: storeDetails['Location']);
  final _openingHoursController = TextEditingController(text: storeDetails['Opening hours']);
  final _cuisineController = TextEditingController(text: storeDetails['Cuisine']);
  final _pricingController = TextEditingController(text: storeDetails['Pricing'].toString());

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Store Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: _openingHoursController,
                decoration: InputDecoration(labelText: 'Opening Hours'),
              ),
              TextField(
                controller: _cuisineController,
                decoration: InputDecoration(labelText: 'Cuisine'),
              ),
              TextField(
                controller: _pricingController,
                decoration: InputDecoration(labelText: 'Pricing'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Attempt to update store details
              bool success = await _controller.changeStoreDetails(
                storeName: stallName,
                newLocation: _locationController.text,
                newOpeningHours: _openingHoursController.text,
                newCuisine: _cuisineController.text,
                newPricing: int.tryParse(_pricingController.text),
              );

              if (success) {
                // Update local state to reflect changes
                fetchStallAndStoreDetails(); // Refresh store details after successful update
                Navigator.pop(context); // Close the dialog
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update store details')));
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}

  void fetchStallAndStoreDetails() async {
    String name = await _controller.getStallName(widget.username);
    setState(() => stallName = name);

    Map<String, dynamic> details = await _controller.getStoreDetails(name);
    setState(() {
      storeDetails = details;
      fetchMenu();
    });
  }

  void fetchMenu() async {
    List<Map<String, dynamic>> fetchedMenuItems = await _controller.fetchStoreMenu(stallName);
    setState(() => menuItems = fetchedMenuItems);
  }

  void _addOrEditMenuItem({Map<String, dynamic>? item}) {
  // Keep the name controller but make it non-editable if item is not null (editing mode)
    final _nameController = TextEditingController(text: item?['Name'] ?? '');
    final _descController = TextEditingController(text: item?['Description'] ?? '');
    final _priceController = TextEditingController(text: item?['Price']?.toString() ?? '');

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(item == null ? 'Add Menu Item' : 'Edit Menu Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  // Make the name field read-only if we're editing an existing item
                  readOnly: item != null,
                ),
                TextField(controller: _descController, decoration: InputDecoration(labelText: 'Description')),
                TextField(controller: _priceController, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    // Add or edit menu item
                    if (item == null) {
                      await _controller.addToMenu(stallName, _nameController.text, _descController.text, double.parse(_priceController.text));
                    } else {
                      await _controller.editMenuItem(stallName, item['Name'], _descController.text, double.parse(_priceController.text));
                    }
                    fetchMenu();
                    Navigator.pop(context);
                  },
                  child: Text('Save'))
            ],
          );
        });
  }


  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Welcome, ${widget.username}'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
          },
        ),
      ],
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Stall Name: $stallName', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20.0),
                      onPressed: _editStoreDetails,
                      tooltip: 'Edit Store Details',
                    ),
                  ],
                ),
                if (storeDetails.isNotEmpty) ...[
                  Text('Cuisine: ${storeDetails["Cuisine"]}'),
                  Text('Location: ${storeDetails["Location"]}'),
                  Text('Opening Hours: ${storeDetails["Opening hours"]}'),
                  Text('Pricing: ${storeDetails["Pricing"]}'),
                ],
                SizedBox(height: 20), // Added for spacing
                Text('Menu:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...menuItems.map((menuItem) => ListTile(
                      title: Text(menuItem['Name']),
                      subtitle: Text(menuItem['Description']),
                      trailing: Wrap(
                        children: [
                          Text('\$${menuItem['Price'].toStringAsFixed(2)}'),
                          IconButton(icon: Icon(Icons.edit), onPressed: () => _addOrEditMenuItem(item: menuItem)),
                          IconButton(icon: Icon(Icons.delete), onPressed: () async {
                            await _controller.deleteMenuItem(stallName, menuItem['Name']);
                            fetchMenu();
                          }),
                        ],
                      ),
                    )).toList(),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Add Menu Item'),
                  onPressed: () => _addOrEditMenuItem(),
                )
              ],
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: BottomAppBar(
      color: Color.fromARGB(255, 238, 234, 237),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(icon: Icon(Icons.home, color: Colors.red), onPressed: () {}),
          IconButton(icon: Icon(Icons.reviews, color: Colors.red), onPressed: (){Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HawkerReviewPage(username: widget.username)));}),
          IconButton(icon: Icon(Icons.settings, color: Colors.red), onPressed: () {Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HawkerSettingPage(username: widget.username)));}),
        ],
      ),
    ),
  );
}


}
