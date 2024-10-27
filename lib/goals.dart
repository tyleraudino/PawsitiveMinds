import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Goal {
  String title;
  String description;

  Goal({required this.title, required this.description});
}

Future<void> createGoal(Goal goal) async {
    final String apiUrl = 'http://127.0.0.1:8000/goals/'; // to be updated
    final Map<String, dynamic> goalData = {
      'title': goal.title, // temp data
      'description': goal.description, // temp data
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(goalData),
      );

      if (response.statusCode == 201) { // checks for 201 Created
        print('Goal created successfully: ${response.body}');
      } else {
        print('Failed to create goal: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

class GoalsPage extends StatefulWidget {
  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage>  {
  List<Goal> userGoals = [
    //example data - will get from backend but implement later 
    Goal(title: 'Meditate', description: 'Meditate 10 minutes every morning'),
    Goal(title: 'Exercise', description: 'Exercise 5 times a week'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Goals'),
      ),
      body: ListView.builder(
        itemCount: userGoals.length,
        itemBuilder: (context, index) {
          final goal = userGoals[index];
          return Card(
            child: ListTile(
              leading: Icon(Icons.check_box_rounded),
              title: Text(goal.title),
              subtitle: Text(goal.description),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditGoalPage(goal: goal, isEditing: true),
                    ),
                  ).then((updatedGoal) {
                      if (updatedGoal != null) {
                        setState(() {
                          userGoals[index] = updatedGoal;
                        });
                      }
                    });
                },
              ),
            ),
          );
        },
      ),

    floatingActionButton: FloatingActionButton(
              onPressed: () { 
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditGoalPage())
                ).then((newGoal) {
                    if (newGoal != null) {
                      //for debugging data
                      setState(() {
                        userGoals.add(newGoal);
                      });

                      //for backend
                      createGoal(newGoal);
                    }
                    
                  });
    
                // open goal creation page here
              },
              child: Text('+'),
            ),
    );
  }
}

class EditGoalPage extends StatefulWidget {
  final Goal? goal;
  final bool isEditing;

  EditGoalPage({this.goal, this.isEditing = false});

  @override
  _EditGoalPageState createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.goal?.title ?? '');
    descriptionController = TextEditingController(text: widget.goal?.description ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void saveGoal() {
    Navigator.pop(
      context,
      Goal(
        title: titleController.text,
        description: descriptionController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text(widget.isEditing ? 'Edit Goal' : 'Create Goal'),),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveGoal,
              child: Text(widget.isEditing ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}