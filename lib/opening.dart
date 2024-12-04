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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20), 
              Text(
                'Welcome to Pawsitive Minds',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
               Center(
                  child: Image.asset(
                    'assets/profilecat.gif',
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              SizedBox(height: 20), 
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
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
