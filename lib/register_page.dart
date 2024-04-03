import 'package:flutter/material.dart';
import 'package:swe_2006_app_hawker/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _stallNameController = TextEditingController(); // Added
  final TextEditingController _locationController = TextEditingController(); // Added
  final TextEditingController _emailController = TextEditingController();
  String? _userType; // Variable to hold the user's selected type
  final List<String> _userTypes = ['Hawker', 'Customer']; // Example user types

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _stallNameController.dispose(); // Added
    _locationController.dispose(); // Added
    super.dispose();
  }

  Future<void> _registerUser() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String email = _emailController.text;
    String? userType = _userType;

    // Basic validation for example purposes
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    if (userType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user type')),
      );
      return;
    }

    // Call the RegisterController to create a new user
    RegisterController _registerController = RegisterController();
    bool success = await _registerController.createNewUser(
      username: username,
      password: password, // Consider hashing this password before sending
      email: email,
      usertype: userType.toLowerCase(), // Ensure this matches your backend expectations ('hawker' or 'customer')
    );

    if (success) {
      Navigator.pop(context); // Navigate back upon successful registration
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed')),
      );
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView( // Added to ensure the view scrolls when fields overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "email"),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            DropdownButtonFormField<String>(
              value: _userType,
              hint: const Text('Select User Type'),
              onChanged: (String? newValue) {
                setState(() {
                  _userType = newValue;
                });
              },
              items: _userTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // Conditionally display additional fields for Hawker
            if (_userType == 'Hawker') ...[
              TextFormField(
                controller: _stallNameController,
                decoration: const InputDecoration(labelText: 'Stall Name'),
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerUser, // Update this line
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}