import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';

class SwipeTag extends StatelessWidget {
  final String color;
  final String text;

  const SwipeTag({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: color == 'red' ? red : green,
              width: 3.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
            child: Text(
              text,
              style: TextStyle(
                  color: color == 'red' ? red : green,
                  fontSize: 16,
                  fontWeight: FontWeight.w700
              ),
            ),
          )
      ),
    );
  }
}
