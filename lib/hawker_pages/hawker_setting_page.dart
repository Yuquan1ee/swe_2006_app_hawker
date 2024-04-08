import 'package:flutter/material.dart';
import 'package:swe_2006_app_hawker/general_controllers/setting_controller.dart';
import 'package:swe_2006_app_hawker/hawker_pages/hawker_home_page.dart'; // Adjust the path as needed
import 'package:swe_2006_app_hawker/hawker_pages/hawker_review_page.dart'; // Adjust the path as needed

class HawkerSettingPage extends StatefulWidget {
  final String username;
  
  const HawkerSettingPage({Key? key, required this.username}) : super(key: key);

  @override
  _HawkerSettingPageState createState() => _HawkerSettingPageState();
}

class _HawkerSettingPageState extends State<HawkerSettingPage> {
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

  void _showChangeUsernameModal() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return _buildModalContent(
            controller: _usernameController,
            label: 'New Username',
            hint: 'Enter your new username',
            onPressed: _updateUsername,
          );
        });
  }

  void _showChangeEmailModal() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return _buildModalContent(
            controller: _emailController,
            label: 'New Email',
            hint: 'Enter your new email',
            onPressed: _updateEmail,
          );
        });
  }

  void _showChangePasswordModal() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return _buildModalContent(
            controller: _passwordController,
            label: 'New Password',
            hint: 'Enter your new password',
            onPressed: _updatePassword,
          );
        });
  }

  void _updateUsername() async {
    SettingController _settingsController = SettingController();
    final success = await _settingsController.changeUsername(widget.username, _usernameController.text);
    if (success) {
      _showFeedback("Username successfully updated.");
      // Replace the current page with a new CustomerSettingsPage instance that has the updated username
      Navigator.pop(context); // Close the modal if update was not successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HawkerSettingPage(username: _usernameController.text)),
      );
    } else {
      Navigator.pop(context); // Close the modal if update was not successful
      _showFeedback("Failed to update username.");
    }
  }

  void _updateEmail() async {
    SettingController _settingsController = SettingController();
    final success = await _settingsController.changeEmail(widget.username, _emailController.text);
    Navigator.pop(context); // Close the modal
    _showFeedback(success ? "Email successfully updated." : "Failed to update email.");
  }

  void _updatePassword() async {
    SettingController _settingsController = SettingController();
    final success = await _settingsController.changePassword(widget.username, _passwordController.text);
    Navigator.pop(context); // Close the modal
    _showFeedback(success ? "Password successfully updated." : "Failed to update password.");
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  Widget _buildModalContent({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        children: <Widget>[
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onPressed,
            child: const Text('Confirm'),
          ),
          ElevatedButton(
              onPressed: () => Navigator.pop(context), // Dismiss the modal sheet
              child: const Text('Cancel'),
            ),

        ],
      ),
    );
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
              onPressed: _showChangeUsernameModal,
              child: const Text('Change Username'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showChangeEmailModal,
              child: const Text('Change Email'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showChangePasswordModal,
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
            IconButton(icon: Icon(Icons.home, color: Colors.red), onPressed: () {Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HawkerHomePage(username: widget.username)));}),
            IconButton(icon: Icon(Icons.reviews, color: Colors.red), onPressed: (){Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HawkerReviewPage(username: widget.username)));}),
            IconButton(icon: Icon(Icons.settings, color: Colors.red), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
