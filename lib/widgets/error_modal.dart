import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'base_button.dart';

class ErrorModal extends StatelessWidget {

  final String title;
  final String content;
  final BuildContext context;

  const ErrorModal({
    super.key,
    required this.title,
    required this.content,
    required this.context,
  });

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
          text: 'OK',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
