import 'package:flutter/material.dart';
import 'user_class.dart';

class UserProvider with ChangeNotifier {
  User _user = User(
    username: 'default',
    firstname: 'John',
    lastname: 'Doe'
  );

  User get user => _user;

  void updateFirstName(String firstName) {
    _user = User(
      username: _user.username,
      firstname: firstName,
      lastname: _user.lastname,
    );
    notifyListeners();
  }

  void updateUsername(String username) {
    _user.username = username;
    notifyListeners();
  }

  void updateToken(String token) {
    _user.token = token;
    notifyListeners();
  }
}