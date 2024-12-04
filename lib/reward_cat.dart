import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class ImageButton extends StatefulWidget {
  final String trueLabel = "";
  final String falseLabel = "Locked";
  final int userPoints;
  final int requiredPoints;
  final String imagePath;
  final VoidCallback onPressed;
  final ValueChanged<int> onPointsUpdated;

  const ImageButton({
    required this.imagePath,
    required this.userPoints,
    required this.requiredPoints,
    required this.onPressed,
    required this.onPointsUpdated,
    Key? key,
  }) : super(key: key);

  @override
  _ImageButtonState createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> {
  bool unlocked = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        // override flutter default colors
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return const Color.fromRGBO(200, 215, 243, 1.0);
            }
            return const Color.fromARGB(255, 212, 212, 212);
          },
        ),
        // text color
        foregroundColor: WidgetStateProperty.all(Colors.black),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      onPressed: unlocked
          ? null
          : () {
              _showUnlockDialog(context);
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // https://stackoverflow.com/questions/53641053/create-a-button-with-an-image-in-flutter
          Image.asset(
            widget.imagePath,
            width: 120,
            height: 120,
          ),
          const SizedBox(width: 8),
          Text(unlocked ? widget.trueLabel : widget.falseLabel),
        ],
      ),
    );
  }

  void _showUnlockDialog(BuildContext context) {
    // https://api.flutter.dev/flutter/material/showDialog.html
    // https://api.flutter.dev/flutter/material/AlertDialog-class.html
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure you want to unlock this cat?'),
          content: Text(
              'You need ${widget.requiredPoints} points to unlock this cat. You have ${widget.userPoints} points.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (widget.userPoints >= widget.requiredPoints) {
                  setState(() {
                    unlocked = true;
                  });
                  widget.onPointsUpdated(widget.userPoints - widget.requiredPoints);
                  widget.onPressed();
                  // updates most recent cat
                  Provider.of<UserProvider>(context, listen: false)
                      .updateRecentCatImagePath(widget.imagePath);
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  _showErrorDialog(context);
                }
              },
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'You do not have enough points to unlock this cat.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('I will get more points!'),
            ),
          ],
        );
      },
    );
  }
}
