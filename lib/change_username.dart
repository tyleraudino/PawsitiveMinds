import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import "userprofile.dart";

class ChangeUsername extends StatefulWidget {
  const ChangeUsername({super.key});

  @override
  _ChangeUsernameState createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  final TextEditingController _usernameController = TextEditingController();

  void _change_username(UserProvider provider) async {
    String username = _usernameController.text;

    final String apiUrl = 'http://127.0.0.1:8000/user/change_username';
    final Map<String, dynamic> usernameData = {
      'username': username,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${provider.user.token}',
      },
      body: json.encode(usernameData),
    );

    Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode == 200) { // demo info
      provider.updateUsername(username);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Changing Username Failed'),
            content: Text('An error occurred while changing username.'),
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
            ElevatedButton(
              onPressed: () => _change_username(userProvider),
              child: Text('Change Username'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to OpeningPage on Go back button press
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
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
