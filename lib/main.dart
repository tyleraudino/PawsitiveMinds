import 'package:flutter/material.dart';
import 'home.dart';
import 'goals.dart';
import 'rewards.dart';
import 'login.dart';
import 'social.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawsitive Minds',
      theme: ThemeData(
        colorSchemeSeed: const Color.fromRGBO(200, 215, 243, 1.0),
        canvasColor: const Color.fromRGBO(200, 215, 243, 1.0),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    HomePage(),
    GoalsPage(),
    RewardsPage(),
    SocialPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: "",
          )
        ],
        backgroundColor: const Color.fromRGBO(200, 215, 243, 1.0),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(255,213,176, 1.0),
        onTap: _onItemTapped,
      ),
    );
  }
}
