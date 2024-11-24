import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'home.dart';
import 'goal_ui.dart';
import 'rewards.dart';
import 'opening.dart';
import 'dart:convert';
import "userprofile.dart";
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'user_class.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
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
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: Colors.grey, // Set selected icon color to transparent
              );
            }
            return const IconThemeData(
              color: Colors.black, // Set unselected icon color
            );
          }),
        ),
        textTheme: GoogleFonts.montserratTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(200, 215, 243, 1.0),
            foregroundColor: Colors.black,
            elevation: 0.0,
            shadowColor: Colors.transparent
          )
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 248, 213, 190),
          elevation: 0.0,
          
        ),
      ),
     home: OpeningPage(),
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
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(200, 215, 243, 1.0),
        title: Icon(Icons.pets, size: 50),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/profilepic.jpeg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    
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
            icon: Icon(Icons.account_circle),
            label: "My Account",
          )
        ],
        backgroundColor: const Color.fromRGBO(200, 215, 243, 1.0),
      ),
    );
  }
}
