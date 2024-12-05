import 'package:flutter/material.dart';
import 'main.dart'; 
import 'opening.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}


class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  void PasswordsError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Passwords do not match. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _register(UserProvider provider) async {
    String email = _emailController.text; // todo - make backend changes to store this
    String username = _usernameController.text;
    String password = _passwordController.text;
    String firstname = _firstNameController.text;
    String lastname = _lastNameController.text;

    if (password != _confirmPassController.text) {
      PasswordsError();
      return;
    }

    final String apiUrl = 'http://127.0.0.1:8000/user/register';
    final Map<String, dynamic> registerData = {
      'username': username,
      'first_name': firstname,
      'last_name': lastname,
      'email': email,
      'password': password,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(registerData),
    );

    Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode == 200) { // demo info
      provider.updateUsername(username);
      provider.updateFirstName(firstname);
      provider.updateLastName(lastname);
      provider.updateEmail(email);
      provider.updateToken(data['token']);
      provider.updateGoals([]); // initialize goals to empty
      provider.updateAndSyncPoints(0); // initilize points to 0
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()), // to home page
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registering Failed'),
            content: const Text('This username has already been registered.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pawsitive Minds'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true, // hides password input
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _register(userProvider),
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                  // Navigate to MainPage on Login button press
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => OpeningPage()),
                  );
                },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  });}
}