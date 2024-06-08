import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class OptionPill extends StatelessWidget {
  final String color;
  final String text;

  const OptionPill({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color == 'red' ? red : green,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: white,
          fontWeight: FontWeight.w600,
          fontSize: 11
        ),
      ),
    );
  }
}
