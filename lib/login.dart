import 'package:flutter/material.dart';
import 'main.dart'; 
import 'opening.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(UserProvider provider) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    final String apiUrl = 'http://127.0.0.1:8000/user/login';
    final Map<String, dynamic> loginData = {
      'user_id': username,
      'password': password,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(loginData),
    );

    Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode == 200) { // demo info
      provider.updateUsername(username);
      //need to get this info from backend after successful login
      //test data for now
      String firstname = "test";
      String lastname = "test";
      String email = "test";
      int points = 10;
      provider.updateFirstName(firstname);
      provider.updateLastName(lastname);
      provider.updateEmail(email);
      provider.updatePoints(points);
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
            title: Text('Login Failed'),
            content: Text('Invalid username or password.'),
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
            ElevatedButton(
              onPressed: () => _login(userProvider), // calls the login function when pressed
              child: Text('Login'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to OpeningPage on Go back button press
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OpeningPage()),
                );
              },
              child: Text('Go back'),
            ),
          ],
        ),
      ),
    );
      });
  }

}
