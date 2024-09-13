import 'dart:convert';

import 'package:flashy_flutter/models/category_data.dart';
import 'package:flashy_flutter/models/deck_notifier_data.dart';
import 'package:flashy_flutter/models/decks_by_category_data.dart';
import 'package:flashy_flutter/models/decks_with_pagination.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/utils/api_helper.dart';
import '../models/category_decks_data.dart';
import '../models/deck_data.dart';
import '../models/question_controllers.dart';
import '../utils/api_exception.dart';
import 'auth_notifier.dart';

class DeckNotifier extends StateNotifier<DeckNotifierData> {
  DeckNotifier(this.ref) : super(DeckNotifierData(
    homeDecks: [],
    detailDecks: [],
    userDecks: null,
    likedDecks: null,
  ));

  final Ref ref; // Reference to access other providers
  final ApiHelper apiHelper = ApiHelper();

  Future<void> fetchHomeDeckData() async {
    List<dynamic> jsonData = await apiHelper.get('/random-decks');
    final homeDecks = jsonData.map((json) => CategoryDecksData.fromJson(json)).toList();
    state = DeckNotifierData(
      homeDecks: homeDecks,
      detailDecks: state.detailDecks,
      userDecks: state.userDecks,
      likedDecks: state.likedDecks,
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
    List<DecksByCategoryData> updatedDetailDecks = state.detailDecks.map((categoryDecks) {
      return DecksByCategoryData(
        category: categoryDecks.category,
        decks: categoryDecks.decks.map((deck) {
          if (deck.id == id) {
            return deckData;
          }
          return deck;
        }).toList(),
        pagination: categoryDecks.pagination,
      );
    }).toList();

    // Update userDecks
    DecksWithPagination? updatedUserDecks = state.userDecks != null ? DecksWithPagination(
      decks: state.userDecks!.decks.map((deck) {
        if (deck.id == id) {
          return deckData;
        }
        return deck;
      }).toList(),
      pagination: state.userDecks!.pagination,
    ) : null;

    // Update likedDecks
    DecksWithPagination? updatedLikedDecks = state.likedDecks != null ? DecksWithPagination(
      decks: state.likedDecks!.decks.map((deck) {
        if (deck.id == id) {
          return deckData;
        }
        return deck;
      }).toList(),
      pagination: state.likedDecks!.pagination,
    ) : null;

    // Update the state with the new homeDecks and detailDecks
    state = DeckNotifierData(
      homeDecks: updatedHomeDecks,
      detailDecks: updatedDetailDecks,
      userDecks: updatedUserDecks,
      likedDecks: updatedLikedDecks,
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
      List<DecksByCategoryData> updatedDetailDecks = state.detailDecks.map((categoryDecks) {
        return DecksByCategoryData(
          category: categoryDecks.category,
          decks: categoryDecks.decks.map((deck) {
            if (deck.id == id) {
              return deck.copyWith(likedUsers: likedUsers);
            }
            return deck;
          }).toList(),
          pagination: categoryDecks.pagination
        );
      }).toList();

      DecksWithPagination? updatedUserDecks = state.userDecks != null ? DecksWithPagination(
        decks: state.userDecks!.decks.map((deck) {
          if (deck.id == id) {
            return deck.copyWith(likedUsers: likedUsers);
          }
          return deck;
        }).toList(),
        pagination: state.userDecks!.pagination,
      ) : null;

      DecksWithPagination? updatedLikedDecks = state.likedDecks != null ? DecksWithPagination(
        decks: state.likedDecks!.decks.map((deck) {
          if (deck.id == id) {
            return deck.copyWith(likedUsers: likedUsers);
          }
          return deck;
        }).toList(),
        pagination: state.likedDecks!.pagination,
      ) : null;

      // Update the state with the new homeDecks and detailDecks
      state = DeckNotifierData(
        homeDecks: updatedHomeDecks,
        detailDecks: updatedDetailDecks,
        userDecks: updatedUserDecks,
        likedDecks: updatedLikedDecks,
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
      List<DecksByCategoryData> updatedDetailDecks = state.detailDecks.map((categoryDecks) {
        return DecksByCategoryData(
          category: categoryDecks.category,
          decks: categoryDecks.decks.map((deck) {
            if (deck.id == id) {
              return deck.copyWith(likedUsers: likedUsers);
            }
            return deck;
          }).toList(),
          pagination: categoryDecks.pagination
        );
      }).toList();

      DecksWithPagination? updatedUserDecks = state.userDecks != null ? DecksWithPagination(
        decks: state.userDecks!.decks.map((deck) {
          if (deck.id == id) {
            return deck.copyWith(likedUsers: likedUsers);
          }
          return deck;
        }).toList(),
        pagination: state.userDecks!.pagination,
      ) : null;

      DecksWithPagination? updatedLikedDecks = state.likedDecks != null ? DecksWithPagination(
        decks: state.likedDecks!.decks.map((deck) {
          if (deck.id == id) {
            return deck.copyWith(likedUsers: likedUsers);
          }
          return deck;
        }).toList(),
        pagination: state.likedDecks!.pagination,
      ) : null;

      // Update the state with the new homeDecks and detailDecks
      state = DeckNotifierData(
        homeDecks: updatedHomeDecks,
        detailDecks: updatedDetailDecks,
        userDecks: updatedUserDecks,
        likedDecks: updatedLikedDecks,
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
    List<DecksByCategoryData> updatedDetailDecks = state.detailDecks.map((categoryDecks) {
      return DecksByCategoryData(
        category: categoryDecks.category,
        decks: categoryDecks.decks.map((deck) {
          if (deck.id == deckId) {
            return deckData;
          }
          return deck;
        }).toList(),
        pagination: categoryDecks.pagination
      );
    }).toList();

    DecksWithPagination? updatedUserDecks = state.userDecks != null ? DecksWithPagination(
      decks: state.userDecks!.decks.map((deck) {
        if (deck.id == deckId) {
          return deckData;
        }
        return deck;
      }).toList(),
      pagination: state.userDecks!.pagination,
    ) : null;

    DecksWithPagination? updatedLikedDecks = state.userDecks != null ? DecksWithPagination(
      decks: state.likedDecks!.decks.map((deck) {
        if (deck.id == deckId) {
          return deckData;
        }
        return deck;
      }).toList(),
      pagination: state.likedDecks!.pagination,
    ) : null;


    // Update the state with the new homeDecks and detailDecks
    state = DeckNotifierData(
      homeDecks: updatedHomeDecks,
      detailDecks: updatedDetailDecks,
      userDecks: updatedUserDecks,
      likedDecks: updatedLikedDecks,
    );
  }

  Future<void> fetchDecksByCategory(int categoryId, int limit, int page) async {
    try {
      // Fetch data from the API with pagination
      var response = await apiHelper.get('/decks/category/$categoryId?limit=$limit&page=$page');

      // Assuming response is an object, not a list
      final DecksByCategoryData data = DecksByCategoryData.fromJson(response);

      int categoryIndex = state.detailDecks.indexWhere((item) => item.category.id == categoryId);
      List<DecksByCategoryData> updatedDetailDecks;

      if (categoryIndex != -1) {
        // Category exists, merge the decks with pagination
        updatedDetailDecks = state.detailDecks.map((categoryDecks) {
          if (categoryDecks.category.id == categoryId) {
            return DecksByCategoryData(
              category: categoryDecks.category,
              decks: [...categoryDecks.decks, ...data.decks], // Merge the decks
              pagination: data.pagination, // Update pagination info
            );
          }
          return categoryDecks;
        }).toList();
      } else {
        // Category does not exist, add a new one
        updatedDetailDecks = [
          ...state.detailDecks,
          DecksByCategoryData(
            category: data.category,
            decks: data.decks,
            pagination: data.pagination,
          )
        ];
      }

      // Update the state with the new homeDecks and detailDecks
      state = DeckNotifierData(
        homeDecks: state.homeDecks,
        detailDecks: updatedDetailDecks,
        userDecks: state.userDecks,
        likedDecks: state.likedDecks,
      );

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<void> fetchUserDecks(int limit, int page) async {
    try {
      // Fetch data from the API with pagination
      var response = await apiHelper.get('/decks/created-decks?limit=$limit&page=$page');

      final DecksWithPagination data = DecksWithPagination.fromJson(response);

      DecksWithPagination updatedUserDecks;

      if (state.userDecks != null) {
        updatedUserDecks = DecksWithPagination(
          decks: [...state.likedDecks!.decks, ...data.decks],
          pagination: data.pagination,
        );
      } else {
        updatedUserDecks = data;
      }

      // Update the state with the new homeDecks and detailDecks
      state = DeckNotifierData(
        homeDecks: state.homeDecks,
        detailDecks: state.detailDecks,
        userDecks: updatedUserDecks,
        likedDecks: state.likedDecks,
      );

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }

  Future<void> fetchLikedDecks(int limit, int page) async {
    try {
      // Fetch data from the API with pagination
      var response = await apiHelper.get('/decks/liked-decks?limit=$limit&page=$page');

      final DecksWithPagination data = DecksWithPagination.fromJson(response);

      DecksWithPagination updatedLikedDecks;

      if (state.likedDecks != null) {
        updatedLikedDecks = DecksWithPagination(
          decks: [...state.likedDecks!.decks, ...data.decks],
          pagination: data.pagination,
        );
      } else {
        updatedLikedDecks = data;
      }

      // Update the state with the new homeDecks and detailDecks
      state = DeckNotifierData(
        homeDecks: state.homeDecks,
        detailDecks: state.detailDecks,
        userDecks: state.userDecks,
        likedDecks: updatedLikedDecks,
      );

    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.statusCode, e.message);
      } else {
        throw ApiException(500, 'Unexpected Error: $e');
      }
    }
  }
}

final deckProvider = StateNotifierProvider<DeckNotifier, DeckNotifierData>((ref) {
  return DeckNotifier(ref);
});
