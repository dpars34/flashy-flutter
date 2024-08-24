import 'dart:io';

import 'package:flashy_flutter/screens/create/create_deck_confirm_screen.dart';
import 'package:flashy_flutter/screens/register/register_confirm_screen.dart';
import 'package:flashy_flutter/utils/api_exception.dart';
import 'package:flashy_flutter/widgets/custom_radio_button_field.dart';
import 'package:flashy_flutter/widgets/error_modal.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/category_data.dart';
import '../../models/question_controllers.dart';
import '../../notifiers/auth_notifier.dart';
import '../../notifiers/loading_notifier.dart';
import '../../widgets/base_button.dart';
import '../../widgets/custom_input_field.dart';

class CreateDeckQuestionsScreen extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final String leftOption;
  final String rightOption;
  final CategoryData? category;
  final List<QuestionControllers>? controllers;

  const CreateDeckQuestionsScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.leftOption,
    required this.rightOption,
    required this.category,
    this.controllers,
  }) : super(key: key);

  @override
  ConsumerState<CreateDeckQuestionsScreen> createState() => _CreateDeckQuestionsScreenState();
}

class _CreateDeckQuestionsScreenState extends ConsumerState<CreateDeckQuestionsScreen> {
  final _formKey = GlobalKey<FormState>();

  List<QuestionControllers> _controllers = [];
  bool validationChecked = false;

  // Add a new set of inputs for a question
  void _addQuestion() {
    if (_controllers.length > 50) {
      showModal(context, 'Limit reached', "You can only add a maximum of 50 cards!");
      return;
    }

    setState(() {
      _controllers.add(QuestionControllers(
        questionController: TextEditingController(),
        noteController: TextEditingController(),
        answerController: TextEditingController(),
      ));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _controllers.removeAt(index);
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
    Navigator.pop(context, _controllers);
  }

  void _toNextPage () async {
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final authNotifier = ref.watch(authProvider.notifier);

    setState(() {
      validationChecked = true;
    });

    bool allAnswersSelected = _controllers.every((q) => q.answerController.text.isNotEmpty);

    if (_formKey.currentState!.validate() && allAnswersSelected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateDeckConfirmScreen(
              title: widget.title,
              description: widget.description,
              leftOption: widget.leftOption,
              rightOption: widget.rightOption,
              category: widget.category,
              controllers: _controllers,
          ),
        ),
      );

    } else {
      // showModal(context, 'An Error Occurred', "Please check that the information you have entered is valid and try again.");
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch the deck data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controllers != null) {
        setState(() {
          _controllers = widget.controllers!;
        });
      } else {
        _controllers = [];
        for (int i = 0; i < 5; i++) {
          _addQuestion();
        }
      }
    });
  }

  // @override
  // void dispose() {
  //   for (var controllerSet in _controllers) {
  //     controllerSet.questionController.dispose();
  //     controllerSet.noteController.dispose();
  //     controllerSet.answerController.dispose();
  //   }
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(authProvider.notifier);
    final loadingNotifier = ref.read(loadingProvider.notifier);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: secondary,
          title: Text(widget.title),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              _goBack();
            },
          ),
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
                        return Stack(
                          children: [
                            Column(
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
                                        isError: question.answerController.text.isEmpty && validationChecked,
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
                                        isError: question.answerController.text.isEmpty && validationChecked,
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
                                        color: red,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 40),
                              ],
                            ),
                            if (index > 4) Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: gray),
                                onPressed: () => _removeQuestion(index),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 40.0),
                  BaseButton(onPressed: _addQuestion, text: 'Add question', outlined: true,),
                  const SizedBox(height: 12.0),
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
