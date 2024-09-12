import 'category_data.dart';
import 'deck_data.dart';
import 'pagination_data.dart';

class DecksWithPagination {
  final List<DeckData> decks;
  final PaginationData pagination;

  DecksWithPagination({
    required this.decks,
    required this.pagination
  });

  factory DecksWithPagination.fromJson(Map<String, dynamic> json) {
    return DecksWithPagination(
      decks: (json['decks'] as List<dynamic>)
          .map((deckJson) => DeckData.fromJson(deckJson))
          .toList(),
      pagination: PaginationData.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'decks': decks.map((deck) => deck.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}