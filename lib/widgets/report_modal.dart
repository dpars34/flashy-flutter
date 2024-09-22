import 'package:flutter/material.dart';

import '../utils/colors.dart';
import 'base_button.dart';

class ReportModal extends StatelessWidget {

  final BuildContext context;

  const ReportModal({
    super.key,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: white,
      title: const Text(
        'Report a problem',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: primary,
          fontSize: 20,
        ),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'At Flashy, we strive to maintain a positive and respectful learning environment. We do not tolerate abusive language or comments. If you come across any content that may violate our terms of service, please feel free to reach out to us at:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: primary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'flashy.app.danny@gmail.com',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: primary,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
        ],
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
