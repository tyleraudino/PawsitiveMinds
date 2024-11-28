import 'goal_class.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
String username;
String firstname;
String lastname;
String email;
String token;
int points;
List<Goal> userGoals = [];

User({required this.username, required this.firstname, required this.lastname, required this.email, required this.token, this.points = 0});

String getInitials () {
  String first = this.firstname.substring(0, 1);
  String last = this.lastname.substring(0,1);

  String initials = first + last;
  return initials;
}

Future<void> loadGoals() async {
    try {
      this.userGoals = await getGoals(this.username);
    } catch (e) {
      throw Exception('Failed to load user goals: $e');
    }
  }

}

// determine if we need this
Future<List<Goal>> getGoals(String username) async {
  final String apiUrl = 'http://127.0.0.1:8000/goals/$username'; // Assuming the endpoint takes a username parameter

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List<dynamic> goalsJson = json.decode(response.body);
      return goalsJson.map((json) => Goal.fromJson(json)).toList();
    }
  } catch (e) {
    throw Exception('Failed to load goals: $e');
  }
  throw Exception('Failed to load goals');
}

