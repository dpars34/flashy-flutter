import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class BaseButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;
  final bool outlined;
  final bool loading;

  const BaseButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.color = primary,
    this.outlined = false,
    this.loading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 51,
        width: double.infinity,
        decoration: BoxDecoration(
          color: outlined ? white : color,
          border: Border.all(
            color: color,
            width: 3.0,
          ),
          borderRadius: BorderRadius.circular(50), // Border radius here
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Center(
            child: loading ? SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                color: color == yellow ? outlined ? color : black : outlined ? color : white,
                strokeWidth: 3,
              ),
            ) : Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color == yellow ? outlined ? color : black : outlined ? color : white
              ),
            ),
          ),
        ),
      ),
    );
  }
}
