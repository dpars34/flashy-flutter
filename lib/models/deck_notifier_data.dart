import 'package:flashy_flutter/models/category_data.dart';

import 'category_decks_data.dart';
import 'deck_data.dart';

class DeckNotifierData {
  final List<CategoryDecksData> homeDecks;
  final List<CategoryDecksData> detailDecks;

  DeckNotifierData({
    required this.homeDecks,
    required this.detailDecks,
  });
}