import 'dart:io';

import 'package:flashy_flutter/models/category_data.dart';
import 'package:flashy_flutter/screens/register/register_confirm_screen.dart';
import 'package:flashy_flutter/utils/api_exception.dart';
import 'package:flashy_flutter/widgets/custom_dropdown_field.dart';
import 'package:flashy_flutter/widgets/error_modal.dart';
import 'package:flutter/material.dart';
import 'package:flashy_flutter/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/question_controllers.dart';
import '../../notifiers/auth_notifier.dart';
import '../../notifiers/category_notifier.dart';
import '../../notifiers/loading_notifier.dart';
import '../../widgets/base_button.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_modal.dart';
import 'create_deck_questions_screen.dart';

class CreateDeckScreen extends ConsumerStatefulWidget {
  const CreateDeckScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateDeckScreen> createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends ConsumerState<CreateDeckScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _leftOptionController = TextEditingController();
  final TextEditingController _rightOptionController = TextEditingController();
  CategoryData? _category;
  List<QuestionControllers>? _controllers;

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

  void _handleCategorySelect (CategoryData? value) {
    setState(() {
      _category = value;
    });
  }

  void _goBack () {

    void doNothing () {}

    void goBack () {
      Navigator.pop(context);
    }

    showBackModal(
      context,
      'Are you sure you want to go back?',
      'Your new deck will not be saved!',
      'Keep editing',
      'Go back',
      doNothing,
      goBack,
    );
  }

  void _toNextPage () async {
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final authNotifier = ref.watch(authProvider.notifier);

    if (_formKey.currentState!.validate()) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateDeckQuestionsScreen(
              title: _titleController.text,
              description: _descriptionController.text,
              leftOption: _leftOptionController.text,
              rightOption: _rightOptionController.text,
              category: _category,
              controllers: _controllers,
          ),
        ),
      ).then((result) {
        if (result != null) {
          _controllers = result;
        }
      });
    } else {
      // showModal(context, 'An Error Occurred', "Please check that the information you have entered is valid and try again.");
    }
  }

  @override
  void initState() {
    super.initState();

    // Fetch the deck data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _leftOptionController.text = 'false';
      _rightOptionController.text = 'true';
    });
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(authProvider.notifier);
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final categoryNotifier = ref.read(categoryProvider.notifier);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: secondary,
          title: const Text(''),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
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
                    maxLength: 50,
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
                    maxLength: 200,
                    validator: (value) {
                      return null;
                    },
                  ),
                  const SizedBox(height: 12.0),
                  CustomDropdownField(
                      labelText: 'Category',
                      value: _category,
                      items: categoryNotifier.state,
                      onChanged: _handleCategorySelect,
                      validator: (value) {
                        if (value == null) {
                          return 'Please enter a category';
                        }
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
                  Row(
                    children: [
                      Expanded(
                        child: CustomInputField(
                          controller: _leftOptionController,
                          labelText: 'Left option',
                          maxLength: 15,
                          caplitalize: false,
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
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: CustomInputField(
                          controller: _rightOptionController,
                          labelText: 'Right option',
                          maxLength: 15,
                          caplitalize: false,
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
                      ),
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

void showBackModal(BuildContext context, String title, String content, String button1Text, String button2Text, VoidCallback button1Callback, VoidCallback button2Callback) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomModal(
        title: title,
        content: content,
        button1Text: button1Text,
        button2Text: button2Text,
        button1Callback: button1Callback,
        button2Callback: button2Callback,
      );
    },
  );
}
