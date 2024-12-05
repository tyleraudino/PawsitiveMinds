import 'package:flutter/material.dart';
import 'reward_cat.dart';
import 'rewards_class.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class RewardsPage extends StatefulWidget {
  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Stack(
              alignment: Alignment.center,
              children: [
                // Centered Title
                Center(
                  child: Text('Rewards'),
                ),
                // Right-aligned Points
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 248, 213, 190),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.black, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${userProvider.user.points} Points',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return ImageButton(
                  imagePath: 'assets/rewardcat${index + 1}.png',
                  requiredPoints: 20 + (index % 3) * 10,
                  userProvider: userProvider,
                  onPressed: () {
                    // Define your onPressed action here
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RewardsPage(),
  ));
}
