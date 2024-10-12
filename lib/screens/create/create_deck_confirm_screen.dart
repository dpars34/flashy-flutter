import 'dart:convert';

import 'package:flashy_flutter/models/draft_deck_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/widgets/base_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/category_data.dart';
import '../../models/deck_data.dart';
import '../../models/question_controllers.dart';
import '../../notifiers/deck_notifier.dart';
import '../../utils/colors.dart';
import '../../notifiers/loading_notifier.dart';
import '../../notifiers/auth_notifier.dart';
import '../../utils/api_exception.dart';
import '../../widgets/error_modal.dart';
import '../../widgets/option_pill.dart';
import '../account/account_edit_complete_screen.dart';
import 'create_deck_complete_screen.dart';

class CreateDeckConfirmScreen extends ConsumerWidget {
  final String title;
  final String description;
  final String leftOption;
  final String rightOption;
  final CategoryData? category;
  final List<QuestionControllers> controllers;
  final DeckData? editDeck;
  final int? draftId;

  const CreateDeckConfirmScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.leftOption,
    required this.rightOption,
    required this.category,
    required this.controllers,
    required this.editDeck,
    required this.draftId,
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
      if (draftId != null && editDeck != null) {
        await deckNotifier.submitDeck(title, description, leftOption, rightOption, category, controllers);

        final prefs = await SharedPreferences.getInstance();
        final String? jsonString = prefs.getString('draftDecks');
        List<dynamic> jsonData = [];

        if (jsonString != null) jsonData = jsonDecode(jsonString);
        List<DraftDeckData>decks = jsonData.map((deckJson) => DraftDeckData.fromJson(deckJson)).toList();

        int index = decks.indexWhere((deck) => deck.id == draftId);
        if (index != -1) {
          decks.removeAt(index);
        }

        String decksAsJsonString = jsonEncode(decks.map((deck) => deck.toJson()).toList());
        prefs.setString('draftDecks', decksAsJsonString);
      } else if (editDeck != null) {
        await deckNotifier.updateDeck(title, description, leftOption, rightOption, category, controllers, editDeck!.id);
      } else {
        await deckNotifier.submitDeck(title, description, leftOption, rightOption, category, controllers);
      }
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CreateDeckCompleteScreen(isEdit: editDeck != null)),
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
                  color: black,
                  fontSize: 24,
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
              const SizedBox(height: 12.0),
              const Text(
                'Category:',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: gray,
                  fontSize: 16,
                ),
              ),
              Text(
                '${category!.emoji} ${category!.name}',
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
                        Row(
                          children: [
                            Text(
                              'Question ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: gray,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 8),
                            OptionPill(
                              color: question.answerController.text == 'left' ? 'yellow' : 'purple',
                              text: question.answerController.text == 'left' ? leftOption : rightOption
                            ),
                          ],
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

