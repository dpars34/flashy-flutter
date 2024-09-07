import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomRadioButtonField extends StatelessWidget {
  final String labelText;
  final bool value;
  final bool isError; // New parameter to control the border color
  final ValueChanged<bool> onChanged;

  const CustomRadioButtonField({
    Key? key,
    required this.labelText,
    required this.value,
    this.isError = false, // Default to false
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isError ? red : secondary,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                labelText,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.0,
                  color: gray,
                ),
              ),
            ),
            Container(
              height: 24.0,
              width: 24.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isError ? red : secondary,
                  width: 1.0,
                ),
              ),
              child: value
                  ? Center(
                child: Container(
                  height: 12.0,
                  width: 12.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}