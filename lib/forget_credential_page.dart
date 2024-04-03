import 'package:flutter/material.dart';
import "forget_credential_controller.dart";

class ForgetCredentialsPage extends StatefulWidget {
  @override
  _ForgetCredentialsPageState createState() => _ForgetCredentialsPageState();
}

class _ForgetCredentialsPageState extends State<ForgetCredentialsPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  final ForgetCredentialsController _controller = ForgetCredentialsController();


  bool _isVerified = false; // Indicates whether the user has been verified

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _verifyUser() async {
    bool verified = await _controller.verifyUser(_usernameController.text, _emailController.text);
    setState(() {
      _isVerified = verified;
    });
    if (!verified) {
      // Show an error if verification fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verification failed. Please check your credentials.")));
    }
  }
  void _resetFormAndState() {
    _emailController.clear();
    _usernameController.clear();
    _newPasswordController.clear();
    setState(() {
      _isVerified = false; // Reset verification state
    });
  }


  void _submitNewPassword() async {
    if (_isVerified) {
      bool success = await _controller.resetpassword(_usernameController.text, _newPasswordController.text);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password successfully updated.")));
        // Optionally, navigate away or reset the page state
        _resetFormAndState();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update password.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not verified.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forget Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (!_isVerified) ...[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email', hintText: 'Enter your email'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username', hintText: 'Enter your username'),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _verifyUser, child: Text('Verify')),
            ] else ...[
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'New Password', hintText: 'Enter new password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submitNewPassword, child: Text('Reset Password')),
            ],
          ],
        ),
      ),
    );
  }
}
