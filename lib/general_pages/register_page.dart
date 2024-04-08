import 'package:flutter/material.dart';
import 'package:swe_2006_app_hawker/general_controllers/register_controller.dart';

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
  final TextEditingController _cuisineController = TextEditingController();
  final TextEditingController _openingHoursController = TextEditingController();
  final TextEditingController _pricingController = TextEditingController();
  String? _userType; // Variable to hold the user's selected type
  final List<String> _userTypes = ['Hawker', 'Customer']; // Example user types
  String? _selectedPricing; // To hold the selected pricing level


  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _stallNameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _cuisineController.dispose();
    _openingHoursController.dispose();
    _pricingController.dispose();
    super.dispose();
  }


  Future<void> _registerUser() async {
  String username = _usernameController.text;
  String password = _passwordController.text;
  String confirmPassword = _confirmPasswordController.text;
  String email = _emailController.text;
  String? userType = _userType;

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

  RegisterController _registerController = RegisterController();
  bool userCreationSuccess = await _registerController.createNewUser(
    username: username,
    password: password,
    email: email,
    usertype: userType.toLowerCase(),
  );

  if (!userCreationSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User registration failed')),
    );
    return;
  }

  // Handle hawker-specific registration
  if (userType == 'Hawker') {
    String cuisine = _cuisineController.text;
    String stallName = _stallNameController.text;
    String location = _locationController.text;
    String openingHours = _openingHoursController.text;

    if (_selectedPricing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid pricing value')),
      );
      return;
    }

    bool stallAndMenuSuccess = await _registerController.createstallandmenu(
      cuisine,
      username,
      stallName,
      location,
      openingHours,
      int.tryParse(_selectedPricing ?? '') ?? 0 // Providing a default value of 0
    );

    if (!stallAndMenuSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create stall and menu')),
      );
      return;
    }
  }

  // If everything is successful
  Navigator.pop(context);
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
            // Add the new fields here
            TextFormField(
              controller: _cuisineController,
              decoration: const InputDecoration(labelText: 'Cuisine (e.g., Japanese, Western, Local)'),
            ),
            TextFormField(
              controller: _openingHoursController,
              decoration: const InputDecoration(labelText: 'Opening Hours (e.g., 0900-2100)'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedPricing,
              hint: const Text('Select Pricing Level'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPricing = newValue;
                });
              },
              items: ['1', '2', '3', '4', '5'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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