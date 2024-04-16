import 'package:flutter/material.dart';
import 'package:swe_2006_app_hawker/general_controllers/setting_controller.dart';
import 'customer_home_page.dart'; // Ensure this import path is correct
import 'customer_favourite_page.dart';
import 'customer_order_page.dart';

class CustomerSettingsPage extends StatefulWidget {
  final String username;
  const CustomerSettingsPage({Key? key, required this.username}) : super(key: key);

  @override
  _CustomerSettingsPageState createState() => _CustomerSettingsPageState();
}

class _CustomerSettingsPageState extends State<CustomerSettingsPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showChangeUsernameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Username'),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'New Username',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateUsername();
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showChangeEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Email'),
          content: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'New Email',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateEmail();
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updatePassword();
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _updateUsername() async {
    SettingController _settingsController = SettingController();
    final success = await _settingsController.changeUsername(widget.username, _usernameController.text);
    if (success) {
      _showFeedback("Username successfully updated.");
      // Replace the current page with a new CustomerSettingsPage instance that has the updated username
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CustomerSettingsPage(username: _usernameController.text)),
      );
    } else {
      _showFeedback("Failed to update username.");
    }
  }

  void _updateEmail() async {
    SettingController _settingsController = SettingController();
    final success = await _settingsController.changeEmail(widget.username, _emailController.text);
    _showFeedback(success ? "Email successfully updated." : "Failed to update email.");
  }

  void _updatePassword() async {
    SettingController _settingsController = SettingController();
    final success = await _settingsController.changePassword(widget.username, _passwordController.text);
    _showFeedback(success ? "Password successfully updated." : "Failed to update password.");
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: _showChangeUsernameDialog,
              child: const Text('Change Username'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showChangeEmailDialog,
              child: const Text('Change Email'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showChangePasswordDialog,
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 238, 234, 237),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(icon: Icon(Icons.home, color: Colors.blue), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerHomePage(username: widget.username)))),
            IconButton(icon: Icon(Icons.favorite, color: Colors.blue), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerFavoritePage(username: widget.username)))),
            IconButton(icon: Icon(Icons.settings, color: Colors.blue), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
