import 'goal_class.dart';

class User {
String username;
String firstname;
String lastname;
int points;
List<Goal> userGoals = [
    //example data - will get from backend but implement later 
    Goal(title: 'Meditate', description: 'Meditate 10 minutes every morning', points: 10),
    Goal(title: 'Exercise', description: 'Exercise 5 times a week', points: 20),
];

User({required this.username, required this.firstname, required this.lastname, this.points = 0,});
}