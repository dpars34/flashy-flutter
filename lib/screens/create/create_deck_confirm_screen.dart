import 'dart:io';

import 'package:flashy_flutter/screens/register/register_confirm_screen.dart';
import 'package:flashy_flutter/utils/api_exception.dart';
import 'package:flashy_flutter/widgets/custom_radio_button_field.dart';
import 'package:flashy_flutter/widgets/error_modal.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../notifiers/auth_notifier.dart';
import '../../notifiers/loading_notifier.dart';
import '../../widgets/base_button.dart';
import '../../widgets/custom_input_field.dart';

class QuestionControllers {
  final TextEditingController questionController;
  final TextEditingController noteController;
  final TextEditingController answerController;

  QuestionControllers({
    required this.questionController,
    required this.noteController,
    required this.answerController,
  });
}

class CreateDeckConfirmScreen extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final String leftOption;
  final String rightOption;

  const CreateDeckConfirmScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.leftOption,
    required this.rightOption,
  }) : super(key: key);

  @override
  ConsumerState<CreateDeckConfirmScreen> createState() => _CreateDeckConfirmScreenState();
}

class _CreateDeckConfirmScreenState extends ConsumerState<CreateDeckConfirmScreen> {
  final _formKey = GlobalKey<FormState>();

  List<QuestionControllers> _controllers = [];
  bool validationChecked = false;

  // Add a new set of inputs for a question
  void _addQuestion() {
    setState(() {
      _controllers.add(QuestionControllers(
        questionController: TextEditingController(),
        noteController: TextEditingController(),
        answerController: TextEditingController(),
      ));
    });
  }

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
      _controllers = [];
      for (int i = 0; i < 5; i++) {
        _addQuestion();
      }
    });
  }

  @override
  void dispose() {
    for (var controllerSet in _controllers) {
      controllerSet.questionController.dispose();
      controllerSet.noteController.dispose();
      controllerSet.answerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(authProvider.notifier);
    final loadingNotifier = ref.read(loadingProvider.notifier);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: secondary,
          title: Text(widget.title),
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
                      'Add questions',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: primary,
                        fontSize: 20,
                      )
                  ),
                  const SizedBox(height: 12.0),
                  const Text(
                      'Decks must have a minimum of 5 questions.',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: black,
                        fontSize: 14,
                      )
                  ),
                  const SizedBox(height: 12.0),
                  const Text(
                      'Extra information can be provided as a "note". This is only shown once a quiz has been completed.',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: black,
                        fontSize: 14,
                      )
                  ),
                  // const Text(
                  //     'Questions',
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.w800,
                  //       color: black,
                  //       fontSize: 16,
                  //     )
                  // ),
                  const SizedBox(height: 24.0),
                  Column(
                    children: [
                      ..._controllers.asMap().entries.map((entry) {
                        int index = entry.key;
                        var question = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: gray,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomInputField(
                              controller: question.questionController,
                              labelText: 'Question',
                              minLines: 3,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a question';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            CustomInputField(
                              controller: question.noteController,
                              labelText: 'Note',
                              validator: (value) {
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Answer',
                              style: TextStyle(
                                color: gray,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomRadioButtonField(
                                    labelText: widget.leftOption,
                                    value: question.answerController.text == 'left',
                                    onChanged: (newValue) {
                                      setState(() {
                                        question.answerController.text = 'left';
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomRadioButtonField(
                                    labelText: widget.rightOption,
                                    value: question.answerController.text == 'right',
                                    onChanged: (newValue) {
                                      setState(() {
                                        question.answerController.text = 'right';
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (question.answerController.text.isEmpty && validationChecked)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Please select an answer for Question ${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 40),
                          ],
                        );
                      }).toList(),
                    ],
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
