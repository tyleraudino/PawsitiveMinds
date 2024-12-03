import 'package:flutter/material.dart';
import 'reward_cat.dart';

class RewardsPage extends StatefulWidget {
  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  int userPoints = 100; // hardcode, get from backend

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rewards Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0, // Adjust for aspect ratio of images/buttons
          ),
          itemCount: 9, // Number of reward items
          itemBuilder: (context, index) {
            return ImageButton(
              imagePath: 'assets/rewardcat${index + 1}.png',
              userPoints: userPoints,
              requiredPoints: 20 + (index % 3) * 10, // required points
              onPointsUpdated: (updatedPoints) {
                setState(() {
                  userPoints = updatedPoints;
                });
              },
              onPressed: () {
                // Define your onPressed action here
              },
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RewardsPage(),
  ));
}
