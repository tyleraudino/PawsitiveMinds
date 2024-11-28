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

  void PasswordsError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Passwords do not match. Please try again.'),
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

    if (password != _confirmPassController.text) {
      PasswordsError();
      return;
    }

    final String apiUrl = 'http://127.0.0.1:8000/user/register';
    final Map<String, dynamic> registerData = {
      'user_id': username,
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
      provider.updateToken(data['token']);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()), // to home page
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Registering Failed'),
            content: Text('This username has already been registered.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
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
        title: Text('Pawsitive Minds'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true, // hides password input
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _register(userProvider),
              child: Text('Create Account'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                  // Navigate to MainPage on Login button press
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => OpeningPage()),
                  );
                },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  });}
}