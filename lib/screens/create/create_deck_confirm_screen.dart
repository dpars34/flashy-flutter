import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/widgets/base_button.dart';

import '../../models/question_controllers.dart';
import '../../notifiers/deck_notifier.dart';
import '../../utils/colors.dart';
import '../../notifiers/loading_notifier.dart';
import '../../notifiers/auth_notifier.dart';
import '../../utils/api_exception.dart';
import '../../widgets/error_modal.dart';
import '../account/account_edit_complete_screen.dart';
import 'create_deck_complete_screen.dart';

class CreateDeckConfirmScreen extends ConsumerWidget {
  final String title;
  final String description;
  final String leftOption;
  final String rightOption;
  final List<QuestionControllers> controllers;

  const CreateDeckConfirmScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.leftOption,
    required this.rightOption,
    required this.controllers,
  }) : super(key: key);

  void _goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final loadingNotifier = ref.read(loadingProvider.notifier);
    final authNotifier = ref.watch(authProvider.notifier);
    final deckNotifier = ref.watch(deckProvider.notifier);

    try {
      loadingNotifier.showLoading(context);
      await deckNotifier.submitDeck(title, description, leftOption, rightOption, controllers);
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CreateDeckCompleteScreen()),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        if (e.statusCode == 401 || e.statusCode == 422) {
          showModal(context, 'Submission Failed', 'Please try again');
        } else {
          showModal(context, 'An Error Occurred', 'Please try again');
        }
      } else {
        showModal(context, 'An Error Occurred', 'Please try again');
      }
    } finally {
      loadingNotifier.hideLoading();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondary,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Review questions',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: primary,
                  fontSize: 20,
                ),
              ),
              const Text(
                'Review your questions before submitting.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: black,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Title:',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: gray,
                  fontSize: 16,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: gray,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'Description:',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: gray,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: gray,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...controllers.asMap().entries.map((entry) {
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
                        const SizedBox(height: 4),
                        Text(
                          question.questionController.text,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: black,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (question.noteController.text.isNotEmpty)
                          Text(
                            'Note: ${question.noteController.text}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              color: gray,
                              fontSize: 14,
                            ),
                          ),
                        if (question.noteController.text.isNotEmpty) const SizedBox(height: 4),
                        Text(
                          '${question.answerController.text == 'left' ? leftOption : rightOption}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: primary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 40.0),
              BaseButton(
                onPressed: () => _goBack(context),
                text: 'Go back',
                outlined: true,
              ),
              const SizedBox(height: 12.0),
              BaseButton(
                onPressed: () => _submit(context, ref),
                text: 'Submit',
              ),
              const SizedBox(height: 92.0),
            ],
          ),
        ),
      ),
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

