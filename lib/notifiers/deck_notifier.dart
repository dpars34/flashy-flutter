import 'dart:convert';

import 'package:flashy_flutter/models/category_data.dart';
import 'package:flashy_flutter/models/deck_notifier_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/utils/api_helper.dart';
import '../models/category_decks_data.dart';
import '../models/deck_data.dart';
import '../models/question_controllers.dart';
import '../utils/api_exception.dart';
import 'auth_notifier.dart';

class DeckNotifier extends StateNotifier<DeckNotifierData> {
  DeckNotifier(this.ref) : super(DeckNotifierData(homeDecks: [], detailDecks: []));

  final Ref ref; // Reference to access other providers
  final ApiHelper apiHelper = ApiHelper();

  Future<void> fetchHomeDeckData() async {
    List<dynamic> jsonData = await apiHelper.get('/random-decks');
    final homeDecks = jsonData.map((json) => CategoryDecksData.fromJson(json)).toList();
    state = DeckNotifierData(
      homeDecks: homeDecks,
      detailDecks: state.detailDecks, // Keep the current detailDecks
    );
  }

  Future<void> fetchDeckDetails(int id) async {
    // Iterate over homeDecks to find the deck with the given id
    for (var homeDecksData in state.homeDecks) {
      final homeIndex = homeDecksData.decks.indexWhere((deck) => deck.id == id);

      if (homeIndex != -1 && homeDecksData.decks[homeIndex].cards != null) {
        return; // Cards are already loaded, no need to fetch
      }
    }

    // Iterate over detailDecks to find the deck with the given id
    for (var detailDecksData in state.detailDecks) {
      final detailIndex = detailDecksData.decks.indexWhere((deck) => deck.id == id);

      if (detailIndex != -1 && detailDecksData.decks[detailIndex].cards != null) {
        return; // Cards are already loaded, no need to fetch
      }
    }

    // Fetch the deck details from the API
    Map<String, dynamic> jsonData = await apiHelper.get('/decks/$id');
    DeckData deckData = DeckData.fromJson(jsonData);

    // Update homeDecks with the fetched deck details
    List<CategoryDecksData> updatedHomeDecks = state.homeDecks.map((categoryDecks) {
      return CategoryDecksData(
        category: categoryDecks.category,
        decks: categoryDecks.decks.map((deck) {
          if (deck.id == id) {
            return deckData;
          }
          return deck;
        }).toList(),
      );
    }).toList();

    // Update detailDecks with the fetched deck details
    List<CategoryDecksData> updatedDetailDecks = state.detailDecks.map((categoryDecks) {
      return CategoryDecksData(
        category: categoryDecks.category,
        decks: categoryDecks.decks.map((deck) {
          if (deck.id == id) {
            return deckData;
          }
          return deck;
        }).toList(),
      );
    }).toList();

    // Update the state with the new homeDecks and detailDecks
    state = DeckNotifierData(
      homeDecks: updatedHomeDecks,
      detailDecks: updatedDetailDecks,
    );
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

      // Update homeDecks
      List<CategoryDecksData> updatedHomeDecks = state.homeDecks.map((categoryDecks) {
        return CategoryDecksData(
          category: categoryDecks.category,
          decks: categoryDecks.decks.map((deck) {
            if (deck.id == id) {
              return deck.copyWith(likedUsers: likedUsers);
            }
            return deck;
          }).toList(),
        );
      }).toList();

      // Update detailDecks
      List<CategoryDecksData> updatedDetailDecks = state.detailDecks.map((categoryDecks) {
        return CategoryDecksData(
          category: categoryDecks.category,
          decks: categoryDecks.decks.map((deck) {
            if (deck.id == id) {
              return deck.copyWith(likedUsers: likedUsers);
            }
            return deck;
          }).toList(),
        );
      }).toList();

      // Update the state with the new homeDecks and detailDecks
      state = DeckNotifierData(
        homeDecks: updatedHomeDecks,
        detailDecks: updatedDetailDecks,
      );

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

      // Update homeDecks
      List<CategoryDecksData> updatedHomeDecks = state.homeDecks.map((categoryDecks) {
        return CategoryDecksData(
          category: categoryDecks.category,
          decks: categoryDecks.decks.map((deck) {
            if (deck.id == id) {
              return deck.copyWith(likedUsers: likedUsers);
            }
            return deck;
          }).toList(),
        );
      }).toList();

      // Update detailDecks
      List<CategoryDecksData> updatedDetailDecks = state.detailDecks.map((categoryDecks) {
        return CategoryDecksData(
          category: categoryDecks.category,
          decks: categoryDecks.decks.map((deck) {
            if (deck.id == id) {
              return deck.copyWith(likedUsers: likedUsers);
            }
            return deck;
          }).toList(),
        );
      }).toList();

      // Update the state with the new homeDecks and detailDecks
      state = DeckNotifierData(
        homeDecks: updatedHomeDecks,
        detailDecks: updatedDetailDecks,
      );

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

    // Update homeDecks
    List<CategoryDecksData> updatedHomeDecks = state.homeDecks.map((categoryDecks) {
      return CategoryDecksData(
        category: categoryDecks.category,
        decks: categoryDecks.decks.map((deck) {
          if (deck.id == deckId) {
            return deckData;
          }
          return deck;
        }).toList(),
      );
    }).toList();

    // Update detailDecks
    List<CategoryDecksData> updatedDetailDecks = state.detailDecks.map((categoryDecks) {
      return CategoryDecksData(
        category: categoryDecks.category,
        decks: categoryDecks.decks.map((deck) {
          if (deck.id == deckId) {
            return deckData;
          }
          return deck;
        }).toList(),
      );
    }).toList();

    // Update the state with the new homeDecks and detailDecks
    state = DeckNotifierData(
      homeDecks: updatedHomeDecks,
      detailDecks: updatedDetailDecks,
    );
  }
}

final deckProvider = StateNotifierProvider<DeckNotifier, DeckNotifierData>((ref) {
  return DeckNotifier(ref);
});
