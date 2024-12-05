import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'goal_class.dart';
import 'user_class.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

Widget buildGoalListView(List<Goal> goals, void Function(void Function()) setStateCallback) {
  final groupedGoals = groupGoalsByDueStatus(goals);
  final sortedDueStatuses = groupedGoals.keys.toList();

  return Consumer<UserProvider>(
      builder: (context, userProvider, child)  {
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
                      updateGoalBackend(updatedGoal, userProvider);

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
});
}

Future<void> createGoal(Goal goal, UserProvider provider) async {
    final String apiUrl = 'http://127.0.0.1:8000/goals/'; // to be updated
    final Map<String, dynamic> goalData = {
      'title': goal.title, 
      'description': goal.description, 
      'recurrence' : goal.recurrence,
      'points' : goal.points,
      'lastCompleted' : goal.lastCompleted
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${provider.user.token}',
      },
        body: json.encode(goalData),
      );

      if (response.statusCode == 200) { // checks for 200 created
        print('Goal created successfully: ${response.body}');
        final responseData = json.decode(response.body);
        final String goalId = responseData['goal_id'];  
        goal.id = goalId; // sets goal object's id after mongo creates one
        print('Goal created successfully with ID: $goalId');
        //update goals now
        List<Goal> updatedGoals = await getGoals(provider.user.username, provider.user.token);
        provider.updateGoals(updatedGoals);
      } else {
        print("Failed: ${response.body}");
        print('Failed to create goal: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

Future<void> deleteGoal(Goal? goal, UserProvider provider) async {
  //function to delete goal from backend
  if (goal != null){
    final Map<String, dynamic> goalData = {
          'title': goal.title, 
          'description': goal.description, 
          'recurrence' : goal.recurrence,
          'endDate' : goal.endDate,
          'reminders' : goal.reminders,
          'points' : goal.points,
          'lastCompleted' : goal.lastCompleted
    };
  }
  //do backend stuff here 
  if (goal == null) {
    print("Goal is null. Cannot delete.");
    return;
  }
  final String apiUrl = 'http://127.0.0.1:8000/goals/${goal.id}'; 

  try {
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${provider.user.token}',
      },
    );

    //update goals now
    List<Goal> updatedGoals = await getGoals(provider.user.username, provider.user.token);
    provider.updateGoals(updatedGoals);
  } catch (e) {
    print('Error: $e');
  }

}

Future<void> updateGoalBackend(Goal? goal, UserProvider provider) async {
  //do backend stuff here 
  if (goal == null) {
    print("Goal is null. Cannot update.");
    return;
  }

  final Map<String, dynamic> newgoalData = {
        'title': goal.title, 
        'description': goal.description, 
        'recurrence' : goal.recurrence,
        'points' : goal.points,
        'lastCompleted' : goal.lastCompleted
  };

  print("new goal data: $newgoalData");

  final String apiUrl = 'http://127.0.0.1:8000/goals/${goal.id}'; 

  try {
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${provider.user.token}',
      },
      body: json.encode(newgoalData),
    );
    if (response.statusCode == 200) { // checks for 200 created
        print('Goal updated successfully: ${response.body}');
    } else {
       print("Failed to update: ${response.body}");
      print('Failed to update goal: ${response.statusCode}');
    }

    //update goals now
    List<Goal> updatedGoals = await getGoals(provider.user.username, provider.user.token);
    provider.updateGoals(updatedGoals);
  } catch (e) {
    print('Error: $e');
}
}

class GoalsPage extends StatefulWidget {
  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage>  {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }
// load user goals from backend
   Future<void> _loadGoals() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      List<Goal> loadedGoals = await getGoals(userProvider.user.username, userProvider.user.token);
      userProvider.updateGoals(loadedGoals);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      // Optionally show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load goals: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child)  {
        //then sort
        List<Goal> sortedGoals = sortGoalsByNextDueDate(userProvider.user.userGoals);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Goals'),
        ),
        body: userProvider.user.userGoals.isEmpty
          ? const Center(
                child: Text('You currently have no goals. Click the + icon to add one!', textAlign: TextAlign.center),
              )
          : buildGoalListView(sortedGoals, (fn) => setState(fn)),
      floatingActionButton: FloatingActionButton(
                onPressed: () { 
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditGoalPage())
                  ).then((newGoal) async {
                      if (newGoal != null) {
                        
                        //for backend
                        createGoal(newGoal, userProvider);
                        
                      }        
                    });
                  // open goal creation page here
                },
                child: const Text('+'),
              ),
      );
    });
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
  String? goalId;

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
    goalId = widget.goal?.id;
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
      ),
    );
  }

  void updateGoal(String id) {
    int points = int.tryParse(pointsController.text) ?? 0;
    Navigator.pop(
      context,
      Goal(
        id: id,
        title: titleController.text,
        description: descriptionController.text,
        points: points,
        recurrence: selectedFrequency,
      ),
    );
  }

  void confirmDeleteGoal(UserProvider userProvider) {
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
              deleteGoal(widget.goal, userProvider); // Call the delete function
              Navigator.of(context).pop(false); // go to goals page
            },
            style: TextButton.styleFrom(foregroundColor: Color.fromARGB(255, 0, 0, 0), backgroundColor: const Color.fromRGBO(222, 144, 144, 1)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
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
                  onPressed: (){
                    if(widget.isEditing == false){
                      saveGoal();
                    }else if (goalId != null){
                      updateGoal(goalId!);
                    }
                    
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(255, 198, 163, 1)),
                  child: Text(widget.isEditing ? 'Save' : 'Create', style: const TextStyle(fontWeight: FontWeight.bold),),
                ),
                if(widget.isEditing && (widget.goal != null ))
                  ElevatedButton(
                  onPressed: () => confirmDeleteGoal(userProvider),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(255, 198, 163, 1)),
                  child: Text(widget.isEditing ? 'Delete' : 'Cancel', style: const TextStyle(fontWeight: FontWeight.bold)),
                  )
                 
             ])
            
          ],
        ),
      ),
    );
  });
  }}

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

  void saveCompletion(UserProvider provider) async {
    widget.goal.completeGoal();
    int result = await provider.updateAndSyncPoints(provider.user.points + widget.goal.points);

    if (mounted) {
      if (result != 200) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('An error occurred while updating points.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
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
              onPressed: () => saveCompletion(userProvider),
              child: const Text("Complete Goal"),
            ),
          ],
        ),
      ),
    );
  });
  }
}