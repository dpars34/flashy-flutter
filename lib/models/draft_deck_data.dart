import 'category_data.dart';
import 'deck_data.dart';
import 'pagination_data.dart';

class DraftDeckData {
  final int id;
  final DeckData deck;

  DraftDeckData({
    required this.deck,
    required this.id
  });

  factory DraftDeckData.fromJson(Map<String, dynamic> json) {
    return DraftDeckData(
      id: json['id'],
      deck: DeckData.fromJson(json['deck']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deck': deck.toJson()
    };
  }
}