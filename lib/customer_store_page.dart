import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_store_controller.dart'; // Ensure this path matches where your controller is located

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
  bool _isLoading = true;
  bool _isFavourite = false;
  bool _isLoadingFavoriteStatus = true;

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
      setState(() {
        _storeDetails = details;
        _storeReviews = reviews;
        _isLoading = false;
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
                            Text('Hawker name: ${_storeDetails!['Hawker name']}', style: TextStyle(fontSize: 16)),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Reviews:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _storeReviews.length,
                        itemBuilder: (context, index) {
                          final review = _storeReviews[index];
                          return ListTile(
                            title: Text(review['customer_username'], style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(review['review']),
                            trailing: Text('${review['ratings']} ⭐'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
