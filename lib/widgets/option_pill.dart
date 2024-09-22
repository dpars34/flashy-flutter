import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class OptionPill extends StatelessWidget {
  final bool large;
  final String color;
  final String text;

  const OptionPill({
    super.key,
    this.large = false,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: large ? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 3.0) : const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: color == 'purple' ? primary : yellow,
      ),
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          color: color == 'purple' ? white : black,
          fontWeight: FontWeight.w600,
          fontSize: large ? 14 : 11,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
