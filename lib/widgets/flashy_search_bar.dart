import 'package:flutter/material.dart';
import '../utils/colors.dart';

class FlashySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final VoidCallback onSubmit;

  const FlashySearchBar({
    Key? key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      autocorrect: false,
      textInputAction: TextInputAction.search,
      onFieldSubmitted: (String value) {
        onSubmit();
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, color: gray),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100.0),
          borderSide: const BorderSide(color: white, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100.0),
          borderSide: const BorderSide(color: white, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100.0),
          borderSide: const BorderSide(color: white, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100.0),
          borderSide: const BorderSide(color: red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100.0),
          borderSide: const BorderSide(color: red, width: 2.0),
        ),
        contentPadding: EdgeInsets.all(16.0),
      ),
      validator: validator,
    );
  }
}
