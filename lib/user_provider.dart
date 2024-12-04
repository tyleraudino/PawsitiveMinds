import 'package:flutter/material.dart';
import 'user_class.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider with ChangeNotifier {
  User _user = User(
    username: 'default',
    firstname: 'John',
    lastname: 'Doe',
    email: 'JohnDoe@gmail.com',
    token: 'test',
  );

  String _recentCatImagePath = ''; // Store the path of the most recent cat image

  User get user => _user;

  String get recentCatImagePath => _recentCatImagePath; // Getter for the recent cat image path

  void updateFirstName(String firstName) {
    _user.firstname = firstName;
    notifyListeners();
  }

  void updateLastName(String lastName) {
    _user.lastname = lastName;
    notifyListeners();
  }

  void updateUsername(String username) {
    _user.username = username;
    notifyListeners();
  }

  void updateEmail(String email) {
    _user.email = email;
    notifyListeners();
  }

  void updatePoints(int points) {
    _user.points = points;
    notifyListeners();
  }

  Future<int> updateAndSyncPoints(int points) async {
    _user.points = points;

    final String apiUrl = 'http://127.0.0.1:8000/user/change_points';
    final Map<String, dynamic> pointsData = {
      'points': points,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user.token}',
      },
      body: json.encode(pointsData),
    );

    Map<String, dynamic> data = json.decode(response.body);

    notifyListeners();

    return response.statusCode;
  }

  void updateToken(String token) {
    _user.token = token;
    notifyListeners();
  }

  // to update image path of most recently unlocked cat
  void updateRecentCatImagePath(String imagePath) {
    _recentCatImagePath = imagePath;
    notifyListeners(); 
  }
}
