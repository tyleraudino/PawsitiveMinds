import 'package:flutter/material.dart';
import 'main.dart'; 
import 'opening.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'goal_class.dart';
import 'user_class.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  void _login(UserProvider provider) async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();

      final String apiUrl = 'http://127.0.0.1:8000/user/login';
      final Map<String, dynamic> loginData = {
        'username': username,
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

      if (response.statusCode == 200) {
        List<Goal> loadedGoals = await getGoals(username, data['token']);
        provider.updateUsername(username);
        String firstname = data['first_name'];
        String lastname = data['last_name'];
        String email = data['email'];
        int points = data['points'] ?? 0;
        provider.updateFirstName(firstname);
        provider.updateLastName(lastname);
        provider.updateEmail(email);
        provider.updatePoints(points);
        provider.updateToken(data['token']);
        provider.updateGoals(loadedGoals);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
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
  }

  void _handleKeyPress(RawKeyEvent event, UserProvider provider) {
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_formKey.currentState!.validate()) {
        _login(provider);
      }
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
          body: RawKeyboardListener(
            focusNode: _focusNode,
            onKey: (event) => _handleKeyPress(event, userProvider),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _login(userProvider),
                      child: Text('Login'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
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
            ),
          ),
        );
      },
    );
  }
}
