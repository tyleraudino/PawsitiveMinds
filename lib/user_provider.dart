import 'package:flutter/material.dart';
import 'user_class.dart';

class UserProvider with ChangeNotifier {
  User _user = User(
    username: 'default',
    firstname: 'John',
    lastname: 'Doe',
    email: 'JohnDoe@gmail.com',
    token: 'test',
  );

  User get user => _user;

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

  void updateToken(String token) {
    _user.token = token;
    notifyListeners();
  }
}