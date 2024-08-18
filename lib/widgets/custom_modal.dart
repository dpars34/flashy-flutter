import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'base_button.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final String content;
  final String button1Text;
  final String button2Text;
  final VoidCallback button1Callback;
  final VoidCallback button2Callback;

  const CustomModal({
    Key? key,
    required this.title,
    required this.content,
    required this.button1Text,
    required this.button2Text,
    required this.button1Callback,
    required this.button2Callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: white,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: primary,
          fontSize: 20,
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: primary,
          fontSize: 14,
        ),
      ),
      actions: <Widget>[
        BaseButton(
          text: button1Text,
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            button1Callback(); // Execute the first callback
          },
          outlined: true, // Example: you can customize your button style
        ),
        SizedBox(height: 8),
        BaseButton(
          text: button2Text,
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            button2Callback(); // Execute the second callback
          },
        ),
      ],
    );
  }
}