import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/utils/api_helper.dart';
import '../models/deck_data.dart';
import '../models/question_controllers.dart';
import 'auth_notifier.dart';

class DeckNotifier extends StateNotifier<List<DeckData>> {
  DeckNotifier(this.ref) : super([]);

  final Ref ref; // Reference to access other providers
  final ApiHelper apiHelper = ApiHelper();

  Future<void> fetchDeckData() async {
    List<dynamic> jsonData = await apiHelper.get('/decks');
    state = jsonData.map((json) => DeckData.fromJson(json)).toList();
  }

  Future<void> fetchDeckDetails(int id) async {
    // if cards have already been loaded then return
    final index = state.indexWhere((deck) => deck.id == id);
    if (index != -1 && state[index].cards != null) {
      return;
    }

    Map<String, dynamic> jsonData = await apiHelper.get('/decks/$id');
    DeckData deckData = DeckData.fromJson(jsonData);

    state = [
      for (final deck in state)
        if (deck.id == id) deckData else deck
    ];
  }

  Future<void> submitDeck(
      String name,
      String description,
      String leftOption,
      String rightOption,
      List<QuestionControllers> questions,
      ) async {

    final user = ref.read(authProvider);
    if (user == null) {
      throw Exception('User is not logged in');
    }

    Map<String, dynamic> body = {
      'name': name,
      'description': description,
      'categories': [],
      'left_option': leftOption,
      'right_option': rightOption,
      'count': questions.length,
      'creator_user_id': user.id,
      'cards': questions.map((q) => {
        'text': q.questionController.text,
        'note': q.noteController.text,
        'answer': q.answerController.text,
      }).toList(),
    };

    Map<String, dynamic> jsonData = await apiHelper.postNoConvert('/submit-deck', body);
  }
}

final deckProvider = StateNotifierProvider<DeckNotifier, List<DeckData>>((ref) {
  return DeckNotifier(ref);
});
