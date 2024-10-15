import 'package:flutter/material.dart';
import 'home.dart';
import 'goals.dart';
import 'rewards.dart';
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
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: Colors.transparent, // Remove the indicator color
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // Always hide the labels
          iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(
                color: Colors.grey, // Set selected icon color to transparent
              );
            }
            return const IconThemeData(
              color: Colors.black, // Set unselected icon color
            );
          }),
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPageIndex = 0;

  static List<Widget> _pages = <Widget>[
    HomePage(),
    GoalsPage(),
    RewardsPage(),
    SocialPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPageIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: "Goals",
          ),
          NavigationDestination(
            icon: Icon(Icons.pets),
            label: "Rewards",
          ),
          NavigationDestination(
            icon: Icon(Icons.groups),
            label: "Social",
          )
        ],
        backgroundColor: const Color.fromRGBO(200, 215, 243, 1.0),
      ),
    );
  }
}
