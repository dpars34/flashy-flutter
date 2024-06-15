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
}

final deckProvider = StateNotifierProvider<DeckNotifier, List<DeckData>>((ref) {
  return DeckNotifier();
});