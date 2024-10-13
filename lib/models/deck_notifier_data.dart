import 'package:flashy_flutter/models/decks_by_category_data.dart';
import 'decks_with_pagination.dart';

import 'category_decks_data.dart';
import 'deck_data.dart';

class DeckNotifierData {
  final List<CategoryDecksData> homeDecks;
  final List<DecksByCategoryData> detailDecks;
  final DecksWithPagination? userDecks;
  final DecksWithPagination? likedDecks;
  final DecksWithPagination? searchDecks;
  final List<DeckData>? notificationDecks;

  DeckNotifierData({
    required this.homeDecks,
    required this.detailDecks,
    required this.userDecks,
    required this.likedDecks,
    required this.searchDecks,
    required this.notificationDecks,
  });
}