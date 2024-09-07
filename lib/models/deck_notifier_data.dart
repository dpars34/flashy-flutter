import 'package:flashy_flutter/models/category_data.dart';
import 'package:flashy_flutter/models/decks_by_category_data.dart';

import 'category_decks_data.dart';
import 'deck_data.dart';

class DeckNotifierData {
  final List<CategoryDecksData> homeDecks;
  final List<DecksByCategoryData> detailDecks;
  final List<DeckData> userDecks;
  final List<DeckData> likedDecks;

  DeckNotifierData({
    required this.homeDecks,
    required this.detailDecks,
    required this.userDecks,
    required this.likedDecks,
  });
}