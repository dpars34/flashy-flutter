import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final bool autocorrect;

  const CustomInputField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.isPassword = false,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.autocorrect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: gray,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4.0),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          autocorrect: autocorrect,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: secondary, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: secondary, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: secondary, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: red, width: 2.0),
            ),
            contentPadding: EdgeInsets.all(16.0),
          ),
          validator: validator,
        ),
      ],
    );
  }
}