import 'dart:convert';

import 'package:flashy_flutter/models/category_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/utils/api_helper.dart';
import '../models/deck_data.dart';
import '../models/question_controllers.dart';
import '../utils/api_exception.dart';
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
      CategoryData? category,
      List<QuestionControllers> questions,
      ) async {

    final user = ref.read(authProvider);
    if (user == null) {
      throw Exception('User is not logged in');
    }

    Map<String, dynamic> body = {
      'name': name,
      'description': description,
      'category_id': category!.id,
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

  Future<void> likeDeck(int id) async {
    try {
      var response = await apiHelper.post('/like-deck/$id', {});
      List<int> likedUsers = List<int>.from(response['liked_users']);

      final index = state.indexWhere((deck) => deck.id == id);
      if (index != -1) {
        final updatedDeck = state[index].copyWith(likedUsers: likedUsers);
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == index) updatedDeck else state[i]
        ];
      }

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<void> unlikeDeck(int id) async {
    try {
      var response = await apiHelper.delete('/like-deck/$id');
      List<int> likedUsers = List<int>.from(response['liked_users']);

      final index = state.indexWhere((deck) => deck.id == id);
      if (index != -1) {
        final updatedDeck = state[index].copyWith(likedUsers: likedUsers);
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == index) updatedDeck else state[i]
        ];
      }

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<void> submitHighscore(
      int deckId,
      int time,
      ) async {

    final user = ref.read(authProvider);
    if (user == null) {
      throw Exception('User is not logged in');
    }

    Map<String, dynamic> body = {
      'deck_id': deckId,
      'user_id': user.id,
      'time': time,
    };

    Map<String, dynamic> jsonData = await apiHelper.postNoConvert('/update-highscore', body);
    DeckData deckData = DeckData.fromJson(jsonData);

    state = [
      for (final deck in state)
        if (deck.id == deckId) deckData else deck
    ];
  }
}

final deckProvider = StateNotifierProvider<DeckNotifier, List<DeckData>>((ref) {
  return DeckNotifier(ref);
});
