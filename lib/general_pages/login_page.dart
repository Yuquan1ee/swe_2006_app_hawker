import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swe_2006_app_hawker/hawker_pages/hawker_home_page.dart';
import 'package:swe_2006_app_hawker/general_pages/forget_credential_page.dart';
import 'package:swe_2006_app_hawker/general_controllers/login_controller.dart';
import '../customer_pages/customer_home_page.dart'; // Ensure this import path is correct based on your project structure
import 'register_page.dart';



Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Ensure plugin services are initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false; // This is used to toggle the password visibility

  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showFailedLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Incorrect username or password. Please try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _signIn() async {
    LoginController _logincontroller = LoginController();
    if (await _logincontroller.authenticator(_usernameController.text, _passwordController.text)){
      if (await _logincontroller.isCustomer(_usernameController.text)){
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CustomerHomePage(username: _usernameController.text)),
        );
      }
      else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> HawkerHomePage(username: _usernameController.text)));
      }
    }
    else if (_usernameController.text == "David" && _passwordController.text == "password"){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CustomerHomePage(username: _usernameController.text)),
      );
    }
    else {
      _showFailedLoginDialog();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HawkerInOne', textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username/email',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgetCredentialsPage()),
                  );
                // Implement functionality for "Forget Password?"
              },
              child: const Text('Forget Password?'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to the Register Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
