import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoalsPage extends StatelessWidget {
  Future<void> createGoal() async {
    final String apiUrl = 'http://127.0.0.1:8000/goals/'; // to be updated
    final Map<String, dynamic> goalData = {
      'title': 'New Goal', // temp data
      'description': 'Description of the new goal', // temp data
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(goalData),
      );

      if (response.statusCode == 201) { // checks for 201 Created
        print('Goal created successfully: ${response.body}');
      } else {
        print('Failed to create goal: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goals Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is the Goals page'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                createGoal();
              },
              child: Text('Push to create a goal'),
            ),
          ],
        ),
      ),
    );
  }
}
