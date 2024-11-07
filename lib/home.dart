import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome, ${userProvider.user.firstname}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    userProvider.updateFirstName('Jane');
                  },
                  child: const Text('Change Name'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}