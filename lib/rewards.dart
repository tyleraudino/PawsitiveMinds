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
        child:
          Row(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageButton(
                  imagePath: 'assets/rewardcat1.png',
                  requiredPoints: 20,
                  userPoints: userPoints,
                  onPointsUpdated: (updatedPoints) {
                    setState(() {
                      userPoints = updatedPoints;
                    });
                  },
                  onPressed: () {
                  },
                ),
                const SizedBox(height: 26),
                ImageButton(
                  imagePath: 'assets/rewardcat2.png',
                  userPoints: userPoints,
                  requiredPoints: 30,
                  onPointsUpdated: (updatedPoints) {
                    setState(() {
                      userPoints = updatedPoints;
                    });
                  },
                  onPressed: () {
                  },
                ),
                const SizedBox(height: 26),
                ImageButton(
                  imagePath: 'assets/rewardcat3.png',
                  userPoints: userPoints,
                  requiredPoints: 40,
                  onPointsUpdated: (updatedPoints) {
                    setState(() {
                      userPoints = updatedPoints; 
                    });
                  },
                  onPressed: () {
                  },
                ),
              ],
            ),
            const SizedBox(width: 40),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageButton(
                  imagePath: 'assets/rewardcat4.png',
                  requiredPoints: 20,
                  userPoints: userPoints,
                  onPointsUpdated: (updatedPoints) {
                    setState(() {
                      userPoints = updatedPoints;
                    });
                  },
                  onPressed: () {
                  },
                ),
                const SizedBox(height: 26),
                ImageButton(
                  imagePath: 'assets/rewardcat5.png',
                  userPoints: userPoints,
                  requiredPoints: 30,
                  onPointsUpdated: (updatedPoints) {
                    setState(() {
                      userPoints = updatedPoints;
                    });
                  },
                  onPressed: () {
                  },
                ),
                const SizedBox(height: 26),
                ImageButton(
                  imagePath: 'assets/rewardcat6.png',
                  userPoints: userPoints,
                  requiredPoints: 40,
                  onPointsUpdated: (updatedPoints) {
                    setState(() {
                      userPoints = updatedPoints;
                    });
                  },
                  onPressed: () {
                  },
                ),
              ],
            ),
            const SizedBox(width: 40),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageButton(
                  imagePath: 'assets/rewardcat7.png',
                  requiredPoints: 20,
                  userPoints: userPoints,
                  onPointsUpdated: (updatedPoints) {
                    setState(() {
                      userPoints = updatedPoints;
                    });
                  },
                  onPressed: () {
                  },
                ),
                const SizedBox(height: 26),
                ImageButton(
                  imagePath: 'assets/rewardcat8.png',
                  userPoints: userPoints,
                  requiredPoints: 30,
                  onPointsUpdated: (updatedPoints) {
                    setState(() {
                      userPoints = updatedPoints;
                    });
                  },
                  onPressed: () {
                  },
                ),
                const SizedBox(height: 26),
                ImageButton(
                  imagePath: 'assets/rewardcat9.png',
                  userPoints: userPoints,
                  requiredPoints: 40,
                  onPointsUpdated: (updatedPoints) {
                    setState(() {
                      userPoints = updatedPoints;
                    });
                  },
                  onPressed: () {
                  },
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RewardsPage(),
  ));
}
