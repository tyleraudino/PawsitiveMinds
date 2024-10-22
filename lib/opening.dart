import 'package:flutter/material.dart';
import 'login.dart'; 
import 'signup.dart'; 

class OpeningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: SingleChildScrollView( // Allow scrolling for smaller screens
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image widget
              /*
              Image.asset(
                'assets/your_image.png', // Change to your image path
                height: 150, // Adjust height as needed
              ),*/
              SizedBox(height: 20), // Space between image and text
              Text(
                'Welcome to Pawsitive Minds',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20), // Space between text and buttons
              ElevatedButton(
                onPressed: () {
                  // Navigate to MainPage on Login button press
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Login'),
              ),
              SizedBox(height: 10), // Space between buttons
              ElevatedButton(
                onPressed: () {
                  // Navigate to MainPage on Login button press
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text('Signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
