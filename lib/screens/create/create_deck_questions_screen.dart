import 'dart:io';

import 'package:flashy_flutter/screens/register/register_confirm_screen.dart';
import 'package:flashy_flutter/utils/api_exception.dart';
import 'package:flashy_flutter/widgets/error_modal.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../notifiers/auth_notifier.dart';
import '../../notifiers/loading_notifier.dart';
import '../../widgets/base_button.dart';
import '../../widgets/custom_input_field.dart';

class CreateDeckQuestionsScreen extends ConsumerStatefulWidget {
  const CreateDeckQuestionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateDeckQuestionsScreen> createState() => _CreateDeckQuestionsScreenState();
}

class _CreateDeckQuestionsScreenState extends ConsumerState<CreateDeckQuestionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _leftOptionController = TextEditingController();
  final TextEditingController _rightOptionController = TextEditingController();

  String formatValidationErrors(Map<String, dynamic> errors) {
    List<String> errorMessages = [];

    errors.forEach((field, messages) {
      if (messages is List) {
        for (var message in messages) {
          errorMessages.add(message);
        }
      } else {
        errorMessages.add(messages);
      }
    });

    return errorMessages.join('\n\n');
  }

  void _goBack () {
    Navigator.of(context).pop();
  }

  void _toNextPage () async {
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final authNotifier = ref.watch(authProvider.notifier);

    if (_formKey.currentState!.validate()) {

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => RegisterConfirmScreen(
      //
      //     ),
      //   ),
      // );

    } else {
      // showModal(context, 'An Error Occurred', "Please check that the information you have entered is valid and try again.");
    }
  }

  @override
  void initState() {
    super.initState();

    // Fetch the deck data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(authProvider.notifier);
    final loadingNotifier = ref.read(loadingProvider.notifier);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: secondary,
          title: const Text(''),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'Create deck',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: primary,
                        fontSize: 20,
                      )
                  ),
                  const Text(
                      'Basic info',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: black,
                        fontSize: 16,
                      )
                  ),
                  const SizedBox(height: 24.0),
                  CustomInputField(
                    controller: _titleController,
                    labelText: 'Title',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12.0),
                  CustomInputField(
                    controller: _descriptionController,
                    labelText: 'Description (optional)',
                    minLines: 3,
                    maxLines: 3,
                    validator: (value) {
                      return null;
                    },
                  ),
                  const SizedBox(height: 40.0),
                  const Text(
                      'Options',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: gray,
                        fontSize: 14,
                      )
                  ),
                  const SizedBox(height: 12.0),
                  CustomInputField(
                    controller: _leftOptionController,
                    labelText: 'Left option',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an option';
                      }
                      if (value.length > 15) {
                        return 'Options must be 15 characters or less';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12.0),
                  CustomInputField(
                    controller: _rightOptionController,
                    labelText: 'Right option',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an option';
                      }
                      if (value.length > 15) {
                        return 'Options must be 15 characters or less';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40.0),
                  BaseButton(onPressed: _goBack, text: 'Go back', outlined: true,),
                  const SizedBox(height: 12.0),
                  BaseButton(onPressed: _toNextPage, text: 'Next'),
                  const SizedBox(height: 92.0),
                ],
              ),
            ),
          ),
        )
    );
  }
}

void showModal(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ErrorModal(title: title, content: content, context: context);
    },
  );
}
