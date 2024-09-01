import 'package:flashy_flutter/models/category_data.dart';

import 'deck_data.dart';

class CategoryDecksData {
  final CategoryData category;
  final List<DeckData> decks;

  CategoryDecksData({
    required this.category,
    required this.decks,
  });

  factory CategoryDecksData.fromJson(Map<String, dynamic> json) {
    return CategoryDecksData(
      category: CategoryData.fromJson(json['category']),
      decks: (json['decks'] as List<dynamic>)
          .map((deckJson) => DeckData.fromJson(deckJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.toJson(),
      'decks': decks.map((deck) => deck.toJson()).toList(),
    };
  }
}