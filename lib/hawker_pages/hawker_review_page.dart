import 'package:flutter/material.dart';
import 'package:swe_2006_app_hawker/hawker_controllers/hawker_review_controller.dart';
import 'package:swe_2006_app_hawker/hawker_pages/Hawker_home_page.dart';
import 'package:swe_2006_app_hawker/hawker_pages/hawker_setting_page.dart';

class HawkerReviewPage extends StatefulWidget {
  final String username; // Username of the hawker

  const HawkerReviewPage({Key? key, required this.username}) : super(key: key);

  @override
  _HawkerReviewPageState createState() => _HawkerReviewPageState();
}

class _HawkerReviewPageState extends State<HawkerReviewPage> {
  final HawkerReviewController _controller = HawkerReviewController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: FutureBuilder<String>(
        future: _controller.getStallName(widget.username),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching stall name"));
          } else if (snapshot.hasData) {
            return _buildReviewList(snapshot.data!); // Pass the stall name to the next FutureBuilder
          } else {
            return Center(child: Text("Stall not found"));
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 238, 234, 237),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(icon: Icon(Icons.home, color: Colors.red), onPressed: () {Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HawkerHomePage(username: widget.username)));}),
            IconButton(icon: Icon(Icons.reviews, color: Colors.red), onPressed: (){}),
            IconButton(icon: Icon(Icons.settings, color: Colors.red), onPressed: () {Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HawkerSettingPage(username: widget.username)));}),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList(String storeName) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _controller.getStoreReview(storeName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error fetching reviews"));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var review = snapshot.data![index];
              return ListTile(
                title: Text(review['customer_username'] ?? 'Anonymous'),
                subtitle: Text(review['review']),
                trailing: Text("${review['ratings'] ?? 'No Rating'} \u2B50"),
              );
            },
          );
        } else {
          return Center(child: Text("No reviews found"));
        }
      },
    );
  }
}
