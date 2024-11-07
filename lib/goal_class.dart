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
