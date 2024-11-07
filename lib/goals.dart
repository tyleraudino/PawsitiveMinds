import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';



class Goal {
  String title;
  String description;
  String recurrence; 
  int recurrenceInterval; // for custom recurrence
  DateTime? endDate; // init end date to null for reminders with no end date
  DateTime? lastCompleted;
  List<DateTime> completionDates = [];
  bool reminders = false;
  int points;

  Goal({required this.title, required this.description, required this.points, this.recurrence = "Daily", this.recurrenceInterval = 1, this.endDate});

  void completeGoal(){
    DateTime now = DateTime.now();
    lastCompleted = now;
    completionDates.add(now);
    //potentially add completion details like a journal here later
  }

  void undoCompleteGoal(){
    if (completionDates.length == 1){
      lastCompleted = null;
    } else {
      lastCompleted = completionDates[completionDates.length - 1];
    }
    completionDates.removeLast();
  }

  DateTime calculateNextDueDate() {
    DateTime nextDueDate;
    DateTime referenceDate = lastCompleted ?? DateTime.now();

    switch (recurrence) {
      case "Daily":
        nextDueDate = referenceDate.add(Duration(days: recurrenceInterval));
        while (nextDueDate.isBefore(DateTime.now())) {
          nextDueDate = nextDueDate.add(Duration(days: recurrenceInterval));
        }
        break;

      case "Weekly":
        nextDueDate = referenceDate.add(Duration(days: 7 * recurrenceInterval));
        while (nextDueDate.isBefore(DateTime.now())) {
          nextDueDate = nextDueDate.add(Duration(days: 7 * recurrenceInterval));
        }
        break;

      case "Monthly":
        nextDueDate = DateTime(referenceDate.year, referenceDate.month + recurrenceInterval, referenceDate.day);
        while (nextDueDate.isBefore(DateTime.now())) {
          nextDueDate = DateTime(nextDueDate.year, nextDueDate.month + recurrenceInterval, nextDueDate.day);
        }
        break;

      case "Other":
        nextDueDate = referenceDate.add(Duration(days: recurrenceInterval));
        while (nextDueDate.isBefore(DateTime.now())) {
          nextDueDate = nextDueDate.add(Duration(days: recurrenceInterval));
        }
        break;

      default:
        throw Exception("Invalid recurrence type");
    }

    if (endDate != null && nextDueDate.isAfter(endDate!)) {
      throw Exception("Next due date is beyond the end date");
    }

    return nextDueDate;
  }

  bool checkIfCompleted(){
    bool completed = false;

    //check if last completed date = today
    if (lastCompleted?.day == DateTime.now().day){
      completed = true;
    }

    return completed;
  }
}

List<Goal> userGoals = [
    //example data - will get from backend but implement later 
    //Goal(title: 'Meditate', description: 'Meditate 10 minutes every morning', points: 10),
    //Goal(title: 'Exercise', description: 'Exercise 5 times a week', points: 20),
];

List<Goal> sortGoalsByNextDueDate(List<Goal> goals) {
  goals.sort((a, b) => a.calculateNextDueDate().compareTo(b.calculateNextDueDate()));
  return goals;
}

String getDueStatus(DateTime nextDueDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(Duration(days: 1));
  final difference = nextDueDate.difference(today).inDays;

  if (difference == 0) {
    return "Due today";
  } else if (difference == 1) {
    return "Due tomorrow";
  } else if (difference < 0) {
    return "Overdue";
  } else {
    return "Due in $difference days";
  }
}

Map<String, List<Goal>> groupGoalsByDueStatus(List<Goal> goals) {
  final Map<String, List<Goal>> groupedGoals = {};

  for (var goal in goals) {
    final dueStatus = getDueStatus(goal.calculateNextDueDate());
    if (!groupedGoals.containsKey(dueStatus)) {
      groupedGoals[dueStatus] = [];
    }
    groupedGoals[dueStatus]!.add(goal);
  }

  return groupedGoals;
}

Widget buildGoalListView(List<Goal> goals, void Function(void Function()) setStateCallback) {
  final groupedGoals = groupGoalsByDueStatus(goals);
  final sortedDueStatuses = groupedGoals.keys.toList();

  return ListView.builder(
    itemCount: groupedGoals.length,
    itemBuilder: (context, index) {
      final dueStatus = sortedDueStatuses[index];
      final goalsForStatus = groupedGoals[dueStatus]!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              dueStatus,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...goalsForStatus.map((goal) {
            return Card(
              child: ListTile(
                leading: IconButton(
                  icon: Icon(
                    goal.checkIfCompleted() ? Icons.check_circle : Icons.radio_button_unchecked,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompleteGoalPage(goal: goal),
                      ),
                    ).then((completionConfirmation) {
                      setStateCallback(() {
                          goals = sortGoalsByNextDueDate(goals); // Re-sort after updating
                        });
                    });
                  },
                ),
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
                        setStateCallback(() {
                          goals[goals.indexOf(goal)] = updatedGoal;
                          goals = sortGoalsByNextDueDate(goals); // Re-sort after updating
                        });
                      } else if (updatedGoal == false) {
                        // to handle updating
                        setStateCallback(() {
                          goals.remove(goal);
                        });
                      }
                    });
                  },
                ),
              ),
            );
          }).toList(),
        ],
      );
    },
  );
}

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

      if (response.statusCode == 200) { // checks for 201 Created
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
    List<Goal> sortedGoals = sortGoalsByNextDueDate(userGoals);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Goals'),
      ),
      body: userGoals.isEmpty
        ? const Center(
              child: Text('You currently have no goals. Click the + icon to add one!', textAlign: TextAlign.center),
            )
        : buildGoalListView(sortedGoals, (fn) => setState(fn)),
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
            style: TextButton.styleFrom(foregroundColor: const Color(0x00000000) , backgroundColor: const Color.fromRGBO(222, 144, 144, 1)),
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
            const Align(alignment: Alignment.centerLeft, child: Text('How often do you want to complete this goal?', style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildFrequencyButton('Daily'),
                buildFrequencyButton('Weekly'),
                buildFrequencyButton('Monthly'),
                buildFrequencyButton('Other'),
              ],),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text('End date', style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: saveGoal,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(255, 198, 163, 1)),
                  child: Text(widget.isEditing ? 'Save' : 'Create', style: const TextStyle(fontWeight: FontWeight.bold),),
                ),
                if(widget.isEditing && (widget.goal != null ))
                  ElevatedButton(
                  onPressed: confirmDeleteGoal,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(255, 198, 163, 1)),
                  child: Text(widget.isEditing ? 'Delete' : 'Cancel', style: const TextStyle(fontWeight: FontWeight.bold)),
                  )
                 
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
    widget.goal.completeGoal();
    Navigator.of(context).pop();
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