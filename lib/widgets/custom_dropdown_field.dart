import 'package:flutter/material.dart';
import '../models/category_data.dart';
import '../utils/colors.dart';

class CustomDropdownField extends StatelessWidget {
  final String labelText;
  final CategoryData? value;
  final List<CategoryData> items;
  final ValueChanged<CategoryData?> onChanged;
  final FormFieldValidator<CategoryData>? validator;

  const CustomDropdownField({
    Key? key,
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
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
        DropdownButtonFormField<CategoryData>(
          value: value,
          items: items.map<DropdownMenuItem<CategoryData>>((CategoryData item) {
            return DropdownMenuItem(
              value: item,
              child: Text('${item.emoji} ${item.name}'),
            );
          }).toList(),
          onChanged: onChanged,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          validator: validator,
        ),
      ],
    );
  }
}