import 'package:flutter/material.dart';
import 'package:pawsitive_minds/goal_ui.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'goal_class.dart';

Widget buildTodayGoalList(List<Goal> goals) {
  final groupedGoals = groupGoalsByDueStatus(goals);

  // Ensure that dailyGoals is not null
  List<Goal>? dailyGoals = groupedGoals["Due tomorrow"];
  if (dailyGoals == null || dailyGoals.isEmpty) {
    // Return a message if there are no goals due tomorrow
    return const Center(child: Text('No goals due today'));
  }

  return ListView.builder(
    itemCount: dailyGoals.length,
    itemBuilder: (context, index) {
      final goal = dailyGoals[index];

      return Card(
        child: ListTile(
          leading: Icon(
            goal.checkIfCompleted()
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
          ),
          title: Text(goal.title),
          subtitle: Text(goal.description),
          trailing: Icon(Icons.edit),
        ),
      );
    },
  );
}

class HomePage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                //row containing user first name
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 20),
                    Text('Welcome ${userProvider.user.firstname}!',
                        style: const TextStyle(fontSize: 20))
                  ],
                ),
                const SizedBox(height: 16),

                //contains the due goals box
                Row( 
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 248, 213, 190),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Goals due today:",
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: 300, // Set a fixed height for the ListView
                              child:
                                  buildTodayGoalList(userProvider.user.userGoals),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                //this is the row with the points and cat widgets
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 248, 213, 190),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Total points:",
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: 210, // Set a fixed height for the ListView
                          
                              child: 
                                Center(
                                  child:
                                  Text(
                                  userProvider.user.points.toString() ,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
                                  ),
                              ),
                                
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 248, 213, 190),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Most recent cat:",
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: 210, 
                              child: userProvider.recentCatImagePath.isEmpty
                                  // if no cats have been unlocked
                                  ? const Center(child: Text('No recent cat unlocked'))
                                  : Center(
                                      // if a cat has been unlocked, displays the most recent
                                      child: Image.asset(
                                        userProvider.recentCatImagePath,
                                        width: 200,
                                        height: 200,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],),

                //this row has the extra box
                
              ],
            ),
          )
        );
      },
    );
  }
}