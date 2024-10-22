import 'package:flutter/material.dart';
import 'opening.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pawsitive Minds'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                  // Navigate to MainPage on Login button press
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => OpeningPage()),
                  );
                },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}