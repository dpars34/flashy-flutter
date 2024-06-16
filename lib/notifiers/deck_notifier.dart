import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashy_flutter/utils/api_helper.dart';
import '../models/deck_data.dart';

class DeckNotifier extends StateNotifier<List<DeckData>> {
  DeckNotifier() : super([]);

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
}

final deckProvider = StateNotifierProvider<DeckNotifier, List<DeckData>>((ref) {
  return DeckNotifier();
});