import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';


class Goal {
  String title;
  String description;
  String recurrence; 
  DateTime? endDate; // init end date to null for reminders with no end date
  bool reminders = false;
  int points;

  Goal({required this.title, required this.description, required this.points, this.recurrence = "Daily", this.endDate});
}

List<Goal> userGoals = [
    //example data - will get from backend but implement later 
    Goal(title: 'Meditate', description: 'Meditate 10 minutes every morning', points: 10),
    Goal(title: 'Exercise', description: 'Exercise 5 times a week', points: 20),
];

Future<void> createGoal(Goal goal) async {
    final String apiUrl = 'http://127.0.0.1:8000/goals/'; // to be updated
    final Map<String, dynamic> goalData = {
      'title': goal.title, 
      'description': goal.description, 
      'reccurence' : goal.recurrence,
      // 'endDate' : goal.endDate, - need to figure how to encode this
      'reminders' : goal.reminders,
      'points' : goal.points,
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

Future<void> deleteGoal(Goal? goal) async {
  //function to delete goal from backend
  // todo
  if (goal != null){
    final Map<String, dynamic> goalData = {
          'title': goal.title, 
          'description': goal.description, 
          'reccurence' : goal.recurrence,
          'endDate' : goal.endDate,
          'reminders' : goal.reminders,
          'points' : goal.points,
    };
  }

  //do backend stuff here 

  // for ui testing - delete after backend implemented
  
}

class GoalsPage extends StatefulWidget {
  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage>  {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Goals'),
      ),
      body: ListView.builder(
        itemCount: userGoals.length,
        itemBuilder: (context, index) {
          final goal = userGoals[index];
          return Card(
            child: ListTile(
              leading: IconButton(
                icon: const Icon(Icons.check_circle),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompleteGoalPage(goal: goal),
                    ),
                  );
                } ,),
              title: Text(goal.title),
              subtitle: Text(goal.description),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditGoalPage(goal: goal, isEditing: true),
                    ),
                  ).then((updatedGoal) {
                      if (updatedGoal != null && updatedGoal != false) {
                        setState(() {
                          userGoals[index] = updatedGoal;
                        });
                      }else if (updatedGoal == false){
                        // to handle updating
                        setState(() {
                            userGoals.removeAt(index);
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
              child: const Text('+'),
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
  late TextEditingController pointsController;
  String selectedFrequency = "Daily";
  DateTime? endDate;
  bool reminders = false;

  Widget buildFrequencyButton(String frequency) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedFrequency = frequency;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedFrequency == frequency ? const Color.fromRGBO(200, 215, 243, 1.0) : Colors.grey[300],
        foregroundColor: Colors.black,
      ),
      child: Text(frequency),
    );
  }

  @override
  void initState() {

    super.initState();
    titleController = TextEditingController(text: widget.goal?.title ?? '');
    descriptionController = TextEditingController(text: widget.goal?.description ?? '');
    pointsController = TextEditingController(text: widget.goal != null ? widget.goal!.points.toString() : '0',);
    selectedFrequency = widget.goal?.recurrence ?? 'Daily';
    endDate = widget.goal?.endDate;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    pointsController.dispose();
    super.dispose();
  }

  void saveGoal() {
    int points = int.tryParse(pointsController.text) ?? 0;
    Navigator.pop(
      context,
      Goal(
        title: titleController.text,
        description: descriptionController.text,
        points: points,
        recurrence: selectedFrequency,
        endDate: endDate
      ),
    );
  }

  void confirmDeleteGoal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Dismiss dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss dialog
              deleteGoal(widget.goal); // Call the delete function
              Navigator.of(context).pop(false); // go to goals page
            },
            style: TextButton.styleFrom(backgroundColor: const Color.fromRGBO(222, 144, 144, 1)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text(widget.isEditing ? 'Edit Goal' : 'Create Goal'),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Points'),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildFrequencyButton('Daily'),
                buildFrequencyButton('Weekly'),
                buildFrequencyButton('Monthly'),
                buildFrequencyButton('Other'),
              ],),
            const SizedBox(height: 20),
            
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.goal?.endDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2200),
                  );
                  setState(() {
                    endDate = pickedDate;
                  });
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: endDate != null ? const Color.fromRGBO(200, 215, 243, 1.0) : Colors.grey[300],
                  foregroundColor: Colors.black,
                  ),
                  child: Text(endDate != null ? 'Ends: ${endDate!.toLocal().toString().split(' ')[0]}' : 'Select End Date'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      endDate = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: endDate == null ? const Color.fromRGBO(200, 215, 243, 1.0) : Colors.grey[300],
                  foregroundColor: Colors.black,
                  ),
                  child: const Text('Never Ends'),
              ),
            ],),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: saveGoal,
                  child: Text(widget.isEditing ? 'Save' : 'Create'),
                ),
                if(widget.isEditing && (widget.goal != null ))
                  ElevatedButton(
                  onPressed: confirmDeleteGoal, 
                  child: Text(widget.isEditing ? 'Delete' : 'Cancel'))
             ])
            
          ],
        ),
      ),
    );
  }
}

class CompleteGoalPage extends StatefulWidget{
  final Goal goal;

  CompleteGoalPage({required this.goal});

  @override
  _CompleteGoalPageState createState() => _CompleteGoalPageState();
}

class _CompleteGoalPageState extends State<CompleteGoalPage> {
  late TextEditingController journalController;

  @override
  void initState() {
    super.initState();
    journalController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    journalController.dispose();
    super.dispose();
  }

  void saveCompletion() {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: journalController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveCompletion,
              child: const Text("Complete Goal"),
            ),
          ],
        ),
      ),
    );
  }
}