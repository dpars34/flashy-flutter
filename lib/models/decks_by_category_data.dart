import 'category_data.dart';
import 'deck_data.dart';
import 'pagination_data.dart';

class DecksByCategoryData {
  final CategoryData category;
  final List<DeckData> decks;
  final PaginationData pagination;

  DecksByCategoryData({
    required this.category,
    required this.decks,
    required this.pagination
  });

  factory DecksByCategoryData.fromJson(Map<String, dynamic> json) {
    return DecksByCategoryData(
      category: CategoryData.fromJson(json['category']),
      decks: (json['decks'] as List<dynamic>)
          .map((deckJson) => DeckData.fromJson(deckJson))
          .toList(),
      pagination: PaginationData.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.toJson(),
      'decks': decks.map((deck) => deck.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}